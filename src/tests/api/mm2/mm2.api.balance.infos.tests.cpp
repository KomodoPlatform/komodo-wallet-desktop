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

//! Deps
#include "doctest/doctest.h"
#include <nlohmann/json.hpp>

#include "atomicdex/api/mm2/balance.infos.hpp"

TEST_CASE("mm2::balance_infos deserialization")
{
    const nlohmann::json json = R"(
    {
       "balances":{
           "spendable":"0.11398301",
           "unspendable":"0.00001"
       }
    })"_json;
    atomic_dex::mm2::balance_infos infos;
    atomic_dex::mm2::from_json(json.at("balances"), infos);
    CHECK_EQ(infos.spendable, "0.11398301");
    CHECK_EQ(infos.unspendable, "0.00001");
}