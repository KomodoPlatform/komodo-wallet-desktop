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

#include "atomicdex/api/kdf/address_format.hpp"

TEST_CASE("kdf::address_format serialisation")
{
    const nlohmann::json     expected_json = R"(
    {
      "format":"cashaddress",
      "network":"bchtest"
    }
    )"_json;
    atomic_dex::kdf::address_format_t req{.format = "cashaddress", .network = "bchtest"};
    nlohmann::json j;
    
    to_json(j, req);
    CHECK_EQ(j, expected_json);
}