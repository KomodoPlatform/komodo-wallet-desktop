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

//! STD
#include <unordered_set>

//! Deps
#include <nlohmann/json.hpp>
#include <spdlog/spdlog.h>

//! Project Headers
#include "atomicdex/api/mm2/generics.hpp"
#include "atomicdex/api/mm2/rpc.best.orders.hpp"

//! Implementation RPC [best_orders]
namespace mm2::api
{
    void
    to_json(nlohmann::json& j, const best_orders_request& req)
    {
        j["coin"]   = req.coin;
        j["action"] = req.action;
        j["volume"] = req.volume;
    }

    void
    from_json(const nlohmann::json& j, best_orders_answer_success& answer)
    {
        if (j.empty())
        {
            SPDLOG_WARN("best orders result not available yet - probably seed node unsync");
        }
        else
        {
            for (auto&& [key, value]: j.items())
            {
                // SPDLOG_INFO("{} best orders size: {}", key, value.size());
                //bool hit = false;
                std::unordered_set<std::string> uuid_visited;
                for (auto&& cur_order: value)
                {
                    order_contents contents;
                    contents.rel_coin = key;
                    from_json(cur_order, contents);
                    if (uuid_visited.emplace(contents.uuid).second)
                    {
                        answer.result.emplace_back(std::move(contents));
                    }
                    else
                    {
                        //hit = true;
                        SPDLOG_WARN("Order with uuid: {} already added - skipping", contents.uuid);
                    }
                }
                /*if (hit)
                {
                    SPDLOG_WARN("mm2 answer duplicated: {}", value.dump());
                    hit = false;
                }*/
            }
        }
    }

    void
    from_json(const nlohmann::json& j, best_orders_answer& answer)
    {
        extract_rpc_json_answer<best_orders_answer_success>(j, answer);
    }

} // namespace mm2::api
