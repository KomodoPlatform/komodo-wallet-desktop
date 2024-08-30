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
#include "atomicdex/api/kdf/rpc_v2/rpc2.my_tx_history.hpp"

namespace atomic_dex::kdf
{
    void to_json(nlohmann::json& j, const my_tx_history_request_rpc& in)
    {
        j["coin"] = in.coin;
        j["limit"] = in.limit;
        j["paging_options"] = nlohmann::json::object();
        if (in.paging_options.from_id)
        {
            j["paging_options"]["FromId"] = *in.paging_options.from_id;
        }
        if (in.paging_options.page_number)
        {
            j["paging_options"]["PageNumber"] = *in.paging_options.page_number;
        }
    }
    
    void from_json(const nlohmann::json& json, my_tx_history_result_rpc& out)
    {
        out.coin = json["coin"];
        out.current_block = json["current_block"];
        out.transactions = json["transactions"].get<std::vector<transaction_data>>();
    }
}