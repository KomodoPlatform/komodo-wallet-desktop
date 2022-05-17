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
#include "atomicdex/api/mm2/rpc.init_z_coin.hpp"

//! Implementation RPC [init_z_coin]
namespace mm2::api
{
    //! Serialization
    void to_json(nlohmann::json& j, const init_z_coin_request& cfg)
    {
        j["params"]["ticker"]                                                          = cfg.coin_name;
        j["params"]["activation_params"]["mode"]["rpc"]                                = "Light";
        j["params"]["activation_params"]["mode"]["rpc_data"]["electrum_servers"]       = cfg.servers;
        j["params"]["activation_params"]["mode"]["rpc_data"]["light_wallet_d_servers"] = cfg.z_urls;
        j["params"]["tx_history"]                                                      = cfg.with_tx_history;
    }

    //! Deserialization
    void from_json(const nlohmann::json& j, init_z_coin_answer& cfg)
    {
        j.at("task_id").get_to(cfg.task_id);
    }
} // namespace mm2::api
