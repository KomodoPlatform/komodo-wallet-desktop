#pragma once

namespace atomic_dex
{
    //! Possible front end actions
    enum class action
    {
        refresh_enabled_coin             = 0,
        refresh_update_status            = 1,
        post_process_orders_finished     = 2,
        post_process_swaps_finished      = 3,
    };

    inline constexpr std::size_t g_max_actions_size{128};
} // namespace atomic_dex