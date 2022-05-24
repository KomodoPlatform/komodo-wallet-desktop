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

//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/mm2/rpc.init_z_coin_status.hpp"

//! Implementation RPC [init_z_coin]
namespace mm2::api
{
    //! Serialization
    void to_json(nlohmann::json& j, const init_z_coin_status_request& cfg)
    {
        j["params"]["task_id"] = cfg.task_id;
    }

    //! Deserialization
    void from_json(const nlohmann::json& j, init_z_coin_status_answer& z_answer)
    {
        j.at("result").at("status").get_to(z_answer.status);
        j.at("result").at("details").get_to(z_answer.details);

        if (j.at("result").at("details").contains("ticker"))
        {
            z_answer.coin = j.at("result").at("details").at("ticker").get<std::string>();
        }

        if (j.at("result").at("details").contains("wallet_balance"))
        {
            z_answer.address = j.at("result").at("details").at("wallet_balance").at("address").get<std::string>();
            z_answer.balance = j.at("result").at("details").at("wallet_balance").at("balance").at("spendable").get<std::string>();
        }
    }
} // namespace mm2::api

//