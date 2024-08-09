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
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/kdf/trading.order.contents.hpp"

namespace atomic_dex::kdf
{
    struct sell_request
    {
        std::string                   base;
        std::string                   rel;
        std::string                   price;
        std::string                   volume;
        bool                          is_created_order;
        std::string                   price_denom;
        std::string                   price_numer;
        std::string                   volume_denom;
        std::string                   volume_numer;
        bool                          is_exact_selected_order_volume;
        bool                          selected_order_use_input_volume{false};
        std::optional<bool>           rel_nota;
        std::optional<std::size_t>    rel_confs;
        bool                          is_max;
        std::optional<std::string>    min_volume{std::nullopt};
        std::optional<nlohmann::json> order_type{std::nullopt};
    };

    void to_json(nlohmann::json& j, const sell_request& request);

    struct sell_answer_success
    {
        trading_order_contents contents;
    };

    void from_json(const nlohmann::json& j, sell_answer_success& contents);

    struct sell_answer
    {
        std::optional<std::string>         error;
        std::optional<sell_answer_success> result;
        int                                rpc_result_code;
        std::string                        raw_result;
    };

    void from_json(const nlohmann::json& j, sell_answer& answer);
} // namespace atomic_dex::kdf

namespace atomic_dex
{
    using t_sell_request        = kdf::sell_request;
    using t_sell_answer         = kdf::sell_answer;
    using t_sell_answer_success = kdf::sell_answer_success;
} // namespace atomic_dex