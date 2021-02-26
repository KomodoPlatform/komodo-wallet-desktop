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

#include "antara/gaming/event/fatal.error.hpp"
#include <doctest/doctest.h>

namespace antara::gaming::event::tests
{
    TEST_SUITE("fatal error")
    {
        TEST_CASE("construct from an error code")
        {
            fatal_error fatal_error_event{std::make_error_code(std::errc::result_out_of_range)};
            CHECK_EQ(fatal_error_event.ec_.value(), static_cast<int>(std::errc::result_out_of_range));
        }
    }
} // namespace antara::gaming::event::tests