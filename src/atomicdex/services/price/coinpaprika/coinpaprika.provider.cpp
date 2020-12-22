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

//! Project Headers
#include "atomicdex/services/price/coinpaprika/coinpaprika.provider.hpp"
#include "src/atomicdex/constants/http.code.hpp"

namespace
{
    //! Using namespace
    using namespace std::chrono_literals;
    using namespace atomic_dex;
    using namespace atomic_dex::coinpaprika::api;
    constexpr std::uint16_t g_pending_init_tasks_limit = 3;
} // namespace

namespace atomic_dex
{
    namespace bm = boost::multiprecision;


    void
    coinpaprika_provider::process_async_price_converter(
        const t_price_converter_request& request, coin_config current_coin, std::shared_ptr<std::atomic_uint16_t> idx, std::uint16_t target_size,
        std::vector<std::string> tickers)
    {
        async_price_converter(request)
            .then([this, request, current_coin, idx, target_size, tickers](web::http::http_response resp) {
                auto answer = process_generic_resp<price_converter_answer>(resp);
                if (answer.rpc_result_code == e_http_code::too_many_requests)
                {
                    std::this_thread::sleep_for(1s);
                    process_async_price_converter(request, current_coin, idx, target_size, tickers);
                }
                else
                {
                    std::string price = "0.00";
                    if (answer.raw_result.find("error") == std::string::npos)
                    {
                        if (not answer.price.empty())
                        {
                            price = answer.price;
                        }
                    }
                    {
                        std::unique_lock lock(m_provider_mutex);
                        m_usd_rate_providers[current_coin.ticker] = price;
                    }
                    if (idx != nullptr)
                    {
                        auto cur = idx->fetch_add(1) + 1;
                        if (not tickers.empty()) ///< Initialization
                        {
                            // SPDLOG_DEBUG("cur: {}, target size: {}, remaining before adding in the model: {}", cur, target_size, target_size - cur);
                            if (cur == target_size)
                            {
                                this->dispatcher_.trigger<atomic_dex::coin_fully_initialized>(tickers);
                            }
                        }
                        else ///< update
                        {
                            // SPDLOG_DEBUG("cur: {}, target size: {}, remaining before updating rates: {}", cur, target_size, target_size - cur);
                            if (cur == target_size)
                            {
                                this->dispatcher_.trigger<fiat_rate_updated>("");
                            }
                        }
                    }
                }
            })
            .then(&handle_exception_pplx_task);
    }

    void
    coinpaprika_provider::process_provider(
        const atomic_dex::coin_config& current_coin, std::shared_ptr<std::atomic_uint16_t> idx, std::uint16_t target_size, std::vector<std::string> tickers)
    {
        const price_converter_request request{.base_currency_id = current_coin.coinpaprika_id, .quote_currency_id = "usd-us-dollars"};
        process_async_price_converter(request, current_coin, std::move(idx), target_size, tickers);
    }

    void
    coinpaprika_provider::process_async_ticker_infos(
        const t_ticker_infos_request& request, const atomic_dex::coin_config& current_coin, std::shared_ptr<std::atomic_uint16_t> idx,
        std::uint16_t target_size, std::vector<std::string> tickers)
    {
        auto answer_functor = [this, request, current_coin, idx, target_size, tickers](web::http::http_response resp) {
            auto answer = process_generic_resp<ticker_info_answer>(resp);
            if (answer.rpc_result_code == e_http_code::too_many_requests)
            {
                std::this_thread::sleep_for(1s);
                process_async_ticker_infos(request, current_coin, std::move(idx), target_size, tickers);
            }
            else
            {
                // reg.insert_or_assign(current_coin.ticker, answer);
                {
                    std::unique_lock lock(m_ticker_infos_mutex);
                    m_ticker_infos_registry[current_coin.ticker] = answer;
                }
                if (idx != nullptr)
                {
                    auto cur = idx->fetch_add(1) + 1;
                    // SPDLOG_DEBUG("cur: {}, target size: {}, remaining before adding in the model: {}", cur, target_size, target_size - cur);
                    if (cur == target_size)
                    {
                        this->dispatcher_.trigger<atomic_dex::coin_fully_initialized>(tickers);
                    }
                }
            }
        };

        async_ticker_info(request).then(answer_functor).then(&handle_exception_pplx_task);
    }

    void
    coinpaprika_provider::process_ticker_infos(
        const coin_config& current_coin, std::shared_ptr<std::atomic_uint16_t> idx, std::uint16_t target_size, std::vector<std::string> tickers)
    {
        const ticker_infos_request request{.ticker_currency_id = current_coin.coinpaprika_id, .ticker_quotes = {"USD", "EUR", "BTC"}};
        process_async_ticker_infos(request, current_coin, std::move(idx), target_size, tickers);
    }

    void
    coinpaprika_provider::process_async_ticker_historical(
        const t_ticker_historical_request& request, const atomic_dex::coin_config& current_coin, t_ref_count_idx idx, std::uint16_t target_size,
        std::vector<std::string> tickers)
    {
        async_ticker_historical(request)
            .then([this, request, current_coin, idx, target_size, tickers](web::http::http_response resp) {
                auto answer = process_generic_resp<ticker_historical_answer>(resp);
                if (answer.rpc_result_code == e_http_code::too_many_requests)
                {
                    std::this_thread::sleep_for(1s);
                    process_async_ticker_historical(request, current_coin, std::move(idx), target_size, tickers);
                }
                else
                {
                    if (answer.raw_result.find("error") == std::string::npos)
                    {
                        std::unique_lock lock(m_ticker_historical_mutex);
                        this->m_ticker_historical_registry[current_coin.ticker] = answer;
                    }

                    if (idx != nullptr)
                    {
                        auto cur = idx->fetch_add(1) + 1;
                        // SPDLOG_DEBUG("cur: {}, target size: {}, remaining before adding in the model: {}", cur, target_size, target_size - cur);
                        if (cur == target_size)
                        {
                            this->dispatcher_.trigger<atomic_dex::coin_fully_initialized>(tickers);
                        }
                    }
                }
            })
            .then(&handle_exception_pplx_task);
    }

    void
    coinpaprika_provider::process_ticker_historical(
        const coin_config& current_coin, t_ref_count_idx idx, std::uint16_t target_size, std::vector<std::string> tickers)
    {
        if (current_coin.coinpaprika_id == "test-coin")
        {
            if (idx != nullptr)
            {
                auto cur = idx->fetch_add(1) + 1;
                // SPDLOG_DEBUG("cur: {}, target size: {}, remaining before adding in the model: {}", cur, target_size, target_size - cur);
                if (cur == target_size)
                {
                    this->dispatcher_.trigger<atomic_dex::coin_fully_initialized>(tickers);
                }
            }
            return;
        }
        const ticker_historical_request request{.ticker_currency_id = current_coin.coinpaprika_id, .interval = "2h"};
        process_async_ticker_historical(request, current_coin, idx, target_size, tickers);
    }

    coinpaprika_provider::coinpaprika_provider(entt::registry& registry, mm2_service& mm2_instance) : system(registry), m_mm2_instance(mm2_instance)
    {
        disable();
        dispatcher_.sink<mm2_started>().connect<&coinpaprika_provider::on_mm2_started>(*this);
        dispatcher_.sink<coin_enabled>().connect<&coinpaprika_provider::on_coin_enabled>(*this);
        dispatcher_.sink<coin_disabled>().connect<&coinpaprika_provider::on_coin_disabled>(*this);
    }

    void
    coinpaprika_provider::update() noexcept
    {
    }

    coinpaprika_provider::~coinpaprika_provider() noexcept
    {
        dispatcher_.sink<mm2_started>().disconnect<&coinpaprika_provider::on_mm2_started>(*this);
        dispatcher_.sink<coin_enabled>().disconnect<&coinpaprika_provider::on_coin_enabled>(*this);
        dispatcher_.sink<coin_disabled>().disconnect<&coinpaprika_provider::on_coin_disabled>(*this);
    }

    void
    coinpaprika_provider::on_mm2_started([[maybe_unused]] const mm2_started& evt) noexcept
    {
        update_ticker_and_provider();
    }

    void
    coinpaprika_provider::update_ticker_and_provider()
    {
        t_coins coins = m_mm2_instance.get_enabled_coins();

        auto idx{std::make_shared<std::atomic_uint16_t>(0)};
        auto target_size = coins.size();
        for (auto&& current_coin: coins)
        {
            if (current_coin.coinpaprika_id == "test-coin")
            {
                uint16_t cur = idx->fetch_add(1) + 1;
                if (cur == target_size)
                {
                    dispatcher_.trigger<fiat_rate_updated>("");
                }
                continue;
            }
            process_ticker_infos(current_coin);
            process_ticker_historical(current_coin);
            process_provider(current_coin, idx, target_size, {});
        }
    }

    void
    coinpaprika_provider::on_coin_enabled(const coin_enabled& evt) noexcept
    {
        SPDLOG_INFO("{} enabled, retrieve coinpaprika infos", fmt::format("{}", fmt::join(evt.tickers, ", ")));
        auto idx{std::make_shared<std::atomic_uint16_t>(0)};
        auto target_size = evt.tickers.size() * g_pending_init_tasks_limit;
        for (auto&& ticker: evt.tickers)
        {
            const auto config = m_mm2_instance.get_coin_info(ticker);
            if (config.coinpaprika_id != "test-coin")
            {
                process_provider(config, idx, target_size, evt.tickers);
                process_ticker_infos(config, idx, target_size, evt.tickers);
                process_ticker_historical(config, idx, target_size, evt.tickers);
            }
            else
            {
                std::uint16_t cur = idx->fetch_add(g_pending_init_tasks_limit) + g_pending_init_tasks_limit;
                // SPDLOG_DEBUG("cur: {}, target size: {}, remaining before adding in the model: {}", cur, target_size, target_size - cur);
                if (cur == target_size)
                {
                    this->dispatcher_.trigger<coin_fully_initialized>(evt.tickers);
                }
            }
        }
    }

    void
    coinpaprika_provider::on_coin_disabled(const coin_disabled& evt) noexcept
    {
        SPDLOG_INFO("{} disabled, removing from paprika provider", evt.ticker);
        std::unique_lock lock(m_provider_mutex);
        m_usd_rate_providers.erase(evt.ticker);
    }

    template <typename TAnswer, typename TRegistry, typename TLockable>
    TAnswer
    coinpaprika_provider::get_infos(const std::string& ticker, const TRegistry& registry, TLockable& mutex) const noexcept
    {
        std::shared_lock lock(mutex);
        const auto       it = registry.find(ticker);
        return it != registry.cend() ? it->second : TAnswer{};
    }

    std::string
    coinpaprika_provider::get_rate_conversion(const std::string& ticker) const noexcept
    {
        const auto res = get_infos<std::string>(ticker, m_usd_rate_providers, m_provider_mutex);
        return res.empty() ? "0.00" : res;
    }

    t_ticker_info_answer
    coinpaprika_provider::get_ticker_infos(const std::string& ticker) const noexcept
    {
        return get_infos<t_ticker_info_answer>(ticker, m_ticker_infos_registry, m_ticker_infos_mutex);
    }

    t_ticker_historical_answer
    coinpaprika_provider::get_ticker_historical(const std::string& ticker) const noexcept
    {
        return get_infos<t_ticker_historical_answer>(ticker, m_ticker_historical_registry, m_ticker_historical_mutex);
    }
} // namespace atomic_dex
