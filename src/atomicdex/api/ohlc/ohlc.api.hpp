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

//! STD
#include <optional>

//! Project Headers
#include "atomicdex/utilities/cpprestsdk.utilities.hpp"

namespace atomic_dex
{
    struct ohlc_request
    {
        std::string base_asset;
        std::string quote_asset;
    };

    struct ohlc_contents
    {
        std::size_t close_time_timestamp;
        std::string human_readeable_closing_time;
        std::string open;
        std::string high;
        std::string low;
        std::string close;
        std::string volume;
        std::string quote_volume;
    };

    struct ohlc_answer_success
    {
        using t_format        = std::string;
        using t_ohlc_contents = std::vector<ohlc_contents>;
        std::unordered_map<t_format, t_ohlc_contents> result;
        nlohmann::json                                raw_result;
    };

    struct ohlc_answer
    {
        std::optional<ohlc_answer_success> result;
        std::optional<std::string>         error;
    };

    void from_json(const nlohmann::json& j, ohlc_answer_success& answer);
    void from_json(const nlohmann::json& j, ohlc_answer& answer);

    ohlc_answer                          ohlc_answer_from_async_resp(web::http::http_response resp);
    pplx::task<web::http::http_response> async_rpc_ohlc_get_data(ohlc_request&& request);

} // namespace atomic_dex
