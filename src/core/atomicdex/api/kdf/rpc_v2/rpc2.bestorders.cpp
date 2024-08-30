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

//! STD
#include <unordered_set>

//! Deps
#include <nlohmann/json.hpp>
#include <spdlog/spdlog.h>

//! Project Headers
#include "atomicdex/api/kdf/generics.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.bestorders.hpp"

//! Implementation RPC [best_orders]
namespace atomic_dex::kdf
{
    void
    to_json(nlohmann::json& j, const bestorders_request_rpc& req)
    {
        j["coin"]   = req.coin;
        j["action"] = req.action;
        j["request_by"]["type"] = "volume";
        j["request_by"]["value"] = req.volume;
    }

    void
    from_json(const nlohmann::json& j, bestorders_result_rpc& resp)
    {
        if (j.empty())
        {
            SPDLOG_WARN("best orders result not available yet - probably seed node unsync");
        }
        else
        {
            for (auto&& [key, value]: j["orders"].items())
            {
                //bool hit = false;
                std::unordered_set<std::string> uuid_visited;
                for (auto&& cur_order: value)
                {
                    order_contents contents;
                    contents.rel_coin = key;

                    from_json(cur_order, contents);
                    if (uuid_visited.emplace(contents.uuid).second)
                    {
                        resp.result.emplace_back(std::move(contents));
                    }
                    else
                    {
                        SPDLOG_WARN("Order with uuid: {} already added - skipping", contents.uuid);
                    }
                }
            }
        }
    }
} // namespace atomic_dex::kdf
