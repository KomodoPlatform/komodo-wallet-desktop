/******************************************************************************
 * Copyright © 2013-2022 The Komodo Platform Developers.                      *
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
#include "balance.infos.hpp"
#include "generic.error.hpp"

namespace mm2::api
{
    struct slp_activation_params
    {
        std::optional<std::size_t> required_confirmations;
    };

    void to_json(nlohmann::json& j, const slp_activation_params& cfg);

    struct enable_slp_request
    {
        std::string                          ticker;
        std::optional<slp_activation_params> activation_params;
    };

    void to_json(nlohmann::json& j, const enable_slp_request& cfg);

    struct enable_slp_answer_success
    {
        std::string                                    platform_coin;
        std::string                                    token_id;
        std::size_t                                    required_confirmations;
        std::unordered_map<std::string, balance_infos> balances;
    };

    void from_json(const nlohmann::json& j, enable_slp_answer_success& answer);

    struct enable_slp_answer
    {
        std::optional<enable_slp_answer_success> result;
        std::optional<generic_answer_error>      error;
        std::string                              raw_result;      ///< internal
        int                                      rpc_result_code; ///< internal
    };

    void from_json(const nlohmann::json& j, enable_slp_answer& answer);
} // namespace mm2::api

namespace atomic_dex
{
    using t_enable_slp_request        = ::mm2::api::enable_slp_request;
    using t_enable_slp_answer         = ::mm2::api::enable_slp_answer;
    using t_enable_slp_answer_success = ::mm2::api::enable_slp_answer_success;
} // namespace atomic_dex 
