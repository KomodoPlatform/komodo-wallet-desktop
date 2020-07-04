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

namespace atomic_dex
{
    using mm2_started          = entt::tag<"mm2_started"_hs>;
    using gui_enter_trading    = entt::tag<"gui_enter_trading"_hs>;
    using gui_leave_trading    = entt::tag<"gui_leave_trading"_hs>;
    using mm2_initialized      = entt::tag<"mm2_running_and_enabling"_hs>;
    using enabled_coins_event  = entt::tag<"gui_enabled_coins"_hs>;
    using change_ticker_event  = entt::tag<"gui_change_ticker"_hs>;
    using tx_fetch_finished    = entt::tag<"gui_tx_fetch_finished"_hs>;
    using refresh_order_needed = entt::tag<"gui_refresh_order_needed"_hs>;
    using refresh_ohlc_needed  = entt::tag<"gui_refresh_ohlc_needed"_hs>;

    struct coin_enabled
    {
        std::string ticker;
    };

    struct coin_disabled
    {
        std::string ticker;
    };

    struct orderbook_refresh
    {
        std::string base;
        std::string rel;
    };
} // namespace atomic_dex
