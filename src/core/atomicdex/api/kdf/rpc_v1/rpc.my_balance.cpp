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

//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/kdf/rpc_v1/rpc.my_balance.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

namespace atomic_dex::kdf
{
    void
    to_json(nlohmann::json& j, const balance_request& cfg)
    {
        j["coin"] = cfg.coin;
    }

    void
    from_json(const nlohmann::json& j, balance_answer& cfg)
    {
        j.at("address").get_to(cfg.address);
        j.at("balance").get_to(cfg.balance);
        cfg.balance = atomic_dex::utils::adjust_precision(cfg.balance);
        j.at("coin").get_to(cfg.coin);
    }
} // namespace atomic_dex::kdf