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
#include <utility> ///< std::declval

//! Dependencies Headers
#include <meta/detection/detection.hpp> ///< doom::meta::is_detected

namespace antara::gaming::event
{
    //! Typedefs
    template <typename T>
    using constructor_arg_t = decltype(std::declval<T&>().invoker);

    //! Meta-functions
    template <typename T>
    inline constexpr bool has_constructor_arg_type_v = doom::meta::is_detected_v<constructor_arg_t, T>;
} // namespace antara::gaming::event