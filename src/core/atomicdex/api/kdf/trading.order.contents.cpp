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

//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include <atomicdex/api/kdf/trading.order.contents.hpp>

namespace atomic_dex::kdf
{
    void
    from_json(const nlohmann::json& j, trading_order_contents& contents)
    {
        j.at("base").get_to(contents.base);
        j.at("base_amount").get_to(contents.base_amount);
        j.at("rel").get_to(contents.rel);
        j.at("rel_amount").get_to(contents.rel_amount);
        j.at("method").get_to(contents.method);
        j.at("action").get_to(contents.action);
        j.at("uuid").get_to(contents.uuid);
        j.at("sender_pubkey").get_to(contents.sender_pubkey);
        j.at("dest_pub_key").get_to(contents.dest_pub_key);
    }
}