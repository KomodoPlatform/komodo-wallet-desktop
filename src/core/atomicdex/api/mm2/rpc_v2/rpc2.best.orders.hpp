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

//! Deps
#include <nlohmann/json_fwd.hpp>

//! Project Headers
#include "atomicdex/api/mm2/orderbook.order.contents.hpp"

namespace atomic_dex::mm2
{
    struct best_orders_request
    {
        std::string coin;
        std::string volume;
        std::string action;
    };

    void to_json(nlohmann::json& j, const best_orders_request& req);

    struct best_orders_answer_success
    {
        std::vector<order_contents> result;
    };

    void from_json(const nlohmann::json& j, best_orders_answer_success& answer);

    struct best_orders_answer
    {
        std::optional<best_orders_answer_success> result;
        std::optional<std::string>                error;
        std::string                               raw_result;      ///< internal
        int                                       rpc_result_code; ///< internal
    };

    void from_json(const nlohmann::json& j, best_orders_answer& answer);
} // namespace atomic_dex::mm2

namespace atomic_dex
{
    using t_best_orders_request        = mm2::best_orders_request;
    using t_best_orders_answer         = mm2::best_orders_answer;
    using t_best_orders_answer_success = mm2::best_orders_answer_success;
} // namespace atomic_dex