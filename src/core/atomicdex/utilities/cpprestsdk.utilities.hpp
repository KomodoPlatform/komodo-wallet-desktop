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

#include <nlohmann/json_fwd.hpp>

#ifndef _TURN_OFF_PLATFORM_STRING
#   define _TURN_OFF_PLATFORM_STRING
#endif
#include <cpprest/http_client.h>
#ifdef _WIN32
#    define TO_STD_STR(ws_str) utility::conversions::to_utf8string(ws_str)
#    define FROM_STD_STR(utf8str) utility::conversions::to_string_t(utf8str)
#else
#    define TO_STD_STR(ws_str) ws_str
#    define FROM_STD_STR(utf8str) utf8str
#endif

using t_http_client_ptr = std::unique_ptr<web::http::client::http_client>;
using t_http_client     = web::http::client::http_client;
using t_http_request    = web::http::http_request;

t_http_request create_json_post_request(nlohmann::json&& json_data);
void handle_exception_pplx_task(pplx::task<void> previous_task);