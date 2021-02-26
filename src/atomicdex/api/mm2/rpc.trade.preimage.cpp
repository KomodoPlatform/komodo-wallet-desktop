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
#include "atomicdex/api/mm2/rpc.trade.preimage.hpp"
#include "atomicdex/api/mm2/generics.hpp"

namespace mm2::api
{
    //! Serialization
    void
    to_json(nlohmann::json& j, const trade_preimage_request& request)
    {
        j["base"]        = request.base_coin;
        j["rel"]         = request.rel_coin;
        j["swap_method"] = request.swap_method;
        j["volume"]      = request.volume;
        if (request.max.has_value())
        {
            j["max"] = request.max.value();
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
            answer.taker_fee = j.at("taker_fee").get<std::string>();
        }
        if (j.contains("taker_fee_fraction"))
        {
            answer.taker_fee_fraction = j.at("taker_fee_fraction").get<fraction>();
        }
        if (j.contains("fee_to_send_taker_fee"))
        {
            answer.fee_to_send_taker_fee = j.at("fee_to_send_taker_fee").get<coin_fee>();
        }
        if (j.contains("volume"))
        {
            answer.volume = j.at("volume").get<std::string>();
        }
        if (j.contains("volume_fraction"))
        {
            answer.volume_fraction = j.at("volume_fraction").get<fraction>();
        }
    }

    void
    from_json(const nlohmann::json& j, trade_preimage_answer& answer)
    {
        extract_rpc_json_answer<trade_preimage_answer_success>(j, answer);
    }
} // namespace mm2::api