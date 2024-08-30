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

#include <nlohmann/json.hpp>

#include "utxo_merge_params.hpp"

namespace atomic_dex::kdf
{
    void to_json(nlohmann::json& j, const utxo_merge_params_t& req)
    {
        j["merge_at"] = req.merge_at;
        j["check_every"] = req.check_every;
        j["max_merge_at_once"] = req.max_merge_at_once;
    }
    void
    from_json(const nlohmann::json& j, utxo_merge_params_t& resp)
    {
        resp.merge_at = j.at("merge_at").get<std::size_t>();
        resp.check_every = j.at("check_every").get<std::size_t>();
        resp.max_merge_at_once = j.at("max_merge_at_once").get<std::size_t>();        
    }
}
