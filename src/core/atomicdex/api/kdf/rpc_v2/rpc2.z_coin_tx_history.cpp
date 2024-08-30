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
#include "atomicdex/api/kdf/rpc_v2/rpc2.z_coin_tx_history.hpp"

//! Implementation 2.0 RPC [z_coin_tx_history]
namespace atomic_dex::kdf
{
    //! Serialization
    void to_json(nlohmann::json& j, const z_tx_history_request& request)
    {
        j["params"]["coin"]                           = request.coin;
        j["params"]["limit"]                          = request.limit;
        //j["params"]["paging_options"]["PageNumber"]   = request.page_number;
        //j["params"]["paging_options"]["FromId"]       = request.from_id;
    }

    //! Deserialization
    void
    from_json(const nlohmann::json& j, sync_status_z_error& answer)
    {   // TODO: confirm the v2 error output uses this structure
        j.at("code").get_to(answer.code);
        j.at("message").get_to(answer.message);
    }

    void
    from_json(const nlohmann::json& j, sync_status_z_coins& answer)
    {
        j.at("transactions_left").get_to(answer.transactions_left);
    }

    void
    from_json(const nlohmann::json& j, sync_status_z_additional_infos& answer)
    {
        if (j.count("error") == 1)
        {
            answer.error = j.get<sync_status_z_error>();
        } // TODO check if 'blocks_left' or 'transactions_left'
        else if (j.count("transactions_left") == 1)
        {
            answer.z_infos = j.get<sync_status_z_coins>();
        }
    }

    void
    from_json(const nlohmann::json& j, t_z_sync_status& answer)
    {
        j.at("state").get_to(answer.state);
        if (j.count("additional_info") == 1)
        {
            answer.additional_info = j.at("additional_info").get<sync_status_z_additional_infos>();
        }
    }

    void
    from_json(const nlohmann::json& j, z_tx_history_answer_success& answer)
    {
        if (j.contains("from_id"))
        {
            if (not j.at("from_id").is_null())
                j.at("from_id").get_to(answer.from_id);
        }
        if (j.contains("current_block"))
        {
            j.at("current_block").get_to(answer.current_block);
        }
        j.at("limit").get_to(answer.limit);
        j.at("skipped").get_to(answer.skipped);
        if (j.contains("sync_status"))
        {
            j.at("sync_status").get_to(answer.sync_status);
        }
        j.at("total").get_to(answer.total);
        j.at("transactions").get_to(answer.transactions);
    }

    void
    from_json(const nlohmann::json& j, z_tx_history_answer& answer)
    {
        if (j.contains("error"))
        {
            answer.error = j.at("error").get<std::string>();
        }
        else
        {
            answer.result = j.at("result").get<z_tx_history_answer_success>();
        }
    }
} // namespace atomic_dex::kdf
