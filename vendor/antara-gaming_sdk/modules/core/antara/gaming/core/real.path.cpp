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

//! SDK Headers
#include "antara/gaming/core/real.path.hpp"

#ifdef _WIN32

#    include "antara/gaming/core/details/windows/real.path.hpp"

#elif __APPLE__

#    include "antara/gaming/core/details/osx/real.path.hpp"

#elif __linux__

#    include "antara/gaming/core/details/linux/real.path.hpp"

#elif EMSCRIPTEN
#    include "antara/gaming/core/details/emscripten/real.path.hpp"
#endif

namespace antara::gaming::core
{
    fs::path
    binary_real_path() 
    {
        return details::binary_real_path();
    }

    fs::path
    assets_real_path() 
    {
        return details::assets_real_path();
    }
} // namespace antara::gaming::core
