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

#pragma once

//! Project Headers
#include "atomic.dex.cfg.hpp"
#include "atomic.dex.events.hpp"
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.api.hpp"

namespace atomic_dex
{
    namespace ag = antara::gaming;

    class coinpaprika_provider final : public ag::ecs::pre_update_system<coinpaprika_provider>
    {
      public:
        using t_ticker_infos_registry      = t_concurrent_reg<std::string, t_ticker_info_answer>;
        using t_ticker_historical_registry = t_concurrent_reg<std::string, t_ticker_historical_answer>;

      private:
        //! Typedefs
        using t_providers_registry = t_concurrent_reg<std::string, std::string>;

        //! Private fields
        mm2&                         m_mm2_instance;                 ///< represent the MM2 instance
        t_providers_registry         m_usd_rate_providers{};         ///< USD Rate Providers
        t_ticker_infos_registry      m_ticker_infos_registry{};      ///< Ticker info registry, key is the ticker
        t_ticker_historical_registry m_ticker_historical_registry{}; ///< Ticker historical registry, key is the ticker

      public:
        //! Constructor
        coinpaprika_provider(entt::registry& registry, mm2& mm2_instance);

        //! Destructor
        ~coinpaprika_provider() noexcept final;

        //! Public API

        //! Get the rate conversion for the given fiat.
        std::string get_rate_conversion(const std::string& fiat, const std::string& ticker, std::error_code& ec) const noexcept;

        //! Get the ticker informations.
        t_ticker_info_answer get_ticker_infos(const std::string& ticker) const noexcept;

        //! Get the ticker informations.
        t_ticker_historical_answer get_ticker_historical(const std::string& ticker) const noexcept;

        //! Events

        //! Event that occur when the mm2 process is launched correctly.
        void on_mm2_started(const mm2_started& evt) noexcept;

        //! Event that occur when a coin is correctly enabled.
        void on_coin_enabled(const coin_enabled& evt) noexcept;

        //! Event that occur when a coin is correctly disabled.
        void on_coin_disabled(const coin_disabled& evt) noexcept;


        //! Override ag::ecs functions
        void update() noexcept final;

        //! Update all the data of the provider in an async way
        void update_ticker_and_provider();
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::coinpaprika_provider))
