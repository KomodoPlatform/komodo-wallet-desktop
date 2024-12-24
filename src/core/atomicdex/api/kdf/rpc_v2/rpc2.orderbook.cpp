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
#include "atomicdex/api/kdf/rpc_v2/rpc2.orderbook.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

namespace atomic_dex::kdf
{
    void
    to_json(nlohmann::json& j, const orderbook_request_rpc& req)
    {
        j["base"] = req.base;
        j["rel"]  = req.rel;
    }

    void
    from_json(const nlohmann::json& j, orderbook_result_rpc& resp)
    {
        using namespace date;
        // atomic_dex::utils::json_keys(j);
        nlohmann::json k; 
        if (j.contains("result"))
        {
            // Not sure how why where it is being returned in this format
            j.at("result").at("rel").get_to(resp.rel);
            j.at("result").at("num_asks").get_to(resp.numasks);
            j.at("result").at("num_bids").get_to(resp.numbids);
            j.at("result").at("net_id").get_to(resp.netid);
            j.at("result").at("timestamp").get_to(resp.timestamp);
            j.at("result").at("bids").get_to(resp.bids);
            j.at("result").at("asks").get_to(resp.asks);
            j.at("result").at("base").get_to(resp.base);
        }
        else
        {
            j.at("base").get_to(resp.base);
            j.at("rel").get_to(resp.rel);
            j.at("num_asks").get_to(resp.numasks);
            j.at("num_bids").get_to(resp.numbids);
            j.at("net_id").get_to(resp.netid);
            j.at("timestamp").get_to(resp.timestamp);
            j.at("bids").get_to(resp.bids);
            j.at("asks").get_to(resp.asks);
        }

        resp.human_timestamp = atomic_dex::utils::to_human_date(resp.timestamp, "%Y-%m-%d %I:%M:%S");

        t_float_50 result_asks_f(0);
        for (auto&& cur_asks: resp.asks) {
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
        resp.asks_total_volume = result_asks_f.str();

        t_float_50 result_bids_f(0);
        for (auto& cur_bids: resp.bids)
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
        resp.bids_total_volume = result_bids_f.str();

        for (auto&& cur_asks: resp.asks)
        {
            t_float_50 percent_f   = safe_float(cur_asks.max_volume) / result_asks_f;
            cur_asks.depth_percent = atomic_dex::utils::adjust_precision(percent_f.str());
            // SPDLOG_INFO("cur_asks: {}", cur_asks.to_string());
        }

        for (auto&& cur_bids: resp.bids)
        {
            t_float_50 percent_f   = safe_float(cur_bids.max_volume) / result_bids_f;
            cur_bids.depth_percent = atomic_dex::utils::adjust_precision(percent_f.str());
            // SPDLOG_INFO("cur_bids: {}", cur_bids.to_string());
        }
    }

} // namespace atomic_dex::kdf
