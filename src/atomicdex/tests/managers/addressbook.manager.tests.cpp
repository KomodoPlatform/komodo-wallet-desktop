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

//! Deps
#include <doctest/doctest.h>

//! Project Headers
#include "atomicdex/managers/addressbook.manager.hpp"

TEST_CASE("addressbook_manager with 4 contacts")
{
    using namespace atomic_dex;
    
    entt::registry entity_registry;
    {
        entity_registry.set<entt::dispatcher>();
    }
    ag::ecs::system_manager system_manager{entity_registry};
    addressbook_manager addrbook{entity_registry, system_manager};
    
    addrbook.add_contact("one");
    addrbook.add_contact("two");
    addrbook.add_contact("three");
    addrbook.add_contact("four");
    CHECK(addrbook.data().at(0).at("name") == "one");
    CHECK(addrbook.has_contact("one"));
    CHECK(addrbook.get_contacts().at(1).at("name") == "two");
    CHECK(addrbook.has_contact("two"));
    CHECK(addrbook.data().at(2).at("name") == "three");
    CHECK(addrbook.has_contact("three"));
    CHECK(addrbook.get_contacts().at(3).at("name") == "four");
    CHECK(addrbook.has_contact("four"));
    CHECK(addrbook.nb_contacts() == 4);
    
    SUBCASE("Adding categories")
    {
        CHECK(!addrbook.has_category("one", "friend"));
        CHECK(addrbook.add_contact_category("one", "friend"));
        CHECK(!addrbook.add_contact_category("one", "friend"));
        CHECK(addrbook.has_category("one", "friend"));
        
        WHEN("Removing categories")
        {
            addrbook.remove_contact_category("one", "friend");
            CHECK(!addrbook.has_category("one", "friend"));
        }
    }
}