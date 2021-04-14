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

//! SDK Headers
#ifdef _WIN32

#    include "antara/gaming/core/details/windows/open.url.browser.hpp"

#elif __APPLE__ || __linux__

#    include "antara/gaming/core/details/posix/open.url.browser.hpp"

#endif

namespace antara::gaming::core
{
    inline void
    open_url_browser(const std::string& url) 
    {
        details::open_url_browser(url);
    }
} // namespace antara::gaming::core