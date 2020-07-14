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

//! PCH
#include "atomic.dex.pch.hpp"

//! Project headers
#include "atomic.dex.qt.addressbook.model.hpp"

//! Contact model
namespace atomic_dex
{
    contact_model::contact_model(qt_wallet_manager& wallet_manager_, QObject* parent) noexcept : QAbstractListModel(parent), m_wallet_manager(wallet_manager_)
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::debug("contact model created");
    }

    contact_model::~contact_model() noexcept
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::debug("contact model destroyed");
    }

    QVariant
    contact_model::data(const QModelIndex& index, int role = Qt::DisplayRole) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()))
        {
            return {};
        }

        const qt_contact_address_contents& item = m_addresses.at(index.row());
        switch (role)
        {
        case TypeRole:
            return item.type;
        case AddressRole:
            return item.address;
        default:
            return {};
        }
    }

    bool
    atomic_dex::contact_model::setData(const QModelIndex& index, const QVariant& value, int role)
    {
        if (!hasIndex(index.row(), index.column(), index.parent()) || !value.isValid())
        {
            return false;
        }

        qt_contact_address_contents& item = m_addresses[index.row()];
        switch (role)
        {
        case TypeRole:
            item.type = value.toString();
            break;
        case AddressRole:
            item.address = value.toString();
            break;
        default:
            return false;
        }
        emit dataChanged(index, index, {role});
        return true;
    }

    bool
    atomic_dex::contact_model::insertRows(int position, int rows, const QModelIndex& parent)
    {
        spdlog::trace("(contact_model::insertRows) inserting {} elements at position {}", rows, position);
        beginInsertRows(QModelIndex(), position, position + rows - 1);

        for (int row = 0; row < rows; ++row) { this->m_addresses.insert(position, {}); }

        endInsertRows();
        return true;
    }

    bool
    atomic_dex::contact_model::removeRows(int position, int rows, const QModelIndex& parent)
    {
        spdlog::trace("(contact_model::removeRows) removing {} elements at position {}", rows, position);
        beginRemoveRows(QModelIndex(), position, position + rows - 1);

        for (int row = 0; row < rows; ++row) { this->m_addresses.removeAt(position); }

        endRemoveRows();
        return true;
    }

    int
    contact_model::rowCount([[maybe_unused]] const QModelIndex& parent = QModelIndex()) const
    {
        return m_addresses.size();
    }

    QHash<int, QByteArray>
    atomic_dex::contact_model::roleNames() const
    {
        return {
            {TypeRole, "type"},
            {AddressRole, "address"},
        };
    }
} // namespace atomic_dex

//! Addressbook model
namespace atomic_dex
{
    addressbook_model::addressbook_model(atomic_dex::qt_wallet_manager& wallet_manager_, QObject* parent) noexcept :
        QAbstractListModel(parent), m_wallet_manager(wallet_manager_)
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::debug("addressbook model created");
    }

    addressbook_model::~addressbook_model() noexcept
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::debug("addressbook model destroyed");
    }

    QVariant
    atomic_dex::addressbook_model::data(const QModelIndex& index, int role) const
    {
        return QVariant(1);
    }

    int
    atomic_dex::addressbook_model::rowCount(const QModelIndex& parent) const
    {
        return 0;
    }
} // namespace atomic_dex