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

#if defined(_WIN32) || defined(WIN32)
    #ifndef SPDLOG_WCHAR_FILENAMES
        #define SPDLOG_WCHAR_FILENAMES
    #endif
#endif

#ifdef DEBUG
    #define SPDLOG_ACTIVE_LEVEL SPDLOG_LEVEL_TRACE
#else
    #define SPDLOG_ACTIVE_LEVEL SPDLOG_LEVEL_INFO
#endif
#include <spdlog/async.h>
#include <spdlog/sinks/rotating_file_sink.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/stopwatch.h>
#include <spdlog/spdlog.h>

#if defined(_WIN32) || defined(WIN32)
#include <spdlog/sinks/msvc_sink.h>
#endif

#if defined(_WIN32) || defined(WIN32)
    #define LOG_PATH(message, p) SPDLOG_INFO(L"" message, p.wstring());
    #define LOG_PATH_CMP(message, from, to) SPDLOG_INFO(L"" message, from.wstring(), to.wstring());
#else
    #define LOG_PATH(message, p) SPDLOG_INFO(message, p.string());
    #define LOG_PATH_CMP(message, from, to) SPDLOG_INFO(message, from.string(), to.string());
#endif
