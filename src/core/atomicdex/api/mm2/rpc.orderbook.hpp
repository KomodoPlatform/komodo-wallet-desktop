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

//! Deps
#include <nlohmann/json_fwd.hpp>

//! Project Headers
#include "atomicdex/api/mm2/orderbook.order.contents.hpp"

namespace atomic_dex::mm2
{
    struct orderbook_request
    {
        std::string base;
        std::string rel;
    };

    void to_json(nlohmann::json& j, const orderbook_request& request);

    struct orderbook_answer
    {
        std::size_t                 askdepth{0};
        std::size_t                 biddepth{0};
        std::vector<order_contents> asks;
        std::vector<order_contents> bids;
        std::string                 base;
        std::string                 rel;
        std::size_t                 numasks;
        std::size_t                 numbids;
        std::size_t                 timestamp;
        std::size_t                 netid;
        std::string                 human_timestamp; //! Moment of the orderbook request human readeable
        std::string                 asks_total_volume;
        std::string                 bids_total_volume;

        //! Internal
        std::string raw_result;
        int         rpc_result_code;
    };

    void from_json(const nlohmann::json& j, orderbook_answer& answer);
}

namespace atomic_dex
{
    using t_orderbook_request       = mm2::orderbook_request;
    using t_orderbook_answer        = mm2::orderbook_answer;
}