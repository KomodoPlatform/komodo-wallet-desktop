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

#pragma once

#include <optional>

//! Deps
#include <nlohmann/json_fwd.hpp>

namespace atomic_dex::kdf
{
    struct order_contents
    {
        std::string                coin;
        std::string                address;
        std::string                price;
        std::string                price_fraction_numer;
        std::string                price_fraction_denom;
        std::string                min_volume;
        std::string                min_volume_fraction_numer;
        std::string                min_volume_fraction_denom;
        std::string                max_volume;
        std::string                max_volume_fraction_numer;
        std::string                max_volume_fraction_denom;
        std::string                base_min_volume;
        std::string                base_min_volume_denom;
        std::string                base_min_volume_numer;
        std::string                base_max_volume;
        std::string                base_max_volume_denom;
        std::string                base_max_volume_numer;
        std::string                rel_min_volume;
        std::string                rel_min_volume_denom;
        std::string                rel_min_volume_numer;
        std::string                rel_max_volume;
        std::string                rel_max_volume_denom;
        std::string                rel_max_volume_numer;
        std::string                pubkey;
        //std::size_t                age;
        //std::size_t                zcredits;
        std::string                total;
        std::string                uuid;
        std::string                depth_percent;
        bool                       is_mine;
        std::optional<std::string> rel_coin;

        std::string to_string() const noexcept;
    };

    void from_json(const nlohmann::json& j, order_contents& contents);
} // namespace atomic_dex::kdf

namespace atomic_dex
{
    using t_order_contents  = kdf::order_contents;
    using t_orders_contents = std::vector<t_order_contents>;
} // namespace atomic_dex
