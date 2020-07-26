/******************************************************************************
 * Copyright © 2013-2019 The Komodo Platform Developers.                      *
 *                                                                            *
 * See the AUTHORS, DEVELOPER-AGREEMENT and LICENSE files at                  *
 * the top-level directory of this distribution for the individual copyright  *
 * holder information and the developer policies on copyright and licensing.  *
 *                                                                            *
 * Unless otherwise agreed in a custom licensing agreement, no part of the    *
 * Komodo Platform software, including this file may be copied, modified,     *
 * propagated or distributed except according to the terms contained in the   *
 * LICENSE file                                                               *
 *                                                                            *
 * Removal or modification of this copyright notice is prohibited.            *
 *                                                                            *
 ******************************************************************************/

//! Project headers
#include "atomic.dex.provider.cex.prices.hpp"
#include "atomic.dex.provider.cex.prices.api.hpp"
#include "atomic.threadpool.hpp"

namespace atomic_dex
{
    cex_prices_provider::cex_prices_provider(entt::registry& registry, mm2& mm2_instance) : system(registry), m_mm2_instance(mm2_instance)
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        disable();
        dispatcher_.sink<mm2_started>().connect<&cex_prices_provider::on_mm2_started>(*this);
        dispatcher_.sink<orderbook_refresh>().connect<&cex_prices_provider::on_current_orderbook_ticker_pair_changed>(*this);
    }

    void
    cex_prices_provider::update() noexcept
    {
    }

    cex_prices_provider::~cex_prices_provider() noexcept
    {
        //!
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

        consume_pending_tasks();

        m_provider_thread_timer.interrupt();

        if (m_provider_ohlc_fetcher_thread.joinable())
        {
            m_provider_ohlc_fetcher_thread.join();
        }

        dispatcher_.sink<mm2_started>().disconnect<&cex_prices_provider::on_mm2_started>(*this);
        dispatcher_.sink<orderbook_refresh>().disconnect<&cex_prices_provider::on_current_orderbook_ticker_pair_changed>(*this);
    }

    void
    cex_prices_provider::on_current_orderbook_ticker_pair_changed(const orderbook_refresh& evt) noexcept
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

        if (auto [normal, quoted] = is_pair_supported(evt.base, evt.rel); !normal && !quoted)
        {
            m_current_ohlc_data->clear();
            m_current_orderbook_ticker_pair.first  = "";
            m_current_orderbook_ticker_pair.second = "";
            this->dispatcher_.trigger<refresh_ohlc_needed>();
            return;
        }

        m_current_ohlc_data             = nlohmann::json::array();
        m_current_orderbook_ticker_pair = {boost::algorithm::to_lower_copy(evt.base), boost::algorithm::to_lower_copy(evt.rel)};
        auto [base, rel]                = m_current_orderbook_ticker_pair;
        spdlog::debug("new orderbook pair for cex provider [{} / {}]", base, rel);
        m_pending_tasks.push(spawn([base = base, rel = rel, this]() { process_ohlc(base, rel, true); }));
    }

    void
    cex_prices_provider::on_mm2_started([[maybe_unused]] const mm2_started& evt) noexcept
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

        m_provider_ohlc_fetcher_thread = std::thread([this]() {
            //
            spdlog::info("cex prices provider thread started");

            using namespace std::chrono_literals;
            do
            {
                spdlog::info("fetching ohlc value");
                auto [base, rel] = m_current_orderbook_ticker_pair;
                if (not base.empty() && not rel.empty() && m_mm2_instance.is_orderbook_thread_active())
                {
                    process_ohlc(base, rel);
                }
                else
                {
                    spdlog::info("Nothing todo, sleeping");
                }
            } while (not m_provider_thread_timer.wait_for(1min));
        });
    }

    bool
    cex_prices_provider::process_ohlc(const std::string& base, const std::string& rel, bool is_a_reset) noexcept
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        if (auto [normal, quoted] = is_pair_supported(base, rel); normal || quoted)
        {
            spdlog::info("{} / {} is supported, processing", base, rel);
            atomic_dex::ohlc_request req{base, rel};
            if (quoted)
            {
                //! Quoted
                req.base_asset  = rel;
                req.quote_asset = base;
            }
            auto answer = atomic_dex::rpc_ohlc_get_data(std::move(req));
            if (answer.result.has_value())
            {
                m_current_ohlc_data = answer.result.value().raw_result;
                if (quoted)
                {
                    //! It's quoted need to reverse all the value
                    this->reverse_ohlc_data();
                }
                this->compute_moving_average();
                this->dispatcher_.trigger<refresh_ohlc_needed>(is_a_reset);
                return true;
            }
            spdlog::error("http error: {}", answer.error.value_or("dummy"));
            return false;
        }

        spdlog::warn("{} / {}  not supported yet from the provider, skipping", base, rel);
        return false;
    }

    std::pair<bool, bool>
    cex_prices_provider::is_pair_supported(const std::string& base, const std::string& rel) const noexcept
    {
        std::pair<bool, bool> result;
        const std::string     tickers = boost::algorithm::to_lower_copy(base) + "-" + boost::algorithm::to_lower_copy(rel);
        result.first                  = std::any_of(begin(m_supported_pair), end(m_supported_pair), [tickers](auto&& cur_str) { return cur_str == tickers; });
        const std::string quoted_tickers = boost::algorithm::to_lower_copy(rel) + "-" + boost::algorithm::to_lower_copy(base);
        result.second = std::any_of(begin(m_supported_pair), end(m_supported_pair), [quoted_tickers](auto&& cur_str) { return cur_str == quoted_tickers; });
        return result;
    }

    bool
    cex_prices_provider::is_ohlc_data_available() const noexcept
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        bool res = false;
        res      = !m_current_ohlc_data->empty();
        return res;
    }

    nlohmann::json
    cex_prices_provider::get_ohlc_data(const std::string& range) noexcept
    {
        nlohmann::json res = nlohmann::json::array();
        if (m_current_ohlc_data->contains(range))
        {
            res = m_current_ohlc_data->at(range);
        }
        return res;
    }

    void
    cex_prices_provider::consume_pending_tasks()
    {
        while (not m_pending_tasks.empty())
        {
            auto& fut_tasks = m_pending_tasks.front();
            if (fut_tasks.valid())
            {
                fut_tasks.wait();
            }
            m_pending_tasks.pop();
        }
    }

    void
    cex_prices_provider::reverse_ohlc_data() noexcept
    {
        nlohmann::json values = *this->m_current_ohlc_data;
        for (auto&& item: values)
        {
            for (auto&& cur_range: item)
            {
                cur_range["open"]         = 1 / cur_range.at("open").get<double>();
                cur_range["high"]         = 1 / cur_range.at("high").get<double>();
                cur_range["low"]          = 1 / cur_range.at("low").get<double>();
                cur_range["close"]        = 1 / cur_range.at("close").get<double>();
                auto volume               = cur_range.at("volume").get<double>();
                cur_range["volume"]       = cur_range["quote_volume"];
                cur_range["quote_volume"] = volume;
            }
        }
        m_current_ohlc_data = values;
    }

    nlohmann::json
    cex_prices_provider::get_all_ohlc_data() noexcept
    {
        return *m_current_ohlc_data;
    }

    void
    cex_prices_provider::compute_moving_average()
    {
        std::vector<ma_series_data> ma_20_series;
        std::vector<ma_series_data> ma_50_series;
        nlohmann::json              ohlc_data                  = *this->m_current_ohlc_data;
        auto                        add_moving_average_functor = [](nlohmann::json& current_item, std::size_t idx, std::vector<ma_series_data>& ma_series,
                                             const std::vector<double>& sums, float num) {
            if (idx >= num)
            {
                ma_series.push_back({current_item.at("timestamp").get<std::size_t>(), (sums.at(idx) - sums.at(idx - num)) / num});
            }
        };

        for (auto&& [key, value]: ohlc_data.items())
        {
            std::size_t         idx = 0;
            std::vector<double> sums;
            ma_20_series.clear();
            ma_50_series.clear();
            for (auto&& cur_range: value)
            {
                if (idx == 0)
                {
                    sums.emplace_back(cur_range.at("open").get<double>());
                }
                else
                {
                    sums.emplace_back(cur_range.at("open").get<double>() + sums[idx - 1]);
                }
                add_moving_average_functor(cur_range, idx, ma_20_series, sums, 20.f);
                add_moving_average_functor(cur_range, idx, ma_50_series, sums, 50.f);
                ++idx;
            }

            m_ma_20_series_registry->operator[](key) = ma_20_series;
            m_ma_50_series_registry->operator[](key) = ma_50_series;
        }
    }

    std::vector<ma_series_data>
    cex_prices_provider::get_ma_series_data(moving_average scope, const std::string& range) const noexcept
    {
        switch (scope)
        {
        case moving_average::twenty:
            return m_ma_20_series_registry->at(range);
        case moving_average::fifty:
            return m_ma_50_series_registry->at(range);
        }
    }
} // namespace atomic_dex