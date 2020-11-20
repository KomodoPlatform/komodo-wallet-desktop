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

#include "qt.addressbook.contact.model.hpp"

//! Constructors.
namespace atomic_dex
{
    addressbook_contact_model::addressbook_contact_model(addressbook_manager& addrbook_manager, QString name, QObject* parent) :
        QAbstractListModel(parent), m_addressbook_manager(addrbook_manager), m_name(std::move(name))
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("addressbook contact model created");
    }
    
    addressbook_contact_model::~addressbook_contact_model() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("addressbook contact model destroyed");
    }
}

//! QAbstractListModel implementation
namespace atomic_dex
{
    QVariant addressbook_contact_model::data(const QModelIndex& index, int role) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()))
        {
            return {};
        }
    
        const auto& wallets_info = m_addressbook_manager.get_contact(m_name.toStdString()).at("wallets_info");
        switch (role)
        {
        default:
            return {};
        }
    }
    
    bool addressbook_contact_model::setData(const QModelIndex& index, const QVariant& value, int role)
    {
        if (!hasIndex(index.row(), index.column(), index.parent()) || !value.isValid())
        {
            return false;
        }
    
        auto& wallet_info = m_wallets_info[index.row()];
        switch (role)
        {
        case TypeRole:
//            if (value.toString() != wallet_info.type)
//            {
//                spdlog::trace("changing contact {} ticker {} to {}", this->m_name.toStdString(), item.type.toStdString(), value.toString().toStdString());
//                m_addressbook_manager.set_contact_wallet_info(m_name, value.toString());
//                m_addressbook_manager.update_configuration();
//                wallet_info.type = value.toString();
//            }
            break;
        case AddressesRole:
//            if (value.toString() != wallet_info.addresses)
//            {
//                wallet_info.addresses = value;
//                spdlog::trace("changing contact {} ticker {} to address {}", this->m_name.toStdString(), item.type.toStdString(), item.address.toStdString());
//                m_addressbook_manager.update_contact_address(this->m_name, item.type, item.address);
//                m_addressbook_manager.update_configuration();
//            }
            break;
        default:
            return false;
        }
    
        emit dataChanged(index, index, {role});
        return true;
    }
    
    int addressbook_contact_model::rowCount(const QModelIndex& parent) const
    {
        return m_wallets_info.size();
    }
    
    bool addressbook_contact_model::insertRows(int position, int rows, const QModelIndex& parent)
    {
        spdlog::trace("(contact_model::insertRows) inserting {} elements at position {}", rows, position);
        beginInsertRows(QModelIndex(), position, position + rows - 1);
        for (int row = 0; row < rows; ++row)
        {
        //    m_wallets_info.insert(position, );
        }
        endInsertRows();
        //emit addressesChanged();
        return true;
    }
    
    bool addressbook_contact_model::removeRows(int position, int rows, const QModelIndex& parent)
    {
    }
    
    QHash<int, QByteArray> addressbook_contact_model::roleNames() const
    {
        return {
            {TypeRole, "type"},
            {AddressesRole, "addresses"}
        };
    }
}

//! Other member functions
namespace atomic_dex
{
    const QString& addressbook_contact_model::get_name() const noexcept
    {
        return m_name;
    }
    
    void addressbook_contact_model::set_name(const QString& name) noexcept
    {
        if (m_name == name)
        {
            return;
        }
        spdlog::trace("name {} changed to {}", m_name.toStdString(), name.toStdString());
        m_addressbook_manager.change_contact_name(m_name.toStdString(), name.toStdString());
        m_addressbook_manager.update_configuration();
        m_name = name;
        emit nameChanged();
    }
    
    const QJsonArray& addressbook_contact_model::get_categories() const noexcept
    {
        return m_categories;
    }
}