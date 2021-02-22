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
#include "atomicdex/config/electrum.cfg.hpp"

namespace atomic_dex
{
    void
    to_json(nlohmann::json& j, const electrum_server& cfg)
    {
        j["url"] = cfg.url;
        if (cfg.protocol.has_value())
        {
            j["protocol"] = cfg.protocol.value();
        }
        if (cfg.disable_cert_verification.has_value())
        {
            j["disable_cert_verification"] = cfg.disable_cert_verification.value();
        }
    }

    void
    from_json(const nlohmann::json& j, electrum_server& cfg)
    {
        if (j.count("protocol") == 1)
        {
            cfg.protocol = j.at("protocol").get<std::string>();
        }
        if (j.count("disable_cert_verification") == 1)
        {
            cfg.disable_cert_verification = j.at("disable_cert_verification").get<bool>();
        }
        j.at("url").get_to(cfg.url);
    }
} // namespace atomic_dex