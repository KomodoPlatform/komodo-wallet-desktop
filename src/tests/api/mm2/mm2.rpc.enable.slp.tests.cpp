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

#include "atomicdex/api/mm2/mm2.hpp"
#include "atomicdex/api/mm2/rpc.enable.slp.hpp"

TEST_CASE("mm2::api::enable_slp serialisation activation params")
{
    const nlohmann::json        expected_json = R"(
    {
        "required_confirmations": 4
    }
    )"_json;
    mm2::api::slp_activation_params request{.required_confirmations = 4};
    nlohmann::json              j;
    mm2::api::to_json(j, request);
    CHECK_EQ(j, expected_json);
}

TEST_CASE("mm2::api::enable_slp serialisation")
{
    const nlohmann::json        expected_json = R"(
    {
        "method":"enable_slp",
        "mmrpc":"2.0",
        "userpass":"",
        "params":{
            "ticker":"USDF",
            "activation_params": {
              "required_confirmations": 4
            }
        }
    }
    )"_json;
    mm2::api::enable_slp_request request{.ticker = "USDF", .activation_params = mm2::api::slp_activation_params{.required_confirmations = 4}};
    nlohmann::json              j = mm2::api::template_request("enable_slp", true);
    mm2::api::to_json(j, request);
    CHECK_EQ(j, expected_json);
}

TEST_CASE("mm2::api::enable_slp deserialization")
{
    const nlohmann::json        json = R"(
    {
            "mmrpc":"2.0",
            "result":{
            "balances":{
              "slptest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsg8lecug8":{
                "spendable":"5.2974",
                "unspendable":"0"
              }
            },
            "token_id":"bb309e48930671582bea508f9a1d9b491e49b69be3d6f372dc08da2ac6e90eb7",
            "platform_coin":"tBCH",
            "required_confirmations":3
            },
            "id":null
    }
    )"_json;
    mm2::api::enable_slp_answer answer;
    mm2::api::from_json(json, answer);
    CHECK_EQ(answer.error.has_value(), false);
    CHECK_EQ(answer.result.has_value(), true);
    CHECK_EQ(answer.result.value().balances.size(), 1);
    CHECK_EQ(answer.result.value().platform_coin, "tBCH");
    CHECK_EQ(answer.result.value().required_confirmations, 3);
}

TEST_CASE("mm2::api::enable_slp : deserialization error answer")
{
    const nlohmann::json json = R"(
        {
            "mmrpc":"2.0",
            "error":"Platform coin tBCH is not activated",
            "error_path":"token.lp_coins",
            "error_trace":"token:102] lp_coins:1924]",
            "error_type":"PlatformCoinIsNotActivated",
            "error_data":"tBCH",
            "id":null
        }
    )"_json;
    mm2::api::enable_slp_answer data;
    mm2::api::from_json(json, data);
    CHECK_EQ(data.error.has_value(), true);
    CHECK_EQ(data.result.has_value(), false);
    CHECK_EQ(data.error.value().error, "Platform coin tBCH is not activated");
    CHECK_EQ(data.error.value().error_path, "token.lp_coins");
    CHECK_EQ(data.error.value().error_trace, "token:102] lp_coins:1924]");
    CHECK_EQ(data.error.value().error_type, "PlatformCoinIsNotActivated");
}