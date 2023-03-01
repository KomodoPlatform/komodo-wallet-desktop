/******************************************************************************
 * Copyright © 2013-2022 The Komodo Platform Developers.                      *
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
#include <antara/gaming/ecs/system.manager.hpp> //> antara::gaming, ag::ecs::system_manager

//! Project include
#include "atomicdex/managers/addressbook.manager.hpp"             //> addressbook_manager
#include "atomicdex/models/qt.addressbook.proxy.filter.model.hpp" //> addressbook_proxy_filter
#include "qt.addressbook.contact.model.hpp"                       //> addressbook_contact_model

namespace ag = antara::gaming;

namespace atomic_dex
{
    class addressbook_model final : public QAbstractListModel
    {
        // Tells QT this class uses signal/slots mechanisms and/or has GUI elements.
        Q_OBJECT
        
        Q_ENUMS(AddressBookRoles)

    public:
        enum AddressBookRoles
        {
            SubModelRole = Qt::UserRole + 1,
            
            NameRole,
          
            NameRoleAndCategoriesRole           // Used as search role.
        };
        Q_ENUM(AddressBookRoles);

        explicit addressbook_model(ag::ecs::system_manager& system_registry, QObject* parent = nullptr) ;
        ~addressbook_model()  final = default;
        
        // QAbstractListModel Functions
        [[nodiscard]] QVariant               data(const QModelIndex& index, int role) const final;
        [[nodiscard]] int                    rowCount(const QModelIndex& parent = QModelIndex()) const final;
        [[nodiscard]] QHash<int, QByteArray> roleNames() const final;

        // Loads model data from persistent data.
        void populate();
        
        // Unloads model data.
        void clear();
        
        // Getters/Setters
        [[nodiscard]] addressbook_proxy_model* get_addressbook_proxy_mdl() const ;
        
        // QML API
        Q_INVOKABLE bool addContact(const QString& name);
        Q_INVOKABLE void removeContact(const QString& name);

        // QML API properties
        Q_PROPERTY(addressbook_proxy_model* proxy READ get_addressbook_proxy_mdl NOTIFY addressbookProxyChanged);
        
        // QMl API properties signals
    signals:
        void addressbookProxyChanged();

    private:
        ag::ecs::system_manager&            m_system_manager;
        
        addressbook_proxy_model*            m_addressbook_proxy;
        
        QVector<addressbook_contact_model*> m_model_data;
    };
} // namespace atomic_dex
