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


#pragma once

//! STD
#include <optional>
#include <string>

namespace atomic_dex
{
    struct electrum_server
    {
        std::string                url;
        std::optional<std::string> protocol{"TCP"};
        std::optional<std::string> ws_url;
        std::optional<bool>        disable_cert_verification{false};
    };

    void to_json(nlohmann::json& j, const electrum_server& cfg);
    void from_json(const nlohmann::json& j, electrum_server& cfg);
}