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
#include "atomicdex/api/mm2/rpc.orderbook.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

namespace mm2::api
{
    void
    from_json(const nlohmann::json& j, orderbook_answer& answer)
    {
        using namespace date;

        j.at("base").get_to(answer.base);
        j.at("rel").get_to(answer.rel);
        j.at("askdepth").get_to(answer.askdepth);
        j.at("biddepth").get_to(answer.biddepth);
        j.at("bids").get_to(answer.bids);
        j.at("asks").get_to(answer.asks);
        j.at("numasks").get_to(answer.numasks);
        j.at("numbids").get_to(answer.numbids);
        j.at("netid").get_to(answer.netid);
        j.at("timestamp").get_to(answer.timestamp);

        answer.human_timestamp = atomic_dex::utils::to_human_date(answer.timestamp, "%Y-%m-%d %I:%M:%S");

        t_float_50 result_asks_f(0);
        for (auto&& cur_asks: answer.asks) { result_asks_f = result_asks_f + safe_float(cur_asks.maxvolume); }

        answer.asks_total_volume = result_asks_f.str();

        t_float_50 result_bids_f(0);
        for (auto& cur_bids: answer.bids)
        {
            cur_bids.total        = cur_bids.maxvolume;
            t_float_50 new_volume = safe_float(cur_bids.maxvolume) / safe_float(cur_bids.price);
            cur_bids.maxvolume    = atomic_dex::utils::adjust_precision(new_volume.str());
            result_bids_f         = result_bids_f + safe_float(cur_bids.maxvolume);
        }

        answer.bids_total_volume = result_bids_f.str();
        for (auto&& cur_asks: answer.asks)
        {
            t_float_50 percent_f   = safe_float(cur_asks.maxvolume) / result_asks_f;
            cur_asks.depth_percent = atomic_dex::utils::adjust_precision(percent_f.str());
            //SPDLOG_INFO("cur_asks: {}", cur_asks.to_string());
        }

        for (auto&& cur_bids: answer.bids)
        {
            t_float_50 percent_f   = safe_float(cur_bids.maxvolume) / result_bids_f;
            cur_bids.depth_percent = atomic_dex::utils::adjust_precision(percent_f.str());
            //SPDLOG_INFO("cur_bids: {}", cur_bids.to_string());
        }
    }

    void
    to_json(nlohmann::json& j, const orderbook_request& request)
    {
        j["base"] = request.base;
        j["rel"]  = request.rel;
    }
} // namespace mm2::api
