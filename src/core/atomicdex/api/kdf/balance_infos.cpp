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

// Project Headers
#include "balance_infos.hpp"

namespace atomic_dex::kdf
{
    void
    from_json(const nlohmann::json& j, balance_infos& answer)
    {
        answer.spendable = j.at("spendable").get<std::string>();
        answer.unspendable = j.at("unspendable").get<std::string>();
    }
} // namespace atomic_dex::kdf