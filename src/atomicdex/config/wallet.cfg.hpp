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
#include <unordered_map>

//! Deps
#include <nlohmann/json_fwd.hpp>
#include <boost/thread/synchronized_value.hpp>

namespace atomic_dex
{
    struct transactions_contents
    {
        std::string note;
        std::string category;
    };

    void to_json(nlohmann::json& j, const transactions_contents& cfg);
    void from_json(const nlohmann::json& j, transactions_contents& cfg);

    struct wallet_cfg
    {
        using t_synchronized_transactions_details = boost::synchronized_value<std::unordered_map<std::string, transactions_contents>>;
        std::string                         name{};
        std::string                         protection_pass{"default_protection_pass"};
        t_synchronized_transactions_details transactions_details;
    };

    void from_json(const nlohmann::json& j, wallet_cfg& cfg);
    void to_json(nlohmann::json& j, const wallet_cfg& cfg);
} // namespace atomic_dex