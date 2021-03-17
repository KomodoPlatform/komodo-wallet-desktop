#include "atomicdex/pch.hpp"

//! STD
#include <iostream>

//! Deps
#include "doctest/doctest.h"

//! Project Headers
#include "atomicdex/api/coingecko/coingecko.hpp"


TEST_CASE("test to coingecko uri from market infos request")
{
    atomic_dex::t_coingecko_market_infos_request request{.ids = {{"bitcoin"}, {"komodo"}}};
    std::string res = atomic_dex::coingecko::api::to_coingecko_uri(std::move(request));
    CHECK_EQ("/coins/markets?vs_currency=usd&ids=bitcoin,komodo&order=market_cap_desc&sparkline=true&price_change_percentage=24h", res);
}

TEST_CASE("api test")
{
    atomic_dex::t_coingecko_market_infos_request request{.ids = {{"bitcoin"}, {"komodo"}}};
    auto resp = atomic_dex::coingecko::api::async_market_infos(std::move(request)).get();
    std::string body = TO_STD_STR(resp.extract_string(true).get());
    SPDLOG_INFO("resp: {}", body);
    CHECK_EQ(resp.status_code(), 200);
    CHECK_FALSE(body.empty());
}