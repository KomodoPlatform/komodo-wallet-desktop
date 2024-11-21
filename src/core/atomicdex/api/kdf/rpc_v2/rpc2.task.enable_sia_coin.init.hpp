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

// Std Headers
#include <string>

// Deps Headers
#include <nlohmann/json_fwd.hpp>

//! Project Headers
#include "atomicdex/config/electrum.cfg.hpp"
#include "atomicdex/constants/qt.coins.enums.hpp"

namespace atomic_dex::kdf
{
    struct enable_sia_coin_request
    {
        std::string                               coin_name;
        std::string                               server_url;
        bool                                      with_tx_history{true};
    };

    struct enable_sia_coin_answer
    {
        int         task_id;
    };

    void to_json(nlohmann::json& j, const enable_sia_coin_request& request);
    void from_json(const nlohmann::json& j, enable_sia_coin_answer& answer);
}

namespace atomic_dex
{
    using t_enable_sia_coin_request = kdf::enable_sia_coin_request;
    using t_enable_sia_coin_answer = kdf::enable_sia_coin_answer;
} // namespace atomic_dex
