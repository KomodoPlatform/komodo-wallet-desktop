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
#include "atomicdex/api/mm2/trade.preimage.hpp"

TEST_CASE("mm2::api::preimage_request serialisation")
{
    atomic_dex::t_trade_preimage_request request{.base_coin = "KMD", .rel_coin = "BTC", .swap_method = "buy", .volume = "10"};
    nlohmann::json                       j;
    mm2::api::to_json(j, request);
    nlohmann::json expected_json = R"(
                                    {
                                        "base": "KMD",
                                        "rel": "BTC",
                                        "swap_method": "buy",
                                        "volume": "10"
                                    }
                                    )"_json;
    CHECK_EQ(j, expected_json);
}

TEST_CASE("mm2::api::coin_fee deserialization")
{
    nlohmann::json     answer_json = R"(
    {
        "amount":"0.00042049",
        "amount_fraction":{
            "denom":"100000000",
            "numer":"42049"
          },
        "amount_rat":[[1,[42049]],[1,[100000000]]],
        "coin":"BTC"
    }
    )"_json;
    mm2::api::coin_fee answer;
    mm2::api::from_json(answer_json, answer);
    CHECK_EQ("0.00042049", answer.amount);
    CHECK_EQ("BTC", answer.coin);
    CHECK_EQ("100000000", answer.amount_fraction.denom);
}

TEST_CASE("mm2::api::preimage_answer deserialization from setprice")
{
    nlohmann::json answer_json = R"(
    {
      "result":{
        "base_coin_fee": {
          "amount":"0.00042049",
          "amount_fraction":{
            "denom":"100000000",
            "numer":"42049"
          },
          "amount_rat":[[1,[42049]],[1,[100000000]]],
          "coin":"BTC"
        },
        "rel_coin_fee": {
          "amount":"0",
          "amount_fraction":{
            "denom":"1",
            "numer":"0"
          },
          "amount_rat":[[0,[]],[1,[1]]],
          "coin":"RICK"
        }
      }
    }
    )"_json;
}