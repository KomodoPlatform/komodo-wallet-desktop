/******************************************************************************
 * Copyright © 2013-2019 The Komodo Platform Developers.                      *
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
 
#include <doctest/doctest.h>
#include <nlohmann/json.hpp>

#include "atomicdex/config/wallet.cfg.hpp"

TEST_CASE("Load a wallet cfg from json")
{
    atomic_dex::wallet_cfg config;
    const auto             data = nlohmann::json::parse(R"(
    {
        "name": "jack"
        "addressbook_contacts":
        [
            {
                "name": "syl",
                "categories": ["Developer", "C++ lover"],
                "wallets_info":
                [
                    {
                        "type": "BTC",
                        "addresses": { "Wallet of home computer": "some address", "Binance wallet": "another address" }
                    },
                    {
                        "type": "erc-20",
                        "addresses": { "My valid erc-20 address": "erc20 address" }
                    }
                ]
            },
            {
                "name": "Daxter",
                "categories": ["Friend"],
                "wallets_info":
                [
                    {
                        "type": "ETH",
                        "addresses": { "My eth wallet": "An eth waddress" }
                    },
                    {
                        "type": "BTC",
                        "addresses": { "My btc wallet": "A btc address" }
                    }
                ]
            }
        ]
    })");
    
    atomic_dex::from_json(data, config);
    CHECK(config.addressbook_contacts.size() == 2);
    SUBCASE("Test first contact")
    {
        CHECK(config.addressbook_contacts[0].name == "syl");
        CHECK(config.addressbook_contacts[0].categories.size() == 2);
        CHECK(config.addressbook_contacts[0].categories[0] == "Developer");
        CHECK(config.addressbook_contacts[0].categories[1] == "C++ lover");
        CHECK(config.addressbook_contacts[0].wallets_info.size() == 2);
        CHECK(config.addressbook_contacts[0].wallets_info[0].type == "BTC");
        CHECK(config.addressbook_contacts[0].wallets_info[0].addresses.size() == 2);
        CHECK(config.addressbook_contacts[0].wallets_info[0].addresses["Wallet of home computer"] == "some address");
        CHECK(config.addressbook_contacts[0].wallets_info[0].addresses["Binance wallet"] == "another address");
        CHECK(config.addressbook_contacts[0].wallets_info[1].type == "erc-20");
        CHECK(config.addressbook_contacts[0].wallets_info[1].addresses.size() == 1);
        CHECK(config.addressbook_contacts[0].wallets_info[1].addresses["My valid erc-20 address"] == "erc20 address");
    }
    SUBCASE("Test second contact")
    {
        CHECK(config.addressbook_contacts[0].name == "Daxter");
        CHECK(config.addressbook_contacts[0].categories.size() ==1);
        CHECK(config.addressbook_contacts[0].categories[0] == "Friend");
        CHECK(config.addressbook_contacts[0].wallets_info.size() == 2);
        CHECK(config.addressbook_contacts[0].wallets_info[0].type == "ETH");
        CHECK(config.addressbook_contacts[0].wallets_info[0].addresses.size() == 1);
        CHECK(config.addressbook_contacts[0].wallets_info[0].addresses["My eth wallet"] == "An eth address");
        CHECK(config.addressbook_contacts[0].wallets_info[1].type == "BTC");
        CHECK(config.addressbook_contacts[0].wallets_info[1].addresses.size() == 1);
        CHECK(config.addressbook_contacts[0].wallets_info[1].addresses["My btc wallet"] == "A btc address");
    }
}