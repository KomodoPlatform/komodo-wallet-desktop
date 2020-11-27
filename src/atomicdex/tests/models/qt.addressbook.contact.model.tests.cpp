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

//! Qt
#include <QJsonObject>

//! Deps
#include <doctest/doctest.h>

//! Project
#include "atomicdex/models/qt.addressbook.contact.model.hpp"

TEST_CASE("addressbook_contact_model")
{
    entt::registry entity_registry;
    {
        entity_registry.set<entt::dispatcher>();
    }
    ag::ecs::system_manager system_manager{entity_registry};
    atomic_dex::addressbook_manager addressbook_manager{entity_registry, system_manager};
    atomic_dex::addressbook_contact_model addressbook_contact_model{addressbook_manager};
    
    SUBCASE("set_wallets_info && get_wallets_info")
    {
        QList<atomic_dex::addressbook_contact_model::wallet_info> wallets
            {{.type="BTC", .addresses={{"first", "first_value"}, {"second", "second_value"}}},
             {.type="ETC", .addresses={{"first", "first_value"}, {"second", "second_value"}}}};
        
        addressbook_contact_model.set_wallets_info(wallets);
        
        auto wallets_info = addressbook_contact_model.get_wallets_info();
        int index{0};
        
        for (auto&& wallet_info : wallets_info)
        {
            auto json = wallet_info.toJsonObject();
            CHECK(json.value("type").toString() == wallets[index].type);
            for (auto it = wallets[index].addresses.begin(); it != wallets[index].addresses.end(); ++it)
            {
                CHECK(json.value("addresses").toObject().value(it.key()).toString() == it.value());
            }
            index++;
        }
    }
}