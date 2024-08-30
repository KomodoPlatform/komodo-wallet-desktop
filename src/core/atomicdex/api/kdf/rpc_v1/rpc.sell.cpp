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
#include "atomicdex/api/kdf/rpc_v1/rpc.sell.hpp"

namespace atomic_dex::kdf
{
    void
    to_json(nlohmann::json& j, const sell_request& request)
    {
        SPDLOG_DEBUG("price: {}, volume: {}", request.price, request.volume);

        auto volume_fraction_functor = [&request]() {
            nlohmann::json volume_fraction_repr = nlohmann::json::object();
            volume_fraction_repr["numer"]       = request.volume_numer;
            volume_fraction_repr["denom"]       = request.volume_denom;
            return volume_fraction_repr;
        };

        j["base"]   = request.base;
        j["rel"]    = request.rel;
        j["volume"] = request.volume; //< First take the user input
        if (request.is_max && !request.selected_order_use_input_volume)           //< It's a real max means user want to sell his base_max_taker_vol let's take the fraction repr
        {
            j["volume"] = volume_fraction_functor();
        }
        j["price"] = request.price;
        if (request.min_volume.has_value())
        {
            j["min_volume"] = request.min_volume.value();
        }
        if (request.rel_nota.has_value())
        {
            j["rel_nota"] = request.rel_nota.value();
        }
        if (request.rel_confs.has_value())
        {
            j["rel_confs"] = request.rel_confs.value();
        }

        if (not request.is_created_order)
        {
            //! From orderbook
            nlohmann::json price_fraction_repr = nlohmann::json::object();
            price_fraction_repr["numer"]       = request.price_numer;
            price_fraction_repr["denom"]       = request.price_denom;
            j["price"]                         = price_fraction_repr;
            if (request.is_exact_selected_order_volume && !request.selected_order_use_input_volume)
            {
                j["volume"] = volume_fraction_functor();
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

    void
    from_json(const nlohmann::json& j, sell_answer_success& contents)
    {
        j.get_to(contents.contents);
    }

    void
    from_json(const nlohmann::json& j, sell_answer& answer)
    {
        extract_rpc_json_answer<sell_answer_success>(j, answer);
    }
} // namespace atomic_dex::kdf