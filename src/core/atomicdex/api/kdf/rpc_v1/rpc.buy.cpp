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
#include <spdlog/spdlog.h>

//! Project Headers
#include "atomicdex/api/kdf/generics.hpp"
#include "atomicdex/api/kdf/rpc_v1/rpc.buy.hpp"

namespace atomic_dex::kdf
{
    void
    from_json(const nlohmann::json& j, buy_answer_success& contents)
    {
        j.get_to(contents.contents);
    }

    void
    from_json(const nlohmann::json& j, buy_answer& answer)
    {
        extract_rpc_json_answer<buy_answer_success>(j, answer);
    }

    void
    to_json(nlohmann::json& j, const buy_request& request)
    {
        j["base"]   = request.base;
        j["price"]  = request.price;
        j["rel"]    = request.rel;
        j["volume"] = request.volume;
        if (request.min_volume.has_value())
        {
            j["min_volume"] = request.min_volume.value();
        }
        if (request.base_nota.has_value())
        {
            j["base_nota"] = request.base_nota.value();
        }
        if (request.base_confs.has_value())
        {
            j["base_confs"] = request.base_confs.value();
        }
        if (not request.is_created_order)
        {
            //! From orderbook
            nlohmann::json price_fraction_repr  = nlohmann::json::object();
            price_fraction_repr["numer"]        = request.price_numer;
            price_fraction_repr["denom"]        = request.price_denom;
            j["price"]                          = price_fraction_repr;
            nlohmann::json volume_fraction_repr = nlohmann::json::object();
            if (not request.selected_order_use_input_volume)
            {
                volume_fraction_repr["numer"] = request.volume_numer;
                volume_fraction_repr["denom"] = request.volume_denom;
                j["volume"]                   = volume_fraction_repr;
            }
            SPDLOG_INFO("The order is picked from the orderbook price: {}, volume: {}", j.at("price").dump(4), j.at("volume").dump(4));
        }
        else
        {
            SPDLOG_INFO("The order is not picked from orderbook we create it from volume = {}, price = {}", j.at("volume").dump(4), request.price);
        }
        if (request.order_type.has_value())
        {
            j["order_type"] = request.order_type.value();
        }
    }
} // namespace atomic_dex::kdf