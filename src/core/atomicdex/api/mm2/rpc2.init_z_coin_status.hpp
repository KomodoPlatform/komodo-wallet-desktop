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

// Std Headers
#include <optional>

// Deps Headers
#include <nlohmann/json.hpp>

namespace mm2::api
{
    struct init_z_coin_status_request
    {
        int         task_id;
    };

    struct init_z_coin_status_answer
    {
        std::string status;
        std::string details;
        std::optional<std::string> coin;
        std::optional<std::string> address;
        std::optional<std::string> current_scanned_block;
        std::optional<std::string> latest_block;
        std::optional<std::string> current_block;
        std::optional<std::string> wallet_type;
        std::optional<std::string> spendable_balance;
        std::optional<std::string> unspendable_balance;
    };

    void to_json(nlohmann::json& j, const init_z_coin_status_request& request);
    void from_json(const nlohmann::json& j, init_z_coin_status_answer& answer);
}

namespace atomic_dex
{
    using t_init_z_coin_status_request = ::mm2::api::init_z_coin_status_request;
    using t_init_z_coin_status_answer = ::mm2::api::init_z_coin_status_answer;
} // namespace atomic_dex
