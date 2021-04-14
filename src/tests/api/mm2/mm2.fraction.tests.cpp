//
// Created by Roman Szterg on 13/02/2021.
//

#include "atomicdex/pch.hpp"

//! STD
#include <iostream>

//! Deps
#include "doctest/doctest.h"
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/mm2/fraction.hpp"

TEST_CASE("mm2::api::fraction deserialisation")
{
    nlohmann::json fraction_json = R"(
                                    {
                                        "denom": "777",
                                        "numer": "333"
                                    }
                                    )"_json;
    mm2::api::fraction fraction;
    mm2::api::from_json(fraction_json, fraction);

    CHECK_EQ(fraction.numer, "333");
    CHECK_EQ(fraction.denom, "777");
}