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

#include <doctest/doctest.h>

//! SDK Headers
#include "antara/gaming/timer/time.step.hpp" ///< time_step

namespace antara::gaming::timer::tests
{
    TEST_SUITE("timestep tests")
    {
        time_step timestep;

        TEST_CASE("get interpolation")
        {
            CHECK_EQ(0.f, timestep.get_interpolation());
        }

        TEST_CASE("start timer")
        {
            timestep.start();
        }

        TEST_CASE("start frame")
        {
            timestep.start_frame();
        }

        TEST_CASE("perform update")
        {
            timestep.perform_update();
        }

        TEST_CASE("is update required")
        {
            CHECK_FALSE(timestep.is_update_required());
        }

        TEST_CASE("get fixed delta time")
        {
            CHECK_GT(time_step::get_fixed_delta_time(), 0.0f);
        }

        TEST_CASE("change delta time")
        {
            time_step::change_tps(_120tps_dt);
            CHECK_GT(time_step::get_fixed_delta_time(), 0.0f);
            time_step::change_tps(_144tps_dt);
            CHECK_GT(time_step::get_fixed_delta_time(), 0.0f);
        }
    }
} // namespace antara::gaming::timer::tests