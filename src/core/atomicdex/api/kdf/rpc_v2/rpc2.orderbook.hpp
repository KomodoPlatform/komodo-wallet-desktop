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

#include <optional>
#include <string>

#include <nlohmann/json_fwd.hpp> //> nlohmann::json

#include "atomicdex/api/kdf/rpc.hpp"
#include "atomicdex/api/kdf/orderbook.order.contents.hpp"

namespace atomic_dex::kdf
{
    struct orderbook_rpc
    {
        static constexpr auto endpoint  = "orderbook";
        static constexpr bool is_v2     = true;

        struct expected_request_type
        {
            std::string base;
            std::string rel;
        };

        struct expected_result_type
        {
            std::size_t                 askdepth;
            std::size_t                 biddepth;
            std::vector<order_contents> asks;
            std::vector<order_contents> bids;
            std::string                 base;
            std::string                 rel;
            std::size_t                 numasks;
            std::size_t                 numbids;
            std::size_t                 timestamp;
            std::size_t                 netid;
            std::string                 human_timestamp; //! human readable orderbook request time
            std::string                 asks_total_volume;
            std::string                 bids_total_volume;
        };

        using expected_error_type = rpc_basic_error_type;

        expected_request_type                  request;
        std::optional<expected_result_type>    result;
        std::optional<expected_error_type>     error;
        std::string                            raw_result;
    };

    using orderbook_request_rpc    = orderbook_rpc::expected_request_type;
    using orderbook_result_rpc     = orderbook_rpc::expected_result_type;
    using orderbook_error_rpc      = orderbook_rpc::expected_error_type;

    void to_json(nlohmann::json& j, const orderbook_request_rpc& req);
    void from_json(const nlohmann::json& j, orderbook_result_rpc& resp);
}
