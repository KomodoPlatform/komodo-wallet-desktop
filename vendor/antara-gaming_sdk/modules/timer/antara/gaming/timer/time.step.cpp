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

//! C System Headers
#include <cmath> ///< std::round

//! SDK Headers
#include "antara/gaming/timer/time.step.hpp"

namespace antara::gaming::timer
{
    //! Static member initialization
    std::chrono::nanoseconds time_step::tps_dt = _60tps_dt;
    std::chrono::nanoseconds time_step::lag_   = 0ns;

    float       time_step::fps_time_sum_      = 0.0f;
    int         time_step::fps_capture_count_ = 0;
    std::string time_step::fps_str_           = "";
    using clock                               = std::chrono::steady_clock;
    clock::time_point time_step::start_       = clock::now();
    float             time_step::fixed_delta_time{std::chrono::duration<float, std::ratio<1>>(tps_dt).count()};
} // namespace antara::gaming::timer

namespace antara::gaming::timer
{
    void
    time_step::start() 
    {
        start_ = clock::now();
    }

    void
    time_step::start_frame() 
    {
        auto deltaTime = clock::now() - start_;
        start_         = clock::now();
        lag_ += std::chrono::duration_cast<std::chrono::nanoseconds>(deltaTime);

        float elapsed_time = std::chrono::duration<float, std::ratio<1>>(deltaTime).count();
        fps_time_sum_ += elapsed_time;
        ++fps_capture_count_;
        if (fps_time_sum_ > fps_average_every_seconds_)
        {
            // Calculate average rounded fps
            const float avg_fps = std::round(1 / (fps_time_sum_ / fps_capture_count_));

            // Reset
            fps_time_sum_      = 0.0f;
            fps_capture_count_ = 0;

            // Set string
            fps_str_ = std::to_string(avg_fps);
        }
    }

    bool
    time_step::is_update_required() const 
    {
        return lag_ >= tps_dt;
    }

    void
    time_step::perform_update() 
    {
        lag_ -= tps_dt;
    }

    void
    time_step::change_tps(std::chrono::nanoseconds new_tps_rate)
    {
        tps_dt           = new_tps_rate;
        fixed_delta_time = std::chrono::duration<float, std::ratio<1>>(tps_dt).count();
    }

    float
    time_step::get_fixed_delta_time() 
    {
        return fixed_delta_time;
    }

    float
    time_step::get_interpolation() const 
    {
        return std::chrono::duration<float, std::ratio<1>>(lag_).count() / std::chrono::duration<float, std::ratio<1>>(tps_dt).count();
    }

    void
    time_step::reset_lag() 
    {
        lag_ = std::chrono::nanoseconds(0);
        start();
    }
} // namespace antara::gaming::timer