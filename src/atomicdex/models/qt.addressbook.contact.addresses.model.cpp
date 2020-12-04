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

//! Std
#include <algorithm>

//! Project
#include "qt.addressbook.contact.addresses.model.hpp"

//! Constructors.
namespace atomic_dex
{
    addressbook_contact_addresses_model::addressbook_contact_addresses_model(ag::ecs::system_manager& system_manager, const QString& name, QString type, QObject* parent) :
        QAbstractTableModel(parent), m_system_manager(system_manager), m_name(name), m_type(std::move(type))
    {
        populate();
    }
}

//! QAbstractListModel implementation.
namespace atomic_dex
{
    QVariant addressbook_contact_addresses_model::data(const QModelIndex& index, int role) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()))
        {
            return {};
        }
    
        const auto& data = m_model_data.at(index.row());
        switch (role)
        {
        case TypeRole:
            return m_type;
        case KeyRole:
            return data.key;
        case AddressRole:
            return data.value;
        default:
            return {};
        }
    }
    
    bool addressbook_contact_addresses_model::setData(const QModelIndex& index, const QVariant& value, int role)
    {
        if (!hasIndex(index.row(), index.column(), index.parent()))
        {
            return {};
        }
    
        auto& data = m_model_data[index.row()];
        switch (role)
        {
        case KeyRole:
            data.key = value.toString();
            break;
        case AddressRole:
            data.value = value.toString();
            break;
        default:
            break;
        }
        emit dataChanged(index, index, {role});
        return true;
    }
    
    int addressbook_contact_addresses_model::columnCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return 2;
    }
    
    int addressbook_contact_addresses_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return m_model_data.count();
    }

    QHash<int, QByteArray> addressbook_contact_addresses_model::roleNames() const
    {
        return {{TypeRole, "type"}, {KeyRole, "key"}, {AddressRole, "value"}};
    }
}

//! QML API implementation.
namespace atomic_dex
{
    bool addressbook_contact_addresses_model::add_address_entry(QString key, QString value)
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();

        if (addrbook_manager.has_wallet_info(m_name.toStdString(), m_type.toStdString(), key.toStdString()))
        {
            return false;
        }
        beginInsertRows(QModelIndex(), m_model_data.count(), m_model_data.count());
        m_model_data.push_back(address{.key = std::move(key), .value = std::move(value)});
        endInsertRows();
        return true;
    }
    
    void addressbook_contact_addresses_model::remove_address_entry(int row)
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();
        
        beginRemoveRows(QModelIndex(), row, row);
        m_model_data.removeAt(row);
        endRemoveRows();
    }
    
    const QString& addressbook_contact_addresses_model::get_type() const noexcept
    {
        return m_type;
    }
}

namespace atomic_dex
{
    void addressbook_contact_addresses_model::populate()
    {
        const auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();
        
        if (!addrbook_manager.has_wallet_info(m_name.toStdString(), m_type.toStdString()))
        {
            return;
        }
        
        const auto& addresses = addrbook_manager.get_wallet_info(m_name.toStdString(), m_type.toStdString()).at("addresses");
        
        beginInsertRows(QModelIndex(), 0, addresses.size());
        for (auto it = addresses.begin(); it != addresses.end(); ++it)
        {
            m_model_data.push_back(address{.key = QString::fromStdString(it.key()), .value = QString::fromStdString(it.value())});
        }
        endInsertRows();
    }
    
    void addressbook_contact_addresses_model::clear()
    {
        beginResetModel();
        m_model_data.clear();
        endResetModel();
    }
    
    void addressbook_contact_addresses_model::save()
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();
        
        // Cleans existing wallet info persistent data before.
        addrbook_manager.remove_every_wallet_info(m_name.toStdString());
        
        // Replace the persistent data by the model one.
        for (const auto& address : m_model_data)
        {
            addrbook_manager.set_contact_wallet_info(m_name.toStdString(), m_type.toStdString(), address.key.toStdString(), address.value.toStdString());
        }
    }
}