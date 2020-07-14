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

#pragma once

#include <QAbstractListModel>
#include <QObject> //! QObject

//! Project include
#include "atomic.dex.qt.wallet.manager.hpp"

namespace atomic_dex
{
    struct qt_contact_address_contents
    {
        QString type;
        QString address;
    };

    class contact_model final : public QAbstractListModel
    {
        Q_OBJECT
        Q_ENUMS(ContactRoles)
      public:
        enum ContactRoles
        {
            TypeRole = Qt::UserRole + 1,
            AddressRole
        };

      public:
        explicit contact_model(atomic_dex::qt_wallet_manager& wallet_manager_, QObject* parent = nullptr) noexcept;
        ~contact_model() noexcept final;
        QVariant               data(const QModelIndex& index, int role) const final;
        int                    rowCount(const QModelIndex& parent) const final;
        QHash<int, QByteArray> roleNames() const final;
        bool                   setData(const QModelIndex& index, const QVariant& value, int role) final;
        bool                   insertRows(int position, int rows, const QModelIndex& parent) final;
        bool                   removeRows(int position, int rows, const QModelIndex& parent) final;

      public:
        //! Contact stuff
        QString                              m_name;
        QVector<qt_contact_address_contents> m_addresses;

      private:
        atomic_dex::qt_wallet_manager& m_wallet_manager;
    };

    class addressbook_model final : public QAbstractListModel
    {
        Q_OBJECT
      public:
        explicit addressbook_model(atomic_dex::qt_wallet_manager& wallet_manager_, QObject* parent = nullptr) noexcept;
        ~addressbook_model() noexcept final;
        QVariant data(const QModelIndex& index, int role) const final;
        int      rowCount(const QModelIndex& parent) const final;

      private:
        atomic_dex::qt_wallet_manager& m_wallet_manager;
    };
} // namespace atomic_dex