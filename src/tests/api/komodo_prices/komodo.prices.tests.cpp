//
// Created by Sztergbaum Roman on 10/09/2021.
//

#include "atomicdex/pch.hpp"

//! STD
#include <iostream>

//! Deps
#include "doctest/doctest.h"

//! Project Headers
#include "atomicdex/api/komodo_prices/komodo.prices.hpp"

TEST_CASE("komodo prices api test")
{
    auto resp = atomic_dex::komodo_prices::api::async_market_infos().get();
    std::string body = TO_STD_STR(resp.extract_string(true).get());
    CHECK_EQ(resp.status_code(), 200);
    CHECK_FALSE(body.empty());
}