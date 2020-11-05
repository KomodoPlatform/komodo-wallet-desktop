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

//! QT
#include <QAbstractListModel>
#include <QString>
#include <QVariantList>

//! Project
#include "atomicdex/managers/qt.wallet.manager.hpp"

namespace atomic_dex
{
    class contact_model final : public QAbstractListModel
    {
        Q_OBJECT
        Q_PROPERTY(QString name READ get_name WRITE set_name NOTIFY nameChanged)
        Q_PROPERTY(QList<QVariant> readonly_addresses READ get_addresses NOTIFY addressesChanged)
        Q_ENUMS(ContactRoles)
      public:
        enum ContactRoles
        {
            TypeRole = Qt::UserRole + 1,
            AddressRole
        };

        QString get_name() const noexcept;

        void set_name(const QString& name) noexcept;

      public:
        explicit contact_model(atomic_dex::qt_wallet_manager& wallet_manager_, QObject* parent = nullptr) noexcept;
        ~contact_model() noexcept final;
        QVariant               data(const QModelIndex& index, int role) const final;
        int                    rowCount(const QModelIndex& parent) const final;
        QHash<int, QByteArray> roleNames() const final;
        bool                   setData(const QModelIndex& index, const QVariant& value, int role) final;
        bool                   insertRows(int position, int rows, const QModelIndex& parent) final;
        bool                   removeRows(int position, int rows, const QModelIndex& parent) final;
        QVariantList           get_addresses() const noexcept;
        Q_INVOKABLE void       add_address_content();
        Q_INVOKABLE void       remove_at(int position);

      signals:
        void nameChanged();
        void addressesChanged();

      public:
        //! Contact stuff
        QString                                          m_name;
        QVector<atomic_dex::qt_contact_address_contents> m_addresses;

      private:
        atomic_dex::qt_wallet_manager& m_wallet_manager;
    };
} // namespace atomic_dex
