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

#include <nlohmann/json_fwd.hpp>

namespace atomic_dex::kdf
{
    struct balance_request
    {
        std::string coin;
    };

    struct balance_answer
    {
        std::string address;
        std::string balance;
        std::string coin;
        int         rpc_result_code;
        std::string raw_result;
    };

    void to_json(nlohmann::json& j, const balance_request& cfg);

    void from_json(const nlohmann::json& j, balance_answer& cfg);
} // namespace atomic_dex::kdf

namespace atomic_dex
{
    using t_balance_request = kdf::balance_request;
    using t_balance_answer  = kdf::balance_answer;
} // namespace atomic_dex