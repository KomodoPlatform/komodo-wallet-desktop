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

//! Project
#include "qt.addressbook.page.hpp"

//! Constructor(s)/destructor
namespace atomic_dex
{
    addressbook_page::addressbook_page(entt::registry& registry, ag::ecs::system_manager& system_manager, QObject* parent) :
        QObject(parent), system(registry), m_system_manager(system_manager), m_model(new addressbook_model(system_manager, this))
    {
        m_system_manager.create_system<addressbook_manager>(m_system_manager);
        disable();
    }
} // namespace atomic_dex

//! ag::ecs::pre_update_system implem
namespace atomic_dex
{
    void
    addressbook_page::update() 
    {
    }
} // namespace atomic_dex

//! QML API
namespace atomic_dex
{
    addressbook_model*
    addressbook_page::get_model() const 
    {
        return m_model;
    }

    void
    addressbook_page::connect_signals() 
    {
        SPDLOG_INFO("connecting addressbook signals");
        dispatcher_.sink<post_login>().connect<&addressbook_page::on_post_login>(*this);
    }

    void
    addressbook_page::disconnect_signals() 
    {
        SPDLOG_INFO("disconnecting addressbook signals");
        dispatcher_.sink<post_login>().disconnect<&addressbook_page::on_post_login>(*this);
    }

    void
    addressbook_page::on_post_login([[maybe_unused]] const post_login& evt) 
    {
        SPDLOG_INFO("post_login: filling addressbook from cfg");
        m_system_manager.get_system<addressbook_manager>().load_configuration();
        m_model->populate();
    }

    void
    addressbook_page::clear() 
    {
        SPDLOG_INFO("clear addressbook page");
        m_system_manager.get_system<addressbook_manager>().save_configuration();
        m_model->clear();
    }
} // namespace atomic_dex