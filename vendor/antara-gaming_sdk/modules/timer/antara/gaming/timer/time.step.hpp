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

#pragma once

//! C++ System Headers
#include <chrono> ///< std::chrono::nanoseconds|steady_clock|duration|duration_cast
#include <string> ///< std::string, std::to_string

//! SDK Headers
#include "antara/gaming/timer/fps.hpp"

namespace antara::gaming::timer
{
    class time_step
    {
        //! Private typedefs
        using clock = std::chrono::steady_clock;

        //! Private fields
        static std::chrono::nanoseconds tps_dt;
        static float                    fixed_delta_time;
        static std::chrono::nanoseconds lag_;
        static clock::time_point        start_;
        static constexpr float          fps_average_every_seconds_{1.0f};
        static float                    fps_time_sum_;
        static int                      fps_capture_count_;

      public:
        //! Public static functions
        static void start() ;

        static void start_frame() ;

        static void perform_update() ;

        static void change_tps(std::chrono::nanoseconds new_tps_rate);

        static float get_fixed_delta_time() ;

        static void reset_lag() ;

        //! Public member functions
        [[nodiscard]] bool is_update_required() const ;

        [[nodiscard]] float get_interpolation() const ;

        //! Public Fields
        static std::string fps_str_;
    };
} // namespace antara::gaming::timer