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

#pragma once

//! STD
#include <optional>
#include <string>

//! Deps
#include <nlohmann/json_fwd.hpp>

//! Project Headers
#include "atomicdex/api/kdf/rpc.hpp"
#include "atomicdex/api/kdf/orderbook.order.contents.hpp"

namespace atomic_dex::kdf
{
    struct bestorders_rpc
    {
        static constexpr auto endpoint  = "best_orders";
        static constexpr bool is_v2     = true;

        struct expected_request_type
        {
            std::string coin;
            std::string volume;
            std::string action;
        };


        struct expected_result_type
        {
            std::vector<order_contents> result;
        };

        using expected_error_type = rpc_basic_error_type;

        expected_request_type                  request;
        std::optional<expected_result_type>    result;
        std::optional<expected_error_type>     error;
        std::string                            raw_result;
    };

    using bestorders_request_rpc    = bestorders_rpc::expected_request_type;
    using bestorders_result_rpc     = bestorders_rpc::expected_result_type;
    using bestorders_error_rpc      = bestorders_rpc::expected_error_type;

    void to_json(nlohmann::json& j, const bestorders_request_rpc& req);
    void from_json(const nlohmann::json& j, bestorders_result_rpc& answer);

} // namespace atomic_dex::kdf
