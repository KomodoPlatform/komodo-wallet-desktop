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

//! Projects headers.
#include "qt.addressbook.page.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

namespace atomic_dex
{
    addressbook_page::addressbook_page(entt::registry& registry, ag::ecs::system_manager& system_manager,
                                       addressbook_model* addressbook_model, QObject* parent) :
        QObject(parent), system(registry), m_system_manager(system_manager), m_addressbook_model(addressbook_model)
    {}
    
    void addressbook_page::update() noexcept
    {
    
    }
}

//! QML API.
namespace atomic_dex
{
    bool addressbook_page::add_contact(const QString& contact_name)
    {
        return m_addressbook_model->add_contact_entry(contact_name);
    }
    
    void addressbook_page::remove_contact(const QString& contact_name)
    {
    }
    
    void addressbook_page::remove_contact(int position)
    {
        m_addressbook_model->remove_at(position);
    }
    
    void addressbook_page::remove_all_contacts()
    {
        auto row_count = m_addressbook_model->rowCount();
        
        if (row_count > 0)
        {
            m_addressbook_model->removeRows(0, row_count);
        }
    }
    
    void addressbook_page::set_contact_wallet_info(QString contact_name, QString type, QString key, QString address)
    {
    }
    
    void addressbook_page::remove_contact_wallet_info(QString contact_name, QString type)
    {
    }
    
    void addressbook_page::remove_contact_wallet_info(QString contact_name, QString type, QString key)
    {
    }
    
    void addressbook_page::add_contact_category(QString contact_name, QString category)
    {
    }
    
    void addressbook_page::remove_contact_category(QString contact_name, QString category)
    {
    }
    
    addressbook_model* addressbook_page::get_addressbook_model() const noexcept
    {
        return m_addressbook_model;
    }
}