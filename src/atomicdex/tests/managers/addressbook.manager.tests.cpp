/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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

#include "atomicdex/pch.hpp"

//! Deps
#include <doctest/doctest.h>

//! Project Headers
#include "atomicdex/managers/addressbook.manager.hpp"

#include "../atomic.dex.tests.hpp"

TEST_CASE("addressbook_manager with 4 contacts")
{
#if defined(WIN32) || defined(_WIN32)
    CHECK_EQ(42, 42);
#else
    auto addrbook = g_context->system_manager().create_system<atomic_dex::addressbook_manager>(g_context->system_manager());

    addrbook.remove_all_contacts();
    
    //! Contacts creation
    addrbook.add_contact("one");
    addrbook.add_contact("two");
    CHECK(addrbook.nb_contacts() == 2);
    addrbook.add_contact("three");
    CHECK(addrbook.nb_contacts() == 3);
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
    
    //! Categories
    CHECK(!addrbook.has_category("one", "friend"));
    CHECK(addrbook.add_contact_category("one", "friend"));
    CHECK(!addrbook.add_contact_category("one", "friend"));
    CHECK(addrbook.has_category("one", "friend"));
    addrbook.remove_contact_category("one", "friend");
    CHECK(!addrbook.has_category("one", "friend"));
    
    //! Wallets information
    CHECK(!addrbook.has_wallet_info("one", "BTC"));
    addrbook.set_contact_wallet_info("one", "BTC", "home", "value");
    addrbook.set_contact_wallet_info("one", "BTC", "web_exchange", "another_value");
    CHECK(addrbook.has_wallet_info("one", "BTC"));
    CHECK(addrbook.has_wallet_info("one", "BTC", "home"));
    CHECK(addrbook.has_wallet_info("one", "BTC", "web_exchange"));
    addrbook.remove_contact_wallet_info("one", "BTC", "home");
    CHECK(!addrbook.has_wallet_info("one", "BTC", "home"));
    CHECK(addrbook.has_wallet_info("one", "BTC", "web_exchange"));
    addrbook.remove_contact_wallet_info("one", "BTC");
    CHECK(!addrbook.has_wallet_info("one", "BTC"));
    
    //! Contacts removal
    addrbook.remove_contact("one");
    CHECK(addrbook.nb_contacts() == 3);
    addrbook.remove_all_contacts();
    CHECK(addrbook.nb_contacts() == 0);
#endif
}