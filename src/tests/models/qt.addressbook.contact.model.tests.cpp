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

//! Qt
#include <QJsonObject>

//! Deps
#include <doctest/doctest.h>

//! Project
#include "atomicdex/models/qt.addressbook.contact.model.hpp"
#include "atomicdex/managers/addressbook.manager.hpp"

#include "../atomic.dex.tests.hpp"

TEST_CASE("addressbook_contact_model")
{
#if defined(WIN32) || defined(_WIN32)
    CHECK_EQ(42, 42);
#else
    auto& addressbook_manager = g_context->system_manager().create_system<atomic_dex::addressbook_manager>(g_context->system_manager());
    {
        addressbook_manager.load_configuration();
    }
    const auto* contact_name = "contact";
    {
        addressbook_manager.add_contact(contact_name);
        addressbook_manager.add_contact_category(contact_name, "C++ developer");
        addressbook_manager.add_contact_category(contact_name, "Friend");
        addressbook_manager.add_contact_category(contact_name, "QA");
        addressbook_manager.add_contact_category(contact_name, "CTO");
    }
    atomic_dex::addressbook_contact_model contact_model{g_context->system_manager(), contact_name};

    THEN("get_categories should return 4 categories")
    {
        const auto& categories = contact_model.get_categories();

        CHECK(categories.size() == 4);
        CHECK(categories[0] == "C++ developer");
        CHECK(categories[1] == "Friend");
        CHECK(categories[2] == "QA");
        CHECK(categories[3] == "CTO");
    }

    WHEN("A category is added")
    {
        CHECK(contact_model.addCategory("CEO") == true);

        THEN("get_categories should return 5 categories")
        {
            const auto& categories = contact_model.get_categories();

            CHECK(categories.size() == 5);
            CHECK(categories[4] == "CEO");
        }

        WHEN("Data is saved")
        {
            contact_model.save();

            THEN("Persistent data should contains a contact with 5 categories")
            {
                CHECK(addressbook_manager.has_contact(contact_name));
                CHECK(addressbook_manager.has_category(contact_name, "C++ developer"));
                CHECK(addressbook_manager.has_category(contact_name, "Friend"));
                CHECK(addressbook_manager.has_category(contact_name, "QA"));
                CHECK(addressbook_manager.has_category(contact_name, "CTO"));
                CHECK(addressbook_manager.has_category(contact_name, "CEO"));
            }
        }
    }

    WHEN("A category is removed")
    {
        contact_model.removeCategory("Friend");

        THEN("get_categories should return 3 categories")
        {
            const auto& categories = contact_model.get_categories();

            CHECK(categories.size() == 3);
            CHECK(!categories.contains("Friend"));
            CHECK(categories[1] == "QA");
        }

        WHEN("Data is saved")
        {
            contact_model.save();

            THEN("Persistent data should contains a contact with 3 categories")
            {
                CHECK(addressbook_manager.has_contact(contact_name));
                CHECK(addressbook_manager.has_category(contact_name, "C++ developer"));
                CHECK(addressbook_manager.has_category(contact_name, "QA"));
                CHECK(addressbook_manager.has_category(contact_name, "CTO"));
            }
        }
    }

    WHEN("Categories are replaced")
    {
        QStringList new_categories{"C# developer", "Employer"};

        contact_model.set_categories(new_categories);

        THEN("get_categories should return 2 categories")
        {
            const auto& categories = contact_model.get_categories();

            CHECK(categories.size() == 2);
            CHECK(categories[0] == new_categories[0]);
            CHECK(categories[1] == new_categories[1]);
        }

        WHEN("Data is saved")
        {
            const auto& categories_data = addressbook_manager.get_categories(contact_name);

            contact_model.save();

            CHECK(categories_data.size() == 2);
            CHECK(categories_data[0] == new_categories[0].toStdString());
            CHECK(categories_data[1] == new_categories[1].toStdString());
            CHECK(addressbook_manager.has_category(contact_name, new_categories[0].toStdString()));
            CHECK(addressbook_manager.has_category(contact_name, new_categories[1].toStdString()));
        }
    }

    WHEN("Name is changed")
    {
        const auto* contact_new_name = "new_contact";

        contact_model.set_name(contact_new_name);

        THEN("get_name sould return \"new_contact\"")
        { CHECK(contact_model.get_name() == contact_new_name); }

        WHEN("Data is saved")
        {
            contact_model.save();

            CHECK(!addressbook_manager.has_contact(contact_name));
            CHECK(addressbook_manager.has_contact(contact_new_name));
            CHECK(addressbook_manager.has_category(contact_new_name, "C++ developer"));
            CHECK(addressbook_manager.has_category(contact_new_name, "Friend"));
            CHECK(addressbook_manager.has_category(contact_new_name, "QA"));
            CHECK(addressbook_manager.has_category(contact_new_name, "CTO"));
        }
    }
    
    //! Teardown
    addressbook_manager.remove_all_contacts();
    addressbook_manager.save_configuration();
#endif
}