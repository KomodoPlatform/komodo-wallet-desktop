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

#include <string>

#include <nlohmann/json_fwd.hpp> //> nlohmann::json

#include "atomicdex/api/mm2/rpc.hpp"

namespace atomic_dex::mm2
{
    struct enable_slp_rpc
    {
        static constexpr auto endpoint  = "enable_slp";
        static constexpr bool is_v2     = true;
        
        struct excpected_request_type
        {
            std::string                                             ticker;
            struct { std::optional<int> required_confirmations; }   activation_params;
        };
        
        struct excpected_answer_type
        {
            struct balance_info { std::string spendable; std::string unspendable; };

            std::string                                     token_id;
            std::string                                     platform_coin;
            int                                             required_confirmations;
            std::unordered_map<std::string, balance_info>   balances;
        };

        using excpected_error_type = rpc_basic_error_type;

        excpected_request_type                  request;
        std::optional<excpected_answer_type>    result;
        std::optional<excpected_error_type>     error;
    };

    using enable_slp_rpc_request = enable_slp_rpc::expected_request_type;
    using enable_slp_rpc_answer = enable_slp_rpc::expected_answer_type;
    using enable_slp_rpc_error = enable_slp_rpc::excpected_error_type;

    inline void from_json(const nlohmann::json& j, enable_slp_rpc_answer& in);
    inline void from_json(const nlohmann::json& j, enable_slp_rpc_answer::balance_info& in);
}