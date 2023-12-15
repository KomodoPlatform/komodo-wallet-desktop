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
#include <doctest/doctest.h>

namespace antara::gaming::event::tests
{
    TEST_SUITE("quit game event")
    {
        TEST_CASE("default constructor")
        {
            quit_game q_event{};
            CHECK_EQ(q_event.return_value_, 0);
        }

        TEST_CASE("constructor with a value")
        {
            quit_game q_event{-1};
            CHECK_EQ(q_event.return_value_, -1);
        }
    }
} // namespace antara::gaming::event::tests