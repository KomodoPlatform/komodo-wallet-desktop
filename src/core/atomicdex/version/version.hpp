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

#pragma once

namespace atomic_dex
{
    constexpr const char*
    get_version()
    {
        return "0.8.2-beta";
    }

    constexpr int
    get_num_version() noexcept
    {
        return 82;
    }

    constexpr const char*
    get_raw_version()
    {
        return "0.8.2";
    }

    constexpr const char*
    get_precedent_raw_version()
    {
        return "0.8.1";
    }
} // namespace atomic_dex
