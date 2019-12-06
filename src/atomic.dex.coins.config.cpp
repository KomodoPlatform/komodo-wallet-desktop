/******************************************************************************
 * Copyright © 2013-2019 The Komodo Platform Developers.                      *
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

#include <loguru.hpp>
#include "atomic.dex.coins.config.hpp"

namespace atomic_dex {
    void to_json(nlohmann::json &j, const atomic_dex::electrum_server &cfg) {
        LOG_SCOPE_FUNCTION(INFO);
        j["url"] = cfg.url;
        if (cfg.protocol.has_value()) {
            j["protocol"] = cfg.protocol.value();
        }
        if (cfg.disable_cert_verification.has_value()) {
            j["disable_cert_verification"] = cfg.disable_cert_verification.value();
        }
    }
}
