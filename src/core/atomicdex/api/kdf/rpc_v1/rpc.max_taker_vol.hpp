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

namespace atomic_dex::kdf
{
    struct max_taker_vol_request
    {
        std::string                coin;
        std::optional<std::string> trade_with;
    };

    void to_json(nlohmann::json& j, const max_taker_vol_request& cfg);

    struct max_taker_vol_answer_success
    {
        std::string denom;
        std::string numer;
        std::string decimal;
        std::string coin;
    };

    void from_json(const nlohmann::json& j, max_taker_vol_answer_success& cfg);

    struct max_taker_vol_answer
    {
        std::optional<max_taker_vol_answer_success> result;
        std::optional<std::string>                  error;
        int                                         rpc_result_code;
        std::string                                 raw_result;
    };

    void from_json(const nlohmann::json& j, max_taker_vol_answer& answer);
} // namespace atomic_dex::kdf

namespace atomic_dex
{
    using t_max_taker_vol_request        = kdf::max_taker_vol_request;
    using t_max_taker_vol_answer         = kdf::max_taker_vol_answer;
    using t_max_taker_vol_answer_success = kdf::max_taker_vol_answer_success;
} // namespace atomic_dex