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

//! Qt
#include <QJsonArray>
#include <QJsonDocument>

//! Project headers
#include "atomicdex/models/qt.addressbook.model.hpp"
#include "atomicdex/utilities/qt.utilities.hpp"

//! Ctor
namespace atomic_dex
{
    addressbook_model::addressbook_model(ag::ecs::system_manager& system_manager, QObject* parent)  :
        QAbstractListModel(parent),
        m_system_manager(system_manager),
        m_addressbook_proxy(new addressbook_proxy_model(m_system_manager, this))
    {
        m_addressbook_proxy->setSortRole(SubModelRole);
        m_addressbook_proxy->setFilterRole(NameRoleAndCategoriesRole);
        m_addressbook_proxy->setDynamicSortFilter(true);
        m_addressbook_proxy->setSourceModel(this);
        m_addressbook_proxy->sort(0);
    }
}

//! QAbstractListModel Functions
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
        case NameRole:
            return m_model_data.at(index.row())->get_name();
        case NameRoleAndCategoriesRole:
        {
            auto* contact = m_model_data.at(index.row());
            return contact->get_name() + ' ' + contact->get_categories().join(' ');
        }
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
} // namespace atomic_dex

//! QML API
namespace atomic_dex
{
    addressbook_proxy_model*
    addressbook_model::get_addressbook_proxy_mdl() const 
    {
        return m_addressbook_proxy;
    }

    void
    addressbook_model::removeContact(const QString& name)
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();
        auto  res              = match(index(0), NameRole, name, 1, Qt::MatchFlag::MatchExactly);

        if (not res.empty())
        {
            addrbook_manager.remove_contact(name.toStdString());
            addrbook_manager.save_configuration();
            beginRemoveRows(QModelIndex(), res.at(0).row(), res.at(0).row());
            m_model_data.removeAt(res.at(0).row());
            endRemoveRows();
        }
    }
    
    bool addressbook_model::addContact(const QString& name)
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

//! Others
namespace atomic_dex
{
    void addressbook_model::populate()
    {
        const auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();

        beginResetModel();
        for (const auto& contact : addrbook_manager.get_contacts())
        {
            auto  contact_name  = contact.at("name").get<std::string>();
            auto* contact_model = new addressbook_contact_model(m_system_manager, QString::fromStdString(contact_name), this);
    
            m_model_data.push_back(contact_model);
        }
        endResetModel();
    }
    
    void addressbook_model::clear()
    {
        beginResetModel();
        for (auto&& model : m_model_data)
        {
            delete model;
        }
        m_model_data.clear();
        endResetModel();
    }
} // namespace atomic_dex
