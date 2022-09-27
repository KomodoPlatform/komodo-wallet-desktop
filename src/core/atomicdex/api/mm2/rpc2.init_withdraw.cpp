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
#include "atomicdex/api/mm2/rpc2.init_withdraw.hpp"

//! Implementation 2.0 RPC [init_withdraw]
namespace atomic_dex::mm2
{
    void
    to_json(nlohmann::json& j, const init_withdraw_fees& request)
    {
        j["type"]   = request.type;
        j["amount"] = request.amount.value();
    }

    //! Serialization
    void to_json(nlohmann::json& j, const init_withdraw_request& request)
    {
        nlohmann::json obj = nlohmann::json::object();

        obj["params"]["coin"]        = request.coin;
        obj["params"]["to"]          = request.to;
        obj["params"]["amount"]      = request.amount;
        obj["params"]["max"]         = request.max;

        if (request.fees.has_value())
        {
            obj["params"]["fee"] = request.fees.value();
        }
        j.update(obj);
    }

    //! Deserialization
    void from_json(const nlohmann::json& j, init_withdraw_answer& answer)
    {
        j.at("task_id").get_to(answer.task_id);
    }
} // namespace atomic_dex::mm2
