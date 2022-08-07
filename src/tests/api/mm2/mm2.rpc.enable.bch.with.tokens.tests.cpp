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
#include "atomicdex/api/mm2/rpc.enable.bch.with.tokens.hpp"

TEST_CASE("mm2::api::enable_bch_with_tokens serialisation slp tickers with confirmations")
{
    const nlohmann::json        expected_json = R"(
    {
        "ticker":"USDF",
        "required_confirmations": 4
    }
    )"_json;
    mm2::api::slp_token_request request{.ticker = "USDF", .required_confirmations = 4};
    nlohmann::json              j;
    mm2::api::to_json(j, request);
    CHECK_EQ(j, expected_json);
}

TEST_CASE("mm2::api::enable_bch_with_tokens serialisation slp tickers without confirmations")
{
    const nlohmann::json        expected_json = R"(
    {
        "ticker":"USDF"
    }
    )"_json;
    mm2::api::slp_token_request request{.ticker = "USDF"};
    nlohmann::json              j;
    mm2::api::to_json(j, request);
    CHECK_EQ(j, expected_json);
}

TEST_CASE("mm2::api::enable_bch_with_tokens serialisation servers")
{
    const nlohmann::json      expected_json = R"(
   {
    "servers":[
      {
        "url":"electroncash.de:50003",
        "disable_cert_verification": false,
        "protocol":"TCP"
      },
      {
        "url":"tbch.loping.net:60001",
        "disable_cert_verification": false,
        "protocol":"TCP"
      },
      {
        "url":"blackie.c3-soft.com:60001",
        "disable_cert_verification": false,
        "protocol":"TCP"
      },
      {
        "url":"bch0.kister.net:51001",
        "disable_cert_verification": false,
        "protocol":"TCP"
      },
      {
        "url":"testnet.imaginary.cash:50001",
        "disable_cert_verification": false,
        "protocol":"TCP"
      }
    ]
   }
    )"_json;
    mm2::api::enable_rpc_data request{
        .servers = {
            atomic_dex::electrum_server{.url = "electroncash.de:50003"}, atomic_dex::electrum_server{.url = "tbch.loping.net:60001"},
            atomic_dex::electrum_server{.url = "blackie.c3-soft.com:60001"}, atomic_dex::electrum_server{.url = "bch0.kister.net:51001"},
            atomic_dex::electrum_server{.url = "testnet.imaginary.cash:50001"}}};
    nlohmann::json j;
    mm2::api::to_json(j, request);
    CHECK_EQ(j, expected_json);
}

TEST_CASE("mm2::api::enable_bch_with_tokens serialisation mode")
{
    const nlohmann::json      expected_json = R"(
    {
            "rpc":"Electrum",
            "rpc_data":{
                "servers":[
                  {
                    "url":"electroncash.de:50003",
                    "disable_cert_verification": false,
                    "protocol":"TCP"
                  },
                  {
                    "url":"tbch.loping.net:60001",
                    "disable_cert_verification": false,
                    "protocol":"TCP"
                  },
                  {
                    "url":"blackie.c3-soft.com:60001",
                    "disable_cert_verification": false,
                    "protocol":"TCP"
                  },
                  {
                    "url":"bch0.kister.net:51001",
                    "disable_cert_verification": false,
                    "protocol":"TCP"
                  },
                  {
                    "url":"testnet.imaginary.cash:50001",
                    "disable_cert_verification": false,
                    "protocol":"TCP"
                  }
                ]
            }
    }
    )"_json;
    mm2::api::enable_rpc_data enable_rpc_data{
        .servers = {
            atomic_dex::electrum_server{.url = "electroncash.de:50003"}, atomic_dex::electrum_server{.url = "tbch.loping.net:60001"},
            atomic_dex::electrum_server{.url = "blackie.c3-soft.com:60001"}, atomic_dex::electrum_server{.url = "bch0.kister.net:51001"},
            atomic_dex::electrum_server{.url = "testnet.imaginary.cash:50001"}}};
    mm2::api::enable_mode request{.rpc = "Electrum", .rpc_data = std::move(enable_rpc_data)};
    nlohmann::json        j;
    mm2::api::to_json(j, request);
    CHECK_EQ(j, expected_json);
}

TEST_CASE("mm2::api::enable_bch_with_tokens serialisation")
{
    const nlohmann::json expected_json = R"(
    {
        "method":"enable_bch_with_tokens",
        "mmrpc":"2.0",
        "userpass":"",
        "params": {
            "allow_slp_unsafe_conf": false,
            "bchd_urls": [
                "https://bchd-testnet.greyh.at:18335"
            ],
            "mode": {
                "rpc": "Electrum",
                "rpc_data": {
                "servers": [
                      {
                        "disable_cert_verification": false,
                        "protocol": "TCP",
                        "url": "electroncash.de:50003"
                      },
                      {
                        "disable_cert_verification": false,
                        "protocol": "TCP",
                        "url": "tbch.loping.net:60001"
                      },
                      {
                        "disable_cert_verification": false,
                        "protocol": "TCP",
                        "url": "blackie.c3-soft.com:60001"
                      },
                      {
                        "disable_cert_verification": false,
                        "protocol": "TCP",
                        "url": "bch0.kister.net:51001"
                      },
                      {
                        "disable_cert_verification": false,
                        "protocol": "TCP",
                        "url": "testnet.imaginary.cash:50001"
                      }
                    ]
                }
            },
            "slp_tokens_requests": [
                {
                "required_confirmations": 4,
                "ticker": "USDF"
                }
            ],
            "ticker": "tBCH",
            "tx_history": true
        }
    }
    )"_json;

    nlohmann::json            j         = mm2::api::template_request("enable_bch_with_tokens", true);
    std::vector<std::string>  bchd_urls = std::vector<std::string>{"https://bchd-testnet.greyh.at:18335"};
    mm2::api::enable_rpc_data enable_rpc_data{
        .servers = {
            atomic_dex::electrum_server{.url = "electroncash.de:50003"}, atomic_dex::electrum_server{.url = "tbch.loping.net:60001"},
            atomic_dex::electrum_server{.url = "blackie.c3-soft.com:60001"}, atomic_dex::electrum_server{.url = "bch0.kister.net:51001"},
            atomic_dex::electrum_server{.url = "testnet.imaginary.cash:50001"}}};
    mm2::api::enable_mode                        mode{.rpc = "Electrum", .rpc_data = std::move(enable_rpc_data)};
    mm2::api::slp_token_request                  slp_tokens{.ticker = "USDF", .required_confirmations = 4};
    atomic_dex::t_enable_bch_with_tokens_request request{
        .ticker = "tBCH",
        .allow_slp_unsafe_conf = false,
        .bchd_urls = std::move(bchd_urls),
        .mode = std::move(mode),
        .tx_history = true, .slp_token_requests = {std::move(slp_tokens)}};
    mm2::api::to_json(j, request);
    CHECK_EQ(j, expected_json);
}

TEST_CASE("mm2::api::enable_bch_with_tokens deserialization derivation_type")
{
    const nlohmann::json json = R"(
    {
        "derivation_method":{
            "type":"Iguana"
        }
    })"_json;
    mm2::api::derivation_infos infos;
    mm2::api::from_json(json.at("derivation_method"), infos);
    CHECK_EQ(infos.type, "Iguana");
}

TEST_CASE("mm2::api::enable_bch_with_tokens deserialization bch address infos")
{
    const nlohmann::json json = R"(
    {
     "derivation_method":{
        "type":"Iguana"
     },
     "pubkey":"036879df230663db4cd083c8eeb0f293f46abc460ad3c299b0089b72e6d472202c",
     "balances":{
       "spendable":"0.11398301",
       "unspendable":"0.00001"
     }
    })"_json;
    mm2::api::bch_address_infos infos;
    mm2::api::from_json(json, infos);
    CHECK_EQ(infos.derivation_method.type, "Iguana");
    CHECK_EQ(infos.pubkey, "036879df230663db4cd083c8eeb0f293f46abc460ad3c299b0089b72e6d472202c");
    CHECK_EQ(infos.balances.spendable, "0.11398301");
}

TEST_CASE("mm2::api::enable_bch_with_tokens deserialization success answer")
{
    const nlohmann::json json = R"(
    {
        "current_block":1480481,
        "bch_addresses_infos":{
            "bchtest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsnnczzt66":{
                "derivation_method":{
                  "type":"Iguana"
                },
                "pubkey":"036879df230663db4cd083c8eeb0f293f46abc460ad3c299b0089b72e6d472202c",
                "balances":{
                  "spendable":"0.11398301",
                  "unspendable":"0.00001"
                }
            }
        },
        "slp_addresses_infos":{
            "slptest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsg8lecug8":{
                "derivation_method":{
                  "type":"Iguana"
                },
                "pubkey":"036879df230663db4cd083c8eeb0f293f46abc460ad3c299b0089b72e6d472202c",
                "balances":{
                  "USDF":{
                    "spendable":"5.2974",
                    "unspendable":"0"
                  }
                }
            }
        }
    })"_json;
    mm2::api::enable_bch_with_tokens_answer_success infos;
    mm2::api::from_json(json, infos);
    CHECK_EQ(infos.current_block, 1480481);
    CHECK_EQ(infos.bch_addresses_infos.at("bchtest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsnnczzt66").derivation_method.type, "Iguana");
    CHECK_EQ(infos.bch_addresses_infos.at("bchtest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsnnczzt66").pubkey, "036879df230663db4cd083c8eeb0f293f46abc460ad3c299b0089b72e6d472202c");
    CHECK_EQ(infos.bch_addresses_infos.at("bchtest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsnnczzt66").balances.spendable, "0.11398301");
    CHECK_EQ(infos.bch_addresses_infos.size(), 1);
    CHECK_EQ(infos.slp_addresses_infos.at("slptest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsg8lecug8").derivation_method.type, "Iguana");
    CHECK_EQ(infos.slp_addresses_infos.at("slptest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsg8lecug8").pubkey, "036879df230663db4cd083c8eeb0f293f46abc460ad3c299b0089b72e6d472202c");
    CHECK_EQ(infos.slp_addresses_infos.at("slptest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsg8lecug8").balances.at("USDF").spendable, "5.2974");
    CHECK_EQ(infos.slp_addresses_infos.size(), 1);
}

TEST_CASE("mm2::api::enable_bch_with_tokens deserialization answer")
{
    const nlohmann::json json = R"(
    {
        "mmrpc":"2.0",
        "id":null,
        "result":{
            "current_block":1480481,
            "bch_addresses_infos":{
                "bchtest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsnnczzt66":{
                    "derivation_method":{
                      "type":"Iguana"
                    },
                    "pubkey":"036879df230663db4cd083c8eeb0f293f46abc460ad3c299b0089b72e6d472202c",
                    "balances":{
                      "spendable":"0.11398301",
                      "unspendable":"0.00001"
                    }
                }
            },
            "slp_addresses_infos":{
                "slptest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsg8lecug8":{
                    "derivation_method":{
                      "type":"Iguana"
                    },
                    "pubkey":"036879df230663db4cd083c8eeb0f293f46abc460ad3c299b0089b72e6d472202c",
                    "balances":{
                      "USDF":{
                        "spendable":"5.2974",
                        "unspendable":"0"
                      }
                    }
                }
            }
        }
    })"_json;
    mm2::api::enable_bch_with_tokens_answer data;
    mm2::api::from_json(json, data);
    mm2::api::enable_bch_with_tokens_answer_success infos = data.result.value();
    CHECK_EQ(infos.current_block, 1480481);
    CHECK_EQ(infos.bch_addresses_infos.at("bchtest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsnnczzt66").derivation_method.type, "Iguana");
    CHECK_EQ(infos.bch_addresses_infos.at("bchtest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsnnczzt66").pubkey, "036879df230663db4cd083c8eeb0f293f46abc460ad3c299b0089b72e6d472202c");
    CHECK_EQ(infos.bch_addresses_infos.at("bchtest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsnnczzt66").balances.spendable, "0.11398301");
    CHECK_EQ(infos.bch_addresses_infos.size(), 1);
    CHECK_EQ(infos.slp_addresses_infos.at("slptest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsg8lecug8").derivation_method.type, "Iguana");
    CHECK_EQ(infos.slp_addresses_infos.at("slptest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsg8lecug8").pubkey, "036879df230663db4cd083c8eeb0f293f46abc460ad3c299b0089b72e6d472202c");
    CHECK_EQ(infos.slp_addresses_infos.at("slptest:qzx0llpyp8gxxsmad25twksqnwd62xm3lsg8lecug8").balances.at("USDF").spendable, "5.2974");
    CHECK_EQ(infos.slp_addresses_infos.size(), 1);
}

TEST_CASE("mm2::api::enable_bch_with_tokens deserialization error answer")
{
    const nlohmann::json json = R"(
        {
            "mmrpc":"2.0",
            "error":"tBCH",
            "error_path":"platform_coin_with_tokens",
            "error_trace":"platform_coin_with_tokens:281]",
            "error_type":"PlatformIsAlreadyActivated",
            "error_data":"tBCH",
            "id":null
        }
    )"_json;
    mm2::api::enable_bch_with_tokens_answer data;
    mm2::api::from_json(json, data);
    CHECK_EQ(data.error.has_value(), true);
    CHECK_EQ(data.result.has_value(), false);
    CHECK_EQ(data.error.value().error, "tBCH");
    CHECK_EQ(data.error.value().error_path, "platform_coin_with_tokens");
    CHECK_EQ(data.error.value().error_trace, "platform_coin_with_tokens:281]");
    CHECK_EQ(data.error.value().error_type, "PlatformIsAlreadyActivated");
}