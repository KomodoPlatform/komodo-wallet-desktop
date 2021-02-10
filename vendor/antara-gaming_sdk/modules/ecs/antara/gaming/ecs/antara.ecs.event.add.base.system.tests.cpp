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

#include "antara/gaming/ecs/event.add.base.system.hpp"
#include <doctest/doctest.h>

namespace antara::gaming::ecs::tests
{
    TEST_SUITE("test event add base system")
    {
        TEST_CASE("default constructor")
        {
            antara::gaming::ecs::event::add_base_system evt{};
        }
    }
} // namespace antara::gaming::ecs::tests