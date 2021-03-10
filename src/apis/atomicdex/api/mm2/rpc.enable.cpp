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

//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/mm2/rpc.enable.hpp"

//! Implementation RPC [enable]
namespace mm2::api
{
    //! Serialization
    void
    to_json(nlohmann::json& j, const enable_request& cfg)
    {
        j["coin"] = cfg.coin_name;
        if (cfg.coin_type == CoinType::ERC20)
        {
            j["gas_station_url"]       = cfg.gas_station_url;
            j["swap_contract_address"] = cfg.erc_swap_contract_address;
            j["urls"]                  = cfg.urls;
        }
        j["tx_history"] = cfg.with_tx_history;
    }

    //! Deserialization
    void
    from_json(const nlohmann::json& j, enable_answer& cfg)
    {
        j.at("address").get_to(cfg.address);
        j.at("balance").get_to(cfg.balance);
        j.at("result").get_to(cfg.result);
    }
} // namespace mm2::api