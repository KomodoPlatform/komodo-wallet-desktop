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

//! PCH Headers
#include "atomic.dex.pch.hpp"

//! Project Headers
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
        using t_providers_registry      = t_concurrent_reg<std::string, std::string>;
        using t_supported_fiat_registry = std::unordered_set<std::string>;

        //! Private fields
        mm2&                         m_mm2_instance;
        t_providers_registry         m_usd_rate_providers{};
        t_providers_registry         m_eur_rate_providers{};
        t_providers_registry         m_btc_rate_providers{};
        t_providers_registry         m_kmd_rate_providers{};
        t_ticker_infos_registry      m_ticker_infos_registry{};
        t_ticker_historical_registry m_ticker_historical_registry{};
        t_supported_fiat_registry    m_supported_fiat_registry{"USD", "EUR", "BTC", "KMD"};
        std::thread                  m_provider_rates_thread;
        timed_waiter                 m_provider_thread_timer;

      public:
        //! Constructor
        coinpaprika_provider(entt::registry& registry, mm2& mm2_instance);

        //! Destructor
        ~coinpaprika_provider() noexcept final;

        //! Get the rate conversion for the given fiat.
        std::string get_rate_conversion(const std::string& fiat, const std::string& ticker, std::error_code& ec, bool adjusted = false) const noexcept;

        //! Fiat can be USD or EUR
        std::string get_price_in_fiat(const std::string& fiat, const std::string& ticker, std::error_code& ec, bool skip_precision = false) const noexcept;

        //! Get the whole balance in the given fiat.
        std::string get_price_in_fiat_all(const std::string& fiat, std::error_code& ec) const noexcept;

        //! Get the price in fiat from a transaction.
        std::string get_price_in_fiat_from_tx(const std::string& fiat, const std::string& ticker, const tx_infos& tx, std::error_code& ec) const noexcept;

        //! Get the ticker informations.
        t_ticker_info_answer get_ticker_infos(const std::string& ticker) const noexcept;

        //! Get the ticker informations.
        t_ticker_historical_answer get_ticker_historical(const std::string& ticker) const noexcept;

        //! Event that occur when the mm2 process is launched correctly.
        void on_mm2_started(const mm2_started& evt) noexcept;

        //! Event that occur when a coin is correctly enabled.
        void on_coin_enabled(const coin_enabled& evt) noexcept;

        //! Event that occur when a coin is correctly disabled.
        void on_coin_disabled(const coin_disabled& evt) noexcept;

        void update() noexcept final;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::coinpaprika_provider))
