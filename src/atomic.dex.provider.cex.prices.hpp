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

#include "atomic.dex.pch.hpp"

//! Project header
#include "atomic.dex.mm2.hpp"

namespace atomic_dex
{
    namespace ag = antara::gaming;

    class cex_prices_provider final : public ag::ecs::pre_update_system<cex_prices_provider>
    {
        //! Private fields
        [[maybe_unused]] mm2& m_mm2_instance;

        //! OHLC Related
        std::pair<std::string, std::string> m_current_orderbook_ticker_pair;
        std::mutex                          m_orderbook_tickers_data_mutex;
        std::array<std::string, 2>          m_supported_pair{"kmd-btc", "btc-usdt"};

        nlohmann::json     m_current_ohlc_data;
        mutable std::mutex m_ohlc_data_mutex;

        //! Threads
        std::thread  m_provider_ohlc_fetcher_thread;
        timed_waiter m_provider_thread_timer;

      public:
        //! Constructor
        cex_prices_provider(entt::registry& registry, mm2& mm2_instance);

        //! Destructor
        ~cex_prices_provider() noexcept final;

        // Override
        void update() noexcept override;

        //! Process OHLC http rest request
        bool process_ohlc(const std::string& base, const std::string& rel) noexcept;

        //! Return true if json ohlc data is not empty, otherwise return false
        bool is_ohlc_data_available() const noexcept;

        bool is_pair_supported(const std::string& base, const std::string& rel) const noexcept;

        //! Event that occur when the mm2 process is launched correctly.
        void on_mm2_started(const mm2_started& evt) noexcept;

        nlohmann::json get_ohlc_data(const std::string& range) noexcept;

        //! Event that occur when the ticker pair is changed in the front end
        void on_current_orderbook_ticker_pair_changed(const orderbook_refresh& evt) noexcept;
        ;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::cex_prices_provider))