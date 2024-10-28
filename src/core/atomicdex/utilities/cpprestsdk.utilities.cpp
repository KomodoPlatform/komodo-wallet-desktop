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

//! Deps
#include <nlohmann/json.hpp>
#include <spdlog/spdlog.h>
#if defined(linux) || defined(__APPLE__)
#    define BOOST_STACKTRACE_USE_ADDR2LINE
#    if defined(__APPLE__)
#        define _GNU_SOURCE
#    endif
#    include <boost/stacktrace.hpp>
#endif
#include <cpprest/filestream.h>

//! Project Headers
#include "atomicdex/utilities/cpprestsdk.utilities.hpp"

t_http_request
create_json_post_request(nlohmann::json&& json_data, const std::string& content_type)
{
    t_http_request req;
    req.set_method(web::http::methods::POST);
    req.headers().set_content_type(content_type);
    try {
        req.set_body(json_data.dump());
    } catch (const std::exception& e) {
        SPDLOG_ERROR("Error serializing JSON data: {}", e.what());
        throw; // rethrow the exception if needed
    }
    return req;
}


void
handle_exception_pplx_task(pplx::task<void> previous_task)
{
    try
    {
        previous_task.wait();
    }
    catch (const std::exception& e)
    {
        SPDLOG_ERROR("pplx task error: {}", e.what());
        throw; // rethrow the exception if needed
//#if defined(linux) || defined(__APPLE__)
//        SPDLOG_ERROR("stacktrace: {}", boost::stacktrace::to_string(boost::stacktrace::stacktrace()));
//#endif
    }
}