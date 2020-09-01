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

//! PCH
#include "atomic.dex.pch.hpp"

//! Project headers
#include "atomic.dex.provider.cex.prices.hpp"
#include "atomic.dex.provider.cex.prices.api.hpp"

namespace atomic_dex
{
    cex_prices_provider::cex_prices_provider(entt::registry& registry, mm2& mm2_instance) : system(registry), m_mm2_instance(mm2_instance)
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        dispatcher_.sink<mm2_started>().connect<&cex_prices_provider::on_mm2_started>(*this);
        dispatcher_.sink<orderbook_refresh>().connect<&cex_prices_provider::on_current_orderbook_ticker_pair_changed>(*this);
    }

    void
    cex_prices_provider::update() noexcept
    {
        using namespace std::chrono_literals;

        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - m_update_clock);
        if (s >= 1min)
        {
            m_update_clock = std::chrono::high_resolution_clock::now();
            if (m_mm2_started)
            {
                update_ohlc();
            }
        }
    }

    cex_prices_provider::~cex_prices_provider() noexcept
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
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
        process_ohlc(base, rel, true);
    }

    void
    cex_prices_provider::on_mm2_started([[maybe_unused]] const mm2_started& evt) noexcept
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        m_mm2_started  = true;
        m_update_clock = std::chrono::high_resolution_clock::now();
        update_ohlc();
    }

    bool
    cex_prices_provider::process_ohlc(const std::string& base, const std::string& rel, bool is_a_reset) noexcept
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        if (auto [normal, quoted] = is_pair_supported(base, rel); normal || quoted)
        {
            spdlog::info("{} / {} is supported, processing", base, rel);
            this->dispatcher_.trigger<start_fetching_new_ohlc_data>(is_a_reset);
            atomic_dex::ohlc_request req{base, rel};
            if (quoted)
            {
                //! Quoted
                req.base_asset  = rel;
                req.quote_asset = base;
            }

            atomic_dex::async_rpc_ohlc_get_data(std::move(req))
                .then([this, quoted = quoted, is_a_reset](web::http::http_response resp) {
                    auto answer = atomic_dex::ohlc_answer_from_async_resp(resp);
                    if (answer.result.has_value())
                    {
                        m_current_ohlc_data = answer.result.value().raw_result;
                        this->updating_quote_and_average(quoted);
                        this->dispatcher_.trigger<refresh_ohlc_needed>(is_a_reset);
                    }
                    spdlog::error("http error: {}", answer.error.value_or("dummy"));
                })
                .then([](pplx::task<void> previous_task) {
                    try
                    {
                        previous_task.wait(); // or get(), same difference
                    }
                    catch (const std::exception& e)
                    {
                        spdlog::trace("ppl task error: {}", e.what());
                    }
                });
            ;

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
    cex_prices_provider::reverse_ohlc_data(nlohmann::json& cur_range) noexcept
    {
        cur_range["open"]         = 1 / cur_range.at("open").get<double>();
        cur_range["high"]         = 1 / cur_range.at("high").get<double>();
        cur_range["low"]          = 1 / cur_range.at("low").get<double>();
        cur_range["close"]        = 1 / cur_range.at("close").get<double>();
        auto volume               = cur_range.at("volume").get<double>();
        cur_range["volume"]       = cur_range["quote_volume"];
        cur_range["quote_volume"] = volume;
    }

    nlohmann::json
    cex_prices_provider::get_all_ohlc_data() noexcept
    {
        return *m_current_ohlc_data;
    }

    void
    cex_prices_provider::updating_quote_and_average(bool is_quoted)
    {
        nlohmann::json ohlc_data                  = *this->m_current_ohlc_data;
        auto           add_moving_average_functor = [](nlohmann::json& current_item, std::size_t idx, const std::vector<double>& sums, std::size_t num) {
            int real_num  = num;
            int first_idx = static_cast<int>(idx) - real_num;
            if (first_idx < 0)
            {
                first_idx = 0;
                num       = idx;
            }

            if (num == 0)
            {
                current_item["ma_" + std::to_string(real_num)] = current_item.at("open").get<double>();
            }
            else
            {
                current_item["ma_" + std::to_string(real_num)] = static_cast<double>(sums.at(idx) - sums.at(first_idx)) / num;
            }
        };

        for (auto&& [key, value]: ohlc_data.items())
        {
            std::size_t         idx = 0;
            std::vector<double> sums;
            for (auto&& cur_range: value)
            {
                if (is_quoted)
                {
                    this->reverse_ohlc_data(cur_range);
                }
                if (idx == 0)
                {
                    sums.emplace_back(cur_range.at("open").get<double>());
                }
                else
                {
                    sums.emplace_back(cur_range.at("open").get<double>() + sums[idx - 1]);
                }
                add_moving_average_functor(cur_range, idx, sums, 20);
                add_moving_average_functor(cur_range, idx, sums, 50);
                ++idx;
            }
        }
        this->m_current_ohlc_data = ohlc_data;
    }

    void
    cex_prices_provider::update_ohlc() noexcept
    {
        spdlog::info("fetching ohlc value");
        auto [base, rel] = m_current_orderbook_ticker_pair;
        if (not base.empty() && not rel.empty() && m_mm2_instance.is_orderbook_thread_active())
        {
            process_ohlc(base, rel);
        }
        else
        {
            spdlog::info("Nothing to achieve, sleeping");
        }
    }
} // namespace atomic_dex