/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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
#include "atomicdex/constants/http.code.hpp"
#include "atomicdex/pages/qt.portfolio.page.hpp"
#include "atomicdex/services/price/coinpaprika/coinpaprika.provider.hpp"

namespace
{
    //! Using namespace
    using namespace std::chrono_literals;
    using namespace atomic_dex::coinpaprika::api;

    //! Constants
    constexpr std::uint16_t g_pending_init_tasks_limit = 3;
} // namespace

//! Constructor/Destructor
namespace atomic_dex
{
    coinpaprika_provider::coinpaprika_provider(entt::registry& registry, ag::ecs::system_manager& system_manager) noexcept :
        system(registry), m_system_manager(system_manager)
    {
        SPDLOG_INFO("coinpaprika_provider created");
        disable();
        dispatcher_.sink<mm2_started>().connect<&coinpaprika_provider::on_mm2_started>(*this);
        dispatcher_.sink<coin_enabled>().connect<&coinpaprika_provider::on_coin_enabled>(*this);
        dispatcher_.sink<coin_disabled>().connect<&coinpaprika_provider::on_coin_disabled>(*this);
    }

    coinpaprika_provider::~coinpaprika_provider() noexcept
    {
        SPDLOG_INFO("coinpaprika_provider destroyed");
        dispatcher_.sink<mm2_started>().disconnect<&coinpaprika_provider::on_mm2_started>(*this);
        dispatcher_.sink<coin_enabled>().disconnect<&coinpaprika_provider::on_coin_enabled>(*this);
        dispatcher_.sink<coin_disabled>().disconnect<&coinpaprika_provider::on_coin_disabled>(*this);
    }
} // namespace atomic_dex

//! Private Generics
namespace atomic_dex
{
    template <typename TAnswer, typename TRegistry, typename TLockable>
    TAnswer
    coinpaprika_provider::get_infos(const std::string& ticker, const TRegistry& registry, TLockable& mutex) const noexcept
    {
        std::shared_lock lock(mutex);
        const auto       it = registry.find(ticker);
        return it != registry.cend() ? it->second : TAnswer{};
    }
} // namespace atomic_dex

//! RPC Generics
namespace atomic_dex
{
    void
    coinpaprika_provider::verify_idx(t_ref_count_idx idx, uint16_t target_size, const std::vector<std::string>& tickers)
    {
        if (idx != nullptr)
        {
            const auto cur = idx->fetch_add(1) + 1;
            // SPDLOG_DEBUG("cur: {}, target size: {}, remaining before adding in the model: {}", cur, target_size, target_size - cur);
            if (cur == target_size)
            {
                if (not tickers.empty())
                {
                    dispatcher_.trigger<coin_fully_initialized>(tickers);
                }
                else
                {
                    this->dispatcher_.trigger<fiat_rate_updated>("");
                }
            }
        }
    }

    template <typename TContainer, typename TAnswer, typename... Args>
    void
    coinpaprika_provider::generic_post_verification(std::shared_mutex& mtx, TContainer& container, std::string&& ticker, TAnswer&& answer, Args... args)
    {
        {
            std::unique_lock lock(mtx);
            container.insert_or_assign(std::move(ticker), std::forward<TAnswer>(answer));
        }
        verify_idx(std::move(args)...);
    }

    template <typename TAnswer, typename TRequest, typename TExecutorFunctor, typename... Args>
    void
    coinpaprika_provider::generic_rpc_paprika_process(
        const TRequest& request, std::string ticker, std::shared_mutex& mtx, std::unordered_map<std::string, TAnswer>& container, TExecutorFunctor&& functor,
        Args... args)
    {
        const auto answer_functor = [this, &mtx, &container, functor = std::forward<TExecutorFunctor>(functor), request, ticker = std::move(ticker),
                                     ... args = std::move(args)](web::http::http_response resp) mutable {
            const auto answer = process_generic_resp<TAnswer>(resp);
            if (answer.rpc_result_code == e_http_code::too_many_requests)
            {
                std::this_thread::sleep_for(1s);
                generic_rpc_paprika_process<TAnswer>(request, std::move(ticker), mtx, container, std::forward<TExecutorFunctor>(functor), std::move(args)...);
            }
            else
            {
                generic_post_verification(mtx, container, std::move(ticker), std::move(answer), std::move(args)...);
            }
        };

        functor(request).then(answer_functor).then(&handle_exception_pplx_task);
    }
} // namespace atomic_dex

//! RPC call
namespace atomic_dex
{
    template <typename... Args>
    void
    coinpaprika_provider::process_provider(const coin_config& current_coin, Args... args)
    {
        const price_converter_request request{.base_currency_id = current_coin.coinpaprika_id, .quote_currency_id = "usd-us-dollars"};
        generic_rpc_paprika_process<t_price_converter_answer>(
            request, current_coin.ticker, m_provider_mutex, m_usd_rate_providers,
            [](auto&& request) { return async_price_converter(std::forward<decltype(request)>(request)); }, std::move(args)...);
    }

    template <typename... Args>
    void
    coinpaprika_provider::process_ticker_infos(const coin_config& current_coin, Args... args)
    {
        const ticker_infos_request request{.ticker_currency_id = current_coin.coinpaprika_id, .ticker_quotes = {"USD", "EUR", "BTC"}};
        generic_rpc_paprika_process<ticker_info_answer>(
            request, current_coin.ticker, m_ticker_infos_mutex, m_ticker_infos_registry,
            [](auto&& request) { return async_ticker_info(std::forward<decltype(request)>(request)); }, std::move(args)...);
    }

    template <typename... Args>
    void
    coinpaprika_provider::process_ticker_historical(const coin_config& current_coin, Args... args)
    {
        const ticker_historical_request request{.ticker_currency_id = current_coin.coinpaprika_id, .interval = "2h"};
        generic_rpc_paprika_process<ticker_historical_answer>(
            request, current_coin.ticker, m_ticker_historical_mutex, m_ticker_historical_registry,
            [](auto&& request) { return async_ticker_historical(std::forward<decltype(request)>(request)); }, std::move(args)...);
    }
} // namespace atomic_dex

//! System Override
namespace atomic_dex
{
    void
    coinpaprika_provider::update() noexcept
    {
    }
} // namespace atomic_dex

//! Events
namespace atomic_dex
{
    void
    coinpaprika_provider::on_mm2_started([[maybe_unused]] const mm2_started& evt) noexcept
    {
        update_ticker_and_provider();
    }

    void
    coinpaprika_provider::on_coin_enabled(const coin_enabled& evt) noexcept
    {
        SPDLOG_INFO("{} enabled, retrieve coinpaprika infos", fmt::format("{}", fmt::join(evt.tickers, ", ")));
        auto        idx{std::make_shared<std::atomic_uint16_t>(0)};
        const auto  target_size       = evt.tickers.size() * g_pending_init_tasks_limit;
        const auto* global_cfg_system = m_system_manager.get_system<portfolio_page>().get_global_cfg();
        for (auto&& ticker: evt.tickers)
        {
            const auto config = global_cfg_system->get_coin_info(ticker);
            if (config.coinpaprika_id != "test-coin")
            {
                process_provider(config, idx, target_size, evt.tickers);
                process_ticker_infos(config, idx, target_size, evt.tickers);
                process_ticker_historical(config, idx, target_size, evt.tickers);
            }
            else
            {
                const std::uint16_t cur = idx->fetch_add(g_pending_init_tasks_limit) + g_pending_init_tasks_limit; ///< Manually skip the above 3 operations
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
} // namespace atomic_dex

//! Public member functions
namespace atomic_dex
{
    void
    coinpaprika_provider::update_ticker_and_provider()
    {
        const auto coins = this->m_system_manager.get_system<portfolio_page>().get_global_cfg()->get_enabled_coins();
        auto       idx{std::make_shared<std::atomic_uint16_t>(0)};
        const auto target_size = coins.size();
        for (auto&& [_, current_coin]: coins)
        {
            if (current_coin.coinpaprika_id == "test-coin")
            {
                const std::uint16_t cur = idx->fetch_add(1) + 1;
                if (cur == target_size)
                {
                    dispatcher_.trigger<fiat_rate_updated>("");
                }
                continue;
            }
            process_ticker_infos(current_coin);
            process_ticker_historical(current_coin);
            process_provider(current_coin, idx, target_size, std::vector<std::string>{});
        }
    }

    std::string
    coinpaprika_provider::get_rate_conversion(const std::string& ticker) const noexcept
    {
        return get_infos<t_price_converter_answer>(ticker, m_usd_rate_providers, m_provider_mutex).price;
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