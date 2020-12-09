#pragma once

namespace atomic_dex
{
    //! Possible front end actions
    enum class action
    {
        refresh_enabled_coin         = 0,
        post_process_orders_finished = 1,
        post_process_swaps_finished  = 2,
    };

    inline constexpr std::size_t g_max_actions_size{128};
} // namespace atomic_dex
