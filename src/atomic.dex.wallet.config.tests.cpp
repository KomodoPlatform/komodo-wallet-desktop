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

#include "atomic.dex.wallet.config.hpp"
#include <doctest/doctest.h>

TEST_CASE("validate json serialization to cpp data structure (wallet_config)")
{
    auto                   j = R"(
              {
    "name": "roman",
    "addressbook": {
        "ca333": {
            "ERC-20": "0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae",
            "SmartChains": "RB49Rm4jBe5mN9anErvkzf3kcQCzHqyz3e",
            "BTC": "3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc5"
        },
        "alice": {
            "ERC-20": "0xde0b395669a9fd93d5f28d9ec85e40f4cb697bae",
            "SmartChains": "RB39Rm4jBe5mN9anErvkzf3kcQCzHqyz3e",
            "BTC": "3FZbgi30cpjq2GjdwV8eyHuJJnkLtktZc5"
        },
        "bob": {
            "ERC-20": "0xde0b393669a9fd93d5f28d9ec85e40f4cb697bae",
            "SmartChains": "RB39Rm6jBe5mN9anErvkzf3kcQCzHqyz3e",
            "BTC": "3FZbgi30cpjq3GjdwV8eyHuJJnkLtktZc5"
        }
    },
    "categories": {
        "friends": [
            "ca333"
        ],
        "pro": [
            "alice"
        ],
        "black_list": [
            "bob"
        ]
    }
}
            )"_json;
    atomic_dex::wallet_cfg cfg;
    atomic_dex::from_json(j, cfg);
    CHECK_EQ(cfg.addressbook_registry.count("ca333"), 1);
    CHECK_EQ(cfg.addressbook_registry.size(), 3);
    CHECK_EQ(cfg.categories_addressbook_registry.size(), 3);
    CHECK_EQ(cfg.name, "roman");
}

TEST_CASE("validate json deserialization from cpp data structure to json")
{
    auto                   j = R"(
              {
    "name": "roman",
    "addressbook": {
        "ca333": {
            "ERC-20": "0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae",
            "SmartChains": "RB49Rm4jBe5mN9anErvkzf3kcQCzHqyz3e",
            "BTC": "3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc5"
        },
        "alice": {
            "ERC-20": "0xde0b395669a9fd93d5f28d9ec85e40f4cb697bae",
            "SmartChains": "RB39Rm4jBe5mN9anErvkzf3kcQCzHqyz3e",
            "BTC": "3FZbgi30cpjq2GjdwV8eyHuJJnkLtktZc5"
        },
        "bob": {
            "ERC-20": "0xde0b393669a9fd93d5f28d9ec85e40f4cb697bae",
            "SmartChains": "RB39Rm6jBe5mN9anErvkzf3kcQCzHqyz3e",
            "BTC": "3FZbgi30cpjq3GjdwV8eyHuJJnkLtktZc5"
        }
    },
    "categories": {
        "friends": [
            "ca333"
        ],
        "pro": [
            "alice"
        ],
        "black_list": [
            "bob"
        ]
    }
}
            )"_json;
    atomic_dex::wallet_cfg cfg;
    atomic_dex::from_json(j, cfg);

    nlohmann::json out_json;
    atomic_dex::to_json(out_json, cfg);

    CHECK_EQ(out_json, j);
}