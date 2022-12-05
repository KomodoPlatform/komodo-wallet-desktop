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

namespace atomic_dex::mm2
{
    void
    from_json(const nlohmann::json& j, orderbook_answer& answer)
    {
        using namespace date;
        // SPDLOG_INFO("got orderbook data...");

        j.at("result").at("base").get_to(answer.base);
        j.at("result").at("rel").get_to(answer.rel);
        j.at("result").at("num_asks").get_to(answer.numasks);
        j.at("result").at("num_bids").get_to(answer.numbids);
        j.at("result").at("net_id").get_to(answer.netid);
        j.at("result").at("timestamp").get_to(answer.timestamp);
        j.at("result").at("bids").get_to(answer.bids);
        j.at("result").at("asks").get_to(answer.asks);

        answer.human_timestamp = atomic_dex::utils::to_human_date(answer.timestamp, "%Y-%m-%d %I:%M:%S");

        t_float_50 result_asks_f(0);
        for (auto&& cur_asks: answer.asks) {
            cur_asks.min_volume                 = cur_asks.base_min_volume;
            cur_asks.min_volume_fraction_numer  = cur_asks.base_min_volume_numer;
            cur_asks.min_volume_fraction_denom  = cur_asks.base_min_volume_denom;
            cur_asks.max_volume                 = cur_asks.base_max_volume;
            cur_asks.max_volume_fraction_numer  = cur_asks.base_max_volume_numer;
            cur_asks.max_volume_fraction_denom  = cur_asks.base_max_volume_denom;

            if (cur_asks.price.find('.') != std::string::npos)
            {
                boost::trim_right_if(cur_asks.price, boost::is_any_of("0"));
                cur_asks.price = cur_asks.price;
            }
            cur_asks.max_volume = atomic_dex::utils::adjust_precision(cur_asks.max_volume);
            t_float_50 total_f                  = safe_float(cur_asks.price) * safe_float(cur_asks.max_volume);
            cur_asks.total                      = atomic_dex::utils::adjust_precision(total_f.str());
            result_asks_f                       = result_asks_f + safe_float(cur_asks.max_volume);
        }
        answer.asks_total_volume = result_asks_f.str();

        t_float_50 result_bids_f(0);
        for (auto& cur_bids: answer.bids)
        {
            cur_bids.min_volume                 = cur_bids.base_min_volume;
            cur_bids.min_volume_fraction_numer  = cur_bids.base_min_volume_numer;
            cur_bids.min_volume_fraction_denom  = cur_bids.base_min_volume_denom;
            cur_bids.max_volume                 = cur_bids.base_max_volume;
            cur_bids.max_volume_fraction_numer  = cur_bids.base_max_volume_numer;
            cur_bids.max_volume_fraction_denom  = cur_bids.base_max_volume_denom;
            cur_bids.total                      = cur_bids.max_volume;

            if (cur_bids.price.find('.') != std::string::npos)
            {
                boost::trim_right_if(cur_bids.price, boost::is_any_of("0"));
                cur_bids.price = cur_bids.price;
            }
            cur_bids.max_volume = atomic_dex::utils::adjust_precision(cur_bids.max_volume);
            t_float_50 total_f                  = safe_float(cur_bids.price) * safe_float(cur_bids.max_volume);
            cur_bids.total                      = atomic_dex::utils::adjust_precision(total_f.str());
            result_bids_f                       = result_bids_f + safe_float(cur_bids.max_volume);
        }
        answer.bids_total_volume = result_bids_f.str();

        for (auto&& cur_asks: answer.asks)
        {
            t_float_50 percent_f   = safe_float(cur_asks.max_volume) / result_asks_f;
            cur_asks.depth_percent = atomic_dex::utils::adjust_precision(percent_f.str());
            // SPDLOG_INFO("cur_asks: {}", cur_asks.to_string());
        }

        for (auto&& cur_bids: answer.bids)
        {
            t_float_50 percent_f   = safe_float(cur_bids.max_volume) / result_bids_f;
            cur_bids.depth_percent = atomic_dex::utils::adjust_precision(percent_f.str());
            // SPDLOG_INFO("cur_bids: {}", cur_bids.to_string());
        }
    }

    void
    to_json(nlohmann::json& j, const orderbook_request& request)
    {
        j["params"]["base"] = request.base;
        j["params"]["rel"]  = request.rel;
    }
} // namespace atomic_dex::mm2
