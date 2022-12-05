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

//! Project Headers
#include "atomicdex/config/enable.cfg.hpp"

namespace atomic_dex
{
    void
    to_json(nlohmann::json& j, const node& cfg)
    {
        j["url"] = cfg.url;
        if (cfg.gui_auth.has_value())
        {
            j["gui_auth"] = cfg.gui_auth.value();
        }
    }

    void
    from_json(const nlohmann::json& j, node& cfg)
    {
        j.at("url").get_to(cfg.url);
        if (j.count("gui_auth") == 1)
        {
            cfg.gui_auth = j.at("gui_auth").get<bool>();
        }
    }
} // namespace atomic_dex