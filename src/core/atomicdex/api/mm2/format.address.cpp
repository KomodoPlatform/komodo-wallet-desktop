/******************************************************************************
 * Copyright © 2013-2022 The Komodo Platform Developers.                      *
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

//! Dependencies Headers
#include <nlohmann/json.hpp>

//! Project Headers
#include "format.address.hpp"

namespace atomic_dex::mm2
{
    void
    to_json(nlohmann::json& j, const format_address& cfg)
    {
        j["format"] = cfg.format;
        j["network"] = cfg.network;
    }
} // namespace atomic_dex::mm2