/******************************************************************************
 * Copyright © 2013-2023 The Komodo Platform Developers.                      *
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

#include <fstream>
#include <iostream>

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
        std::string cmd_line_check = "pgrep " + std::string(exec_name);
        std::string response = execute(cmd_line_check);
        if (response != "")
        {
            std::string cmd_line = "killall " + std::string(exec_name);
            std::string response = execute(cmd_line);
        }
#else
        std::string cmd_line = "taskkill /F /IM " + std::string(exec_name) + ".exe /T";
        std::string response = execute(cmd_line);
#endif
    }

    std::string
    execute(const std::string& command)
    {
        system((command + " > temp.txt").c_str());

        std::ifstream ifs("temp.txt");
        std::string ret{ std::istreambuf_iterator<char>(ifs), std::istreambuf_iterator<char>() };
        ifs.close(); // must close the inout stream so the file can be cleaned up
        if (std::remove("temp.txt") != 0) {
            SPDLOG_DEBUG("Error deleting temporary file");
        }
        return ret;
    }
} // namespace atomic_dex
