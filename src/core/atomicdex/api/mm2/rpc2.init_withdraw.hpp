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

#include <optional>
#include <string>

//! Deps
#include <nlohmann/json_fwd.hpp>

namespace atomic_dex::mm2
{
    struct init_withdraw_fees
    {
        std::string                type;      ///< UtxoFixed, UtxoPerKbyte, EthGas, Qrc20Gas
        std::optional<std::string> amount;    ///< Utxo only
    };

    struct init_withdraw_request
    {
        std::string                               coin;
        std::string                               to;
        std::string                               amount;
        std::optional<init_withdraw_fees>         fees{std::nullopt}; ///< ignored if std::nullopt
        bool                                      max{false};
    };

    struct init_withdraw_answer
    {
        int         task_id;
    };

    void to_json(nlohmann::json& j, const init_withdraw_request& request);
    void from_json(const nlohmann::json& j, init_withdraw_answer& answer);
}

namespace atomic_dex
{
    using t_init_withdraw_request = mm2::init_withdraw_request;
    using t_init_withdraw_fees    = mm2::init_withdraw_fees;
    using t_init_withdraw_answer  = mm2::init_withdraw_answer;
} // namespace atomic_dex
