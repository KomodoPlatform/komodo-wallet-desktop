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
#include <entt/core/attribute.h>
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/kdf/fraction.hpp"

namespace atomic_dex::kdf
{
    struct trade_preimage_request
    {
        std::string                base_coin;
        std::string                rel_coin;
        std::string                swap_method;
        std::string                volume;
        std::optional<std::string> price;
        std::optional<bool>        max;
    };

    ENTT_API void to_json(nlohmann::json& j, const trade_preimage_request& request);

    struct coin_fee
    {
        std::string                  coin;
        std::string                  amount;
        kdf::fraction           amount_fraction;
    };

    ENTT_API void from_json(const nlohmann::json& j, coin_fee& fee);

    struct trade_preimage_answer_success
    {
        coin_fee                      base_coin_fee;
        coin_fee                      rel_coin_fee;
        std::optional<coin_fee>       taker_fee;
        std::optional<coin_fee>       fee_to_send_taker_fee;
        nlohmann::json                total_fees;
        std::optional<nlohmann::json> error_fees;
    };

    ENTT_API void from_json(const nlohmann::json& j, trade_preimage_answer_success& answer);

    struct trade_preimage_answer
    {
        std::optional<trade_preimage_answer_success> result;
        std::optional<std::string>                   error;
        int                                          rpc_result_code;
        std::string                                  raw_result;
    };

    ENTT_API void from_json(const nlohmann::json& j, trade_preimage_answer& answer);
} // namespace atomic_dex::kdf

namespace atomic_dex
{
    using t_trade_preimage_request        = kdf::trade_preimage_request;
    using t_trade_preimage_answer         = kdf::trade_preimage_answer;
    using t_trade_preimage_answer_success = kdf::trade_preimage_answer_success;
} // namespace atomic_dex
