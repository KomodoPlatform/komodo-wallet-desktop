/******************************************************************************
 * Copyright © 2013-2024 The Komodo Platform Developers.                      *
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

#include "antara/gaming/event/quit.game.hpp"
#include "antara/gaming/event/start.game.hpp"
#include "antara/gaming/event/type.traits.hpp"
#include <doctest/doctest.h>

namespace antara::gaming::event::tests
{
    TEST_SUITE("event type traits")
    {
        TEST_CASE("invoker")
        {
            static_assert(has_constructor_arg_type_v<event::quit_game>);
            static_assert(!has_constructor_arg_type_v<event::start_game>);
        }
    }
} // namespace antara::gaming::event::tests