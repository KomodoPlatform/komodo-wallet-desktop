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

#pragma once

//! STD
#include <shared_mutex>

//! Deps
#include <antara/gaming/ecs/system.manager.hpp>

//! Project Headers
#include "atomicdex/api/coinpaprika/coinpaprika.hpp"
#include "atomicdex/events/events.hpp"

namespace atomic_dex
{
    namespace ag = antara::gaming;

    class coinpaprika_provider final : public ag::ecs::pre_update_system<coinpaprika_provider>
    {
        //! Typedefs
        using t_ref_count_idx              = std::shared_ptr<std::atomic_uint16_t>;
        using t_providers_registry         = std::unordered_map<std::string, t_price_converter_answer>;
        using t_ticker_infos_registry      = std::unordered_map<std::string, t_ticker_info_answer>;
        using t_ticker_historical_registry = std::unordered_map<std::string, t_ticker_historical_answer>;

        //! Private fields

        //! ag::system_manager
        ag::ecs::system_manager& m_system_manager;

        //! Containers
        t_providers_registry         m_usd_rate_providers{};         ///< USD Rate Providers
        t_ticker_infos_registry      m_ticker_infos_registry{};      ///< Ticker info registry, key is the ticker
        t_ticker_historical_registry m_ticker_historical_registry{}; ///< Ticker historical registry, key is the ticker

        //! Mutexes
        mutable std::shared_mutex m_ticker_historical_mutex;
        mutable std::shared_mutex m_ticker_infos_mutex;
        mutable std::shared_mutex m_provider_mutex;

        //! Private member functions
        void verify_idx(t_ref_count_idx idx = nullptr, uint16_t target_size = 0, const std::vector<std::string>& tickers = {});

        //! Private templated member functions
        template <typename TAnswer, typename TRegistry, typename TLockable>
        TAnswer get_infos(const std::string& ticker, const TRegistry& registry, TLockable& mutex) const noexcept;

        template <typename TContainer, typename TAnswer, typename... Args>
        void generic_post_verification(std::shared_mutex& mtx, TContainer& container, std::string&& ticker, TAnswer&& answer, Args... args);

        template <typename TAnswer, typename TRequest, typename TExecutorFunctor, typename... Args>
        void generic_rpc_paprika_process(
            const TRequest& request, std::string ticker, std::shared_mutex& mtx, std::unordered_map<std::string, TAnswer>& container,
            TExecutorFunctor&& functor, Args... args);

        //! Private RPC Call
        template <typename... Args>
        void process_provider(const coin_config& current_coin, Args... args);
        template <typename... Args>
        void process_ticker_infos(const coin_config& current_coin, Args... args);
        template <typename... Args>
        void process_ticker_historical(const coin_config& current_coin, Args... args);

      public:
        //! Deleted operation
        coinpaprika_provider(coinpaprika_provider& other) = delete;
        coinpaprika_provider(coinpaprika_provider&& other) = delete;
        coinpaprika_provider& operator=(coinpaprika_provider& other) = delete;
        coinpaprika_provider& operator=(coinpaprika_provider&& other) = delete;

        //! Constructor
        coinpaprika_provider(entt::registry& registry, ag::ecs::system_manager& system_manager) noexcept;

        //! Destructor
        ~coinpaprika_provider() noexcept final;

        ///< Public API

        //! Update all the data of the provider in an async way
        void update_ticker_and_provider();

        //! Get the rate conversion for the given fiat.
        [[nodiscard]] std::string get_rate_conversion(const std::string& ticker) const noexcept;

        //! Get the ticker informations.
        [[nodiscard]] t_ticker_info_answer get_ticker_infos(const std::string& ticker) const noexcept;

        //! Get the ticker informations.
        [[nodiscard]] t_ticker_historical_answer get_ticker_historical(const std::string& ticker) const noexcept;

        ///< Events

        //! Event that occur when the mm2 process is launched correctly.
        void on_mm2_started(const mm2_started& evt) noexcept;

        //! Event that occur when a coin is correctly enabled.
        void on_coin_enabled(const coin_enabled& evt) noexcept;

        //! Event that occur when a coin is correctly disabled.
        void on_coin_disabled(const coin_disabled& evt) noexcept;

        //! Override ag::system functions
        void update() noexcept final;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::coinpaprika_provider))