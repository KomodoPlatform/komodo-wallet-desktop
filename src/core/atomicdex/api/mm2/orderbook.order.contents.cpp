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
#include <boost/algorithm/string/trim.hpp>

//! Project Headers
#include "atomicdex/api/mm2/orderbook.order.contents.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

namespace mm2::api
{
    void
    from_json(const nlohmann::json& j, order_contents& contents)
    {
        //SPDLOG_INFO("contents: {}", j.dump(4));
        j.at("coin").get_to(contents.coin);
        j.at("address").get_to(contents.address);
        j.at("price").get_to(contents.price);
        // contents.price = t_float_50(contents.price).str(8, std::ios_base::fixed);
        j.at("price_fraction").at("numer").get_to(contents.price_fraction_numer);
        j.at("price_fraction").at("denom").get_to(contents.price_fraction_denom);
        j.at("max_volume_fraction").at("numer").get_to(contents.max_volume_fraction_numer);
        j.at("max_volume_fraction").at("denom").get_to(contents.max_volume_fraction_denom);

        j.at("base_min_volume_fraction").at("numer").get_to(contents.base_min_volume_numer);
        j.at("base_min_volume_fraction").at("denom").get_to(contents.base_min_volume_denom);
        j.at("base_max_volume_fraction").at("numer").get_to(contents.base_max_volume_numer);
        j.at("base_max_volume_fraction").at("denom").get_to(contents.base_max_volume_denom);
        j.at("rel_min_volume_fraction").at("numer").get_to(contents.rel_min_volume_numer);
        j.at("rel_min_volume_fraction").at("denom").get_to(contents.rel_min_volume_denom);
        j.at("rel_max_volume_fraction").at("numer").get_to(contents.rel_max_volume_numer);
        j.at("rel_max_volume_fraction").at("denom").get_to(contents.rel_max_volume_denom);

        j.at("maxvolume").get_to(contents.maxvolume);
        j.at("pubkey").get_to(contents.pubkey);
        j.at("age").get_to(contents.age);
        j.at("zcredits").get_to(contents.zcredits);
        j.at("uuid").get_to(contents.uuid);
        j.at("is_mine").get_to(contents.is_mine);
        if (j.contains("min_volume"))
        {
            contents.min_volume = j.at("min_volume").get<std::string>();
        }

        if (contents.price.find('.') != std::string::npos)
        {
            boost::trim_right_if(contents.price, boost::is_any_of("0"));
            contents.price = contents.price;
        }
        j.at("base_max_volume").get_to(contents.base_max_volume);
        j.at("base_min_volume").get_to(contents.base_min_volume);
        j.at("rel_max_volume").get_to(contents.rel_max_volume);
        j.at("rel_min_volume").get_to(contents.rel_min_volume);
        contents.maxvolume = atomic_dex::utils::adjust_precision(contents.maxvolume);
        t_float_50 total_f = safe_float(contents.price) * safe_float(contents.maxvolume);
        contents.total     = atomic_dex::utils::adjust_precision(total_f.str());
    }

    std::string
    order_contents::to_string() const noexcept
    {
        std::stringstream ss;
        ss << "coin: " << coin << " ";
        ss << "address: " << address << " ";
        ss << "price: " << price << " ";
        ss << "max_volume: " << maxvolume << " ";
        ss << "depth_percent: " << depth_percent << " ";
        ss << "base_max_volume: " << base_max_volume << " ";
        ss << "rel_max_volume: " << rel_max_volume << " ";
        ss << "base_min_volume: " << base_min_volume << " ";
        ss << "rel_min_volume: " << rel_min_volume << " ";
        return ss.str();
    }
} // namespace mm2::api