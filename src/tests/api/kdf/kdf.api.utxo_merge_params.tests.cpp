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

#include "atomicdex/api/kdf/utxo_merge_params.hpp"

TEST_CASE("kdf::utxo_merge_params serialisation")
{
    const nlohmann::json     expected_json = R"(
    {
      "merge_at":50,
      "check_every":10,
      "max_merge_at_once":25
    }
    )"_json;
    atomic_dex::kdf::utxo_merge_params_t request{.merge_at = 50, .check_every = 10, .max_merge_at_once = 25};
    nlohmann::json           j;
    atomic_dex::kdf::to_json(j, request);
    CHECK_EQ(j, expected_json);
}