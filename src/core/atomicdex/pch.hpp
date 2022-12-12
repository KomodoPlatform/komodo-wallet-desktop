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

#include <cstddef>

constexpr std::size_t operator"" _sz(unsigned long long n) { return n; }

//! Boost Headers
#include <boost/algorithm/string/trim.hpp>

//! Prerequisites Headers
#include "atomicdex/utilities/log.prerequisites.hpp"

namespace antara::gaming
{
}

namespace ag = antara::gaming;
