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

//! Qt
#include <QAbstractListModel> //> QAbstractListModel
#include <QObject>            //> QObject

//! Deps
#include <antara/gaming/ecs/system.manager.hpp> //> antara::gaming, ag::ecs::system_manager.

//! Project include
#include "atomicdex/managers/addressbook.manager.hpp"             //> addressbook_manager.
#include "atomicdex/models/qt.addressbook.proxy.filter.model.hpp"
#include "qt.addressbook.contact.model.hpp"

namespace ag = antara::gaming;

namespace atomic_dex
{
    class addressbook_model final : public QAbstractListModel
    {
        /// \brief Tells QT this class uses signal/slots mechanisms and/or has GUI elements.
        Q_OBJECT
        Q_ENUMS(AddressBookRoles)

    public:
        enum AddressBookRoles
        {
            SubModelRole = Qt::UserRole + 1,
        };

        explicit addressbook_model(ag::ecs::system_manager& system_registry, QObject* parent = nullptr) noexcept;
        ~addressbook_model() noexcept final;
        
        /// \defgroup QAbstractListModel implementation.
        /// {@
        
        [[nodiscard]]
        QVariant               data(const QModelIndex& index, int role) const final;
        [[nodiscard]]
        int                    rowCount(const QModelIndex& parent = QModelIndex()) const final;
        bool insertRows(int position, int rows, [[maybe_unused]] const QModelIndex& parent) final;
        bool                   removeRows(int position, int rows, const QModelIndex& parent = QModelIndex()) final;
        [[nodiscard]]
        QHash<int, QByteArray> roleNames() const final;
        
        /// @} End of QAbstractListModel implementation section.
        
        /// \brief Loads model from the addressbook_manager current data.
        void populate();
        
        /// \defgroup QML API
        /// {@
        
        Q_INVOKABLE bool add_contact(const QString& name);
        
        Q_INVOKABLE void remove_contact(int row, const QString& name);
        
        Q_INVOKABLE void remove_all_contacts();

        void clear();

    private:
        Q_PROPERTY(addressbook_proxy_model* addressbook_proxy_mdl READ get_addressbook_proxy_mdl NOTIFY addressbookProxyChanged);
        //! Properties
        [[nodiscard]]
        addressbook_proxy_model* get_addressbook_proxy_mdl() const noexcept;
    signals:
        void addressbookProxyChanged();
        
        /// @} End of QML API section.

    private:
        addressbook_manager&                m_addressbook_manager;
        addressbook_proxy_model*            m_addressbook_proxy;
        QVector<addressbook_contact_model*> m_contact_models;
    };
} // namespace atomic_dex
