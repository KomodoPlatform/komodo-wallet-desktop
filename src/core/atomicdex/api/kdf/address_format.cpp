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

//! Dependencies Headers
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/kdf/address_format.hpp"

namespace atomic_dex::kdf
{
    void
    to_json(nlohmann::json& j, const address_format_t& req)
    {
        j["format"] = req.format;
        if (req.network.has_value())
        {
            j["network"] = req.network.value();
        }
    }

    void
    from_json(const nlohmann::json& j, address_format_t& resp)
    {
        resp.format  = j.at("format").get<std::string>();
        if (j.contains("network"))
        {
            resp.network = j.at("network").get<std::string>();
        }
        
    }
} // namespace atomic_dex::kdf