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

//! PCH Headers
#include "atomicdex/pch.hpp"

//! Project Headers
#include "atomicdex/utilities/kill.hpp"

namespace atomic_dex
{
    ENTT_API void
    kill_executable(const char* exec_name)
    {
#if defined(__APPLE__) || defined(__linux__)
        std::string cmd_line = "killall " + std::string(exec_name);
        std::system(cmd_line.c_str());
#else
        std::string cmd_line = "taskkill /F /IM " + std::string(exec_name) + ".exe /T";
        std::system(cmd_line.c_str());
#endif
    }
} // namespace atomic_dex
