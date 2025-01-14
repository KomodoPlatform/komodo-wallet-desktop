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
#include <optional>
#include <string>

namespace atomic_dex
{
    struct node
    {
        std::string                     url;
        std::optional<bool>             komodo_proxy{false};
    };

    void to_json(nlohmann::json& j, const node& cfg);
    void from_json(const nlohmann::json& j, node& cfg);
}