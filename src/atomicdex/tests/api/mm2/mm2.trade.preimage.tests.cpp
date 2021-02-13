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

//! Constants
namespace
{
    const nlohmann::json g_preimage_request_buy_kmd_btc = R"(
                                    {
                                        "base": "KMD",
                                        "rel": "BTC",
                                        "swap_method": "buy",
                                        "volume": "10"
                                    }
                                    )"_json;
    const nlohmann::json g_coin_fee_answer              = R"(
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
    const nlohmann::json g_preimage_answer_success_buy  = R"(
                                     {
                                        "base_coin_fee": {
                                          "amount":"0",
                                          "amount_fraction":{
                                            "denom":"1",
                                            "numer":"0"
                                          },
                                          "amount_rat":[[0,[]],[1,[1]]],
                                          "coin":"BTC"
                                        },
                                        "rel_coin_fee": {
                                          "amount":"0.0001",
                                          "amount_fraction":{
                                            "denom":"10000",
                                            "numer":"1"
                                          },
                                          "amount_rat":[[1,[1]],[1,[10000]]],
                                          "coin":"RICK"
                                        },
                                        "taker_fee":"0.00012870012870012872",
                                        "taker_fee_fraction":{
                                          "denom":"7770",
                                          "numer":"1"
                                        },
                                        "taker_rat":[[1,[1]],[1,[7770]]],
                                        "fee_to_send_taker_fee":{
                                          "amount":"0.0001",
                                          "amount_fraction":{
                                            "denom":"10000",
                                            "numer":"1"
                                          },
                                          "amount_rat":[[1,[1]],[1,[10000]]],
                                          "coin":"RICK"
                                        }
                                    }
                                    )"_json;
    const nlohmann::json g_preimage_answer_setprice     = R"(
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
    const nlohmann::json g_preimage_answer_buy          = R"(
                                    {
                                      "result":{
                                        "base_coin_fee": {
                                          "amount":"0",
                                          "amount_fraction":{
                                            "denom":"1",
                                            "numer":"0"
                                          },
                                          "amount_rat":[[0,[]],[1,[1]]],
                                          "coin":"BTC"
                                        },
                                        "rel_coin_fee": {
                                          "amount":"0.0001",
                                          "amount_fraction":{
                                            "denom":"10000",
                                            "numer":"1"
                                          },
                                          "amount_rat":[[1,[1]],[1,[10000]]],
                                          "coin":"RICK"
                                        },
                                        "taker_fee":"0.00012870012870012872",
                                        "taker_fee_fraction":{
                                          "denom":"7770",
                                          "numer":"1"
                                        },
                                        "taker_rat":[[1,[1]],[1,[7770]]],
                                        "fee_to_send_taker_fee":{
                                          "amount":"0.0001",
                                          "amount_fraction":{
                                            "denom":"10000",
                                            "numer":"1"
                                          },
                                          "amount_rat":[[1,[1]],[1,[10000]]],
                                          "coin":"RICK"
                                        }
                                      }
                                    }
                                    )"_json;
} // namespace

TEST_CASE("mm2::api::preimage_request serialisation")
{
    atomic_dex::t_trade_preimage_request request{.base_coin = "KMD", .rel_coin = "BTC", .swap_method = "buy", .volume = "10"};
    nlohmann::json                       j;
    mm2::api::to_json(j, request);
    CHECK_EQ(j, g_preimage_request_buy_kmd_btc);
}

TEST_CASE("mm2::api::coin_fee deserialization")
{
    mm2::api::coin_fee answer;
    mm2::api::from_json(g_coin_fee_answer, answer);
    CHECK_EQ("0.00042049", answer.amount);
    CHECK_EQ("BTC", answer.coin);
    CHECK_EQ("100000000", answer.amount_fraction.denom);
}

TEST_CASE("mm2::api::preimage_answer_success deserialization from buy")
{
    mm2::api::trade_preimage_answer_success answer;
    mm2::api::from_json(g_preimage_answer_success_buy, answer);
    CHECK(answer.taker_fee.has_value());
    CHECK(answer.taker_fee_fraction.has_value());
    CHECK(answer.fee_to_send_taker_fee.has_value());
    CHECK_FALSE(answer.volume.has_value());
}

TEST_SUITE("mm2::api::preimage_answer deserialization test suites")
{
    TEST_CASE("setprice BTC/RICK")
    {
        atomic_dex::t_trade_preimage_answer answer;
        mm2::api::from_json(g_preimage_answer_setprice, answer);
        CHECK(answer.result.has_value());
        CHECK_FALSE(answer.error.has_value());
        CHECK_FALSE(answer.result.value().volume.has_value());
        CHECK_FALSE(answer.result.value().fee_to_send_taker_fee.has_value());
    }

    TEST_CASE("buy BTC/RICK")
    {
        atomic_dex::t_trade_preimage_answer answer;
        mm2::api::from_json(g_preimage_answer_buy, answer);
        CHECK(answer.result.has_value());
        CHECK_FALSE(answer.error.has_value());
        CHECK_FALSE(answer.result.value().volume.has_value());
        CHECK(answer.result.value().fee_to_send_taker_fee.has_value());
    }
}