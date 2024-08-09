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
#include "atomicdex/api/kdf/generics.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.trade_preimage.hpp"

namespace atomic_dex::kdf
{
    //! Serialization
    void
    to_json(nlohmann::json& j, const trade_preimage_request& request)
    {
        j["params"]["base"]        = request.base_coin;
        j["params"]["rel"]         = request.rel_coin;
        j["params"]["swap_method"] = request.swap_method;
        j["params"]["volume"]      = request.volume;
        if (request.max.has_value())
        {
            j["params"]["max"] = request.max.value();
        }
        if (request.price.has_value())
        {
            j["params"]["price"] = request.price.value();
        }
    }

    //! Deserialization
    void
    from_json(const nlohmann::json& j, coin_fee& fee)
    {
        j.at("coin").get_to(fee.coin);
        j.at("amount").get_to(fee.amount);
        j.at("amount_fraction").get_to(fee.amount_fraction);
    }

    void
    from_json(const nlohmann::json& j, trade_preimage_answer_success& answer)
    {
        j.at("base_coin_fee").get_to(answer.base_coin_fee);
        j.at("rel_coin_fee").get_to(answer.rel_coin_fee);
        if (j.contains("taker_fee"))
        {
            answer.taker_fee = j.at("taker_fee").get<coin_fee>();
        }
        if (j.contains("fee_to_send_taker_fee"))
        {
            answer.fee_to_send_taker_fee = j.at("fee_to_send_taker_fee").get<coin_fee>();
        }
        if (j.contains("total_fees"))
        {
            j.at("total_fees").get_to(answer.total_fees);
        }
    }

    void
    from_json(const nlohmann::json& j, trade_preimage_answer& answer)
    {
        extract_rpc_json_answer<trade_preimage_answer_success>(j, answer);
    }
} // namespace atomic_dex::kdf
