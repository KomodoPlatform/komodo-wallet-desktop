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

//! STD
#include <string>
#include <optional>

//! Deps
#include <nlohmann/json_fwd.hpp>

namespace atomic_dex::kdf
{
    struct setprice_request
    {
        std::string                base;
        std::string                rel;
        std::string                price;
        std::string                volume;
        std::optional<bool>        cancel_previous{false};
        std::optional<bool>        base_nota;
        std::optional<std::size_t> base_confs;
        std::optional<bool>        rel_nota;
        std::optional<std::size_t> rel_confs;
        std::optional<std::string> min_volume;
    };

    void to_json(nlohmann::json& j, const setprice_request& request);
}

namespace atomic_dex
{
    using t_setprice_request        = kdf::setprice_request;
}