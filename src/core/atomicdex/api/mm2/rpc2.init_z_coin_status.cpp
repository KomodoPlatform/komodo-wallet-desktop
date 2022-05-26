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
#include "atomicdex/api/mm2/rpc2.init_z_coin_status.hpp"

//! Implementation 2.0 RPC [init_z_coin_status]
namespace mm2::api
{
    //! Serialization
    void to_json(nlohmann::json& j, const init_z_coin_status_request& request)
    {
        j["params"]["task_id"] = request.task_id;
    }

    //! Deserialization
    void from_json(const nlohmann::json& j, init_z_coin_status_answer& answer)
    {
        j.at("result").at("status").get_to(answer.status);
        j.at("result").at("details").get_to(answer.details);

        if (j.at("result").at("details").contains("ticker"))
        {
            answer.coin = j.at("result").at("details").at("ticker").get<std::string>();
        }

        if (j.at("result").at("details").contains("wallet_balance"))
        {
            answer.address = j.at("result").at("details").at("wallet_balance").at("address").get<std::string>();
            answer.balance = j.at("result").at("details").at("wallet_balance").at("balance").at("spendable").get<std::string>();
        }
    }
} // namespace mm2::api
