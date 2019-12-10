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

#include <entt/entity/helper.hpp>

namespace atomic_dex {
    using mm2_started = entt::tag<"mm2_started"_hs>;
    using gui_enter_trading = entt::tag<"gui_enter_trading"_hs>;
    using gui_leave_trading = entt::tag<"gui_leave_trading"_hs>;

    struct coin_enabled {
        std::string ticker;
    };
    struct orderbook_refresh {
        std::string base;
        std::string rel;
    };
}