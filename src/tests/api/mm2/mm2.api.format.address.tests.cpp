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

#include "atomicdex/api/mm2/format.address.hpp"

TEST_CASE("mm2::address_format serialisation")
{
    const nlohmann::json     expected_json = R"(
    {
      "format":"cashaddress",
      "network":"bchtest"
    }
    )"_json;
    atomic_dex::mm2::format_address request{.format = "cashaddress", .network = "bchtest"};
    nlohmann::json j;
    
    atomic_dex::mm2::to_json(j, request);
    CHECK_EQ(j, expected_json);
}