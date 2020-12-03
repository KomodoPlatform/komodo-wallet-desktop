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
#include <QJsonArray>
#include <QJsonDocument>

//! Project headers
#include "atomicdex/models/qt.addressbook.model.hpp"
#include "atomicdex/utilities/qt.utilities.hpp"

//! Constructors
namespace atomic_dex
{
    addressbook_model::addressbook_model(ag::ecs::system_manager& system_manager, QObject* parent) noexcept :
        QAbstractListModel(parent),
        m_system_manager(system_manager),
        m_addressbook_proxy(new addressbook_proxy_model(this))
    {
        m_addressbook_proxy->setSourceModel(this);
        m_addressbook_proxy->setSortRole(SubModelRole);
        m_addressbook_proxy->setDynamicSortFilter(true);
        m_addressbook_proxy->sort(0);
    }
}

//! QAbstractListModel implementation
namespace atomic_dex
{
    int
    atomic_dex::addressbook_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return m_model_data.count();
    }
    
    QVariant
    atomic_dex::addressbook_model::data(const QModelIndex& index, int role) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()))
        {
            return {};
        }

        switch (static_cast<AddressBookRoles>(role))
        {
        case SubModelRole:
            return QVariant::fromValue(m_model_data.at(index.row()));
        default:
            return {};
        }
    }
    
    QHash<int, QByteArray>
    atomic_dex::addressbook_model::roleNames() const
    {
        return {
            {SubModelRole, "contacts"}
        };
    }
}

//! QML API
namespace atomic_dex
{
    addressbook_proxy_model* addressbook_model::get_addressbook_proxy_mdl() const noexcept
    {
        return m_addressbook_proxy;
    }
}

//! Other member functions
namespace atomic_dex
{
    void addressbook_model::populate()
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();
        
        beginInsertRows(QModelIndex(), 0, addrbook_manager.nb_contacts() - 1);
        for (auto& contact : addrbook_manager.get_contacts())
        {
            auto  contact_name  = contact.at("name").get<std::string>();
            auto* contact_model = new addressbook_contact_model(m_system_manager, QString::fromStdString(contact_name), this);
    
            m_model_data.push_back(contact_model);
        }
        endInsertRows();
    }
    
    void addressbook_model::clear()
    {
        remove_all_contacts();
    }
    
    void addressbook_model::remove_contact(int row, const QString& name)
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();
    
        for (auto* it = m_model_data.begin(); it != m_model_data.end(); ++it)
        {
            if ((*it)->get_name() == name)
            {
                addrbook_manager.remove_contact(name.toStdString());
                addrbook_manager.save_configuration();
                beginRemoveRows(QModelIndex(), row, row);
                delete *it;
                m_model_data.erase(it);
                endRemoveRows();
                return;
            }
        }
    }
    
    void addressbook_model::remove_all_contacts()
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();

        beginRemoveRows(QModelIndex(), 0, rowCount());
        for (auto& contact_model : m_model_data)
        {
            addrbook_manager.remove_contact(contact_model->get_name().toStdString());
            addrbook_manager.save_configuration();
            delete contact_model;
        }
        m_model_data.clear();
        endRemoveRows();
    }

    bool addressbook_model::add_contact(const QString& name)
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();
    
        if (addrbook_manager.has_contact(name.toStdString()))
        {
            return false;
        }
    
        addrbook_manager.add_contact(name.toStdString());
        addrbook_manager.save_configuration();
        beginInsertRows(QModelIndex(), rowCount(), rowCount());
        m_model_data.push_back(new addressbook_contact_model(m_system_manager, name, this));
        endInsertRows();
        return true;
    }
} // namespace atomic_dex
