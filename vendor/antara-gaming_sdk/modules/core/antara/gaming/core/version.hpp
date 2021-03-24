/******************************************************************************
 * Copyright � 2013-2021 The Komodo Platform Developers.                      *
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

namespace antara::gaming
{
    /**
     * @fn constexpr const char *version() 
     * @brief Function that allows us to find the current version of the SDK
     * @return the current version of the SDK as a `const char *`
     *
     *
     *
     * Example:
     * ```cpp
     *          #include <iostream>
     *          #include <antara/gaming/core/version.hpp>
     *
     *          void print_version() {
     *              std::cout << antara::gaming::version() << std::endl;
     *          }
     * ```
     *
     *
       \verbatim embed:rst
        .. note::

           The result of this function can be deduced at compile-time.
       \endverbatim
    */
    constexpr const char*
    version() 
    {
        return "0.0.1";
    }
} // namespace antara::gaming
