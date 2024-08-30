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
#include "doctest/doctest.h"
#include <nlohmann/json.hpp>

#include "atomicdex/api/kdf/balance_infos.hpp"

TEST_CASE("kdf::balance_infos deserialization")
{
    const nlohmann::json json = R"(
    {
       "balances":{
           "spendable":"0.11398301",
           "unspendable":"0.00001"
       }
    })"_json;
    atomic_dex::kdf::balance_infos infos;
    atomic_dex::kdf::from_json(json.at("balances"), infos);
    CHECK_EQ(infos.spendable, "0.11398301");
    CHECK_EQ(infos.unspendable, "0.00001");
}