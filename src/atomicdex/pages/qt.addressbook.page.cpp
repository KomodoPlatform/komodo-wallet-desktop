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

#include "qt.addressbook.page.hpp"

//! Constructor(s)/destructor
namespace atomic_dex
{
    addressbook_page::addressbook_page(entt::registry& registry, ag::ecs::system_manager& system_manager, QObject* parent) :
        QObject(parent), system(registry), m_system_manager(system_manager)
    {
        disable();
    }
}

//! ag::ecs::pre_update_system implem
namespace atomic_dex
{
    void addressbook_page::update() noexcept
    { }
}

//! QML API
namespace atomic_dex
{
    addressbook_model* addressbook_page::get_model()
    {
        return m_model;
    }
}