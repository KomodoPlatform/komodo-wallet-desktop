#include "atomicdex/pch.hpp"

//! STD
#include <iostream>

//! Deps
#include "doctest/doctest.h"
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/oasis/hashed.time.lock.contract.hpp"

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
