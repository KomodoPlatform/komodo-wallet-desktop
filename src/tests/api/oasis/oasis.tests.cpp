#include "atomicdex/pch.hpp"

//! STD
#include <iostream>

//! Deps
#include "doctest/doctest.h"
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/oasis/hashed.time.lock.contract.hpp"
#include "atomicdex/api/oasis/oasis.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

const nlohmann::json g_oasis_htlc_example = R"(
{
  "asset": "EUR",
  "amount": 815.17,
  "beneficiary": {
    "kty": "EC",
    "crv": "P-256",
    "x": "MKBCTNIcKUSDii11ySs3526iDZ8AiTo7Tu6KPAqv7D4",
    "y": "4Etl6SRW2YiLUrN5vfvVHuhp7x8PxltmWWlbbM4IFyM"
  },
  "hash": {
    "algorithm": "sha256",
    "value": "Pyx8yumK-B5EwOxBlln1DYt9SMaB5dV_x0fQRh5C3aE="
  },
  "preimage": {
    "size": 32
  },
  "expires": "2019-11-29T08:22:52Z",
  "includeFee": false
}
                                )"_json;

TEST_CASE("atomic_dex::oasis::api::hashed_timed_lock_contract serialization")
{
    //!
    using namespace atomic_dex;
    using b = oasis::api::t_beneficiary;
    oasis::api::hashed_timed_lock_contract htlc{
        .asset       = "EUR",
        .amount      = 815.17,
        .beneficiary = b{.kty = "EC", .crv = "P-256", .x = "MKBCTNIcKUSDii11ySs3526iDZ8AiTo7Tu6KPAqv7D4", .y = "4Etl6SRW2YiLUrN5vfvVHuhp7x8PxltmWWlbbM4IFyM"},
        .hash        = oasis::api::hash{.algorithm = "sha256", .value = "Pyx8yumK-B5EwOxBlln1DYt9SMaB5dV_x0fQRh5C3aE="},
        .preimage    = oasis::api::preimage{.size = 32},
        .expires     = "2019-11-29T08:22:52Z",
        .include_fee = false};
    nlohmann::json serialized_htlc;
    oasis::api::to_json(serialized_htlc, htlc);
    CHECK_EQ(serialized_htlc, htlc);
}

TEST_CASE("create an HTLC contract")
{
    //!
    using namespace atomic_dex;
    using b = oasis::api::t_beneficiary;
    using namespace std::chrono_literals;
    auto                                   t = date::make_zoned(date::current_zone(), std::chrono::system_clock::now() + 5min);
    oasis::api::hashed_timed_lock_contract htlc{
        .asset       = "EUR",
        .amount      = 400,
        .beneficiary = b{.x = "MKBCTNIcKUSDii11ySs3526iDZ8AiTo7Tu6KPAqv7D4", .y = "4Etl6SRW2YiLUrN5vfvVHuhp7x8PxltmWWlbbM4IFyM"},
        .hash        = oasis::api::hash{.algorithm = "sha256", .value = "Pyx8yumK-B5EwOxBlln1DYt9SMaB5dV_x0fQRh5C3aE="},
        .preimage    = oasis::api::preimage{.size = 32},
        .expires     = date::format("%FT%TZ", t),
        .include_fee = true};
    const auto resp = oasis::api::create_htlc(std::move(htlc)).get();
    auto       body = TO_STD_STR(resp.extract_string(true).get());
    CHECK_EQ(resp.status_code(), 200);
    SPDLOG_INFO("body: {}", body);
    nlohmann::json                         j = nlohmann::json::parse(body);
    oasis::api::hashed_timed_lock_contract resp_htlc;
    CHECK_NOTHROW(oasis::api::from_json(j, resp_htlc));
    CHECK_EQ(resp_htlc.status, "pending");
    CHECK(resp_htlc.clearing.has_value());
    CHECK_EQ(resp_htlc.clearing.value().status, "waiting");
}
