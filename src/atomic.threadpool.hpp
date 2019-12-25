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

//! Project Headers
#include "atomic.dex.utilities.hpp"

inline constexpr std::size_t g_max_threads = 8ull;

//! Private Singleton
static thread_pool&
get_threadpool()
{
    static thread_pool thread_pool(g_max_threads);
    return thread_pool;
}

//! Public API
namespace atomic_dex
{
    template <typename F, typename... Args>
    static auto
    spawn(F&& f, Args&&... args) noexcept
    {
        return get_threadpool().enqueue(std::forward<F>(f), std::forward<Args>(args)...);
    }
} // namespace atomic_dex