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

#pragma once

// 3rdParty Headers
#include <entt/core/attribute.h>                //> ENTT_API
#include <antara/gaming/ecs/system.manager.hpp> //> ag::ecs::system_manager

// Project Headers
#include "qt.addressbook.contact.proxy.filter.model.hpp"

namespace atomic_dex
{
    class ENTT_API addressbook_contact_model final : public QAbstractListModel
    {
        // Tells QT this class uses signal/slots mechanisms and/or has GUI elements.
        Q_OBJECT
      
        friend class addressbook_model;
        
        struct address_entry
        {
            QString type;
            QString key;
            QString value;
        };
    
      public:
        enum ContactRoles
        {
            AddressTypeRole = Qt::UserRole + 1,
            AddressKeyRole,
            AddressValueRole,
            AddressTypeAndKeyRole,
        };
        Q_ENUMS(ContactRoles)

        explicit addressbook_contact_model(ag::ecs::system_manager& system_manager, QString name, QObject* parent = nullptr);
        ~addressbook_contact_model() noexcept final;
    
        // QAbstractListModel Functions
        [[nodiscard]] QVariant               data(const QModelIndex& index, int role) const final;
        [[nodiscard]] int                    rowCount(const QModelIndex& parent = QModelIndex()) const final;
        [[nodiscard]] QHash<int, QByteArray> roleNames() const final;
        
        // Getters/Setters
        [[nodiscard]] const QString&                          get_name() const noexcept;
        void                                                  set_name(const QString& name) noexcept;
        [[nodiscard]] const QStringList&                      get_categories() const noexcept;
        void                                                  set_categories(QStringList categories) noexcept;
        [[nodiscard]] addressbook_contact_proxy_filter_model* get_proxy_filter() const noexcept;
        [[nodiscard]] const QVector<address_entry>&           get_address_entries() const noexcept; // Returns contact's current addresses.
    
        // Loads this model data from the persistent data.
        void populate();
    
        // Clears this model data.
        void clear();

        // QML API
        Q_INVOKABLE bool add_category(const QString& category) noexcept;                         // Adds a category to the current contact.
        Q_INVOKABLE void remove_category(const QString& category) noexcept;                      // Removes a category from the current contact.
        Q_INVOKABLE bool add_address_entry(QString type, QString key, QString value) noexcept;   // Adds an address entry to the current contact. Returns false if the key already exists in the given wallet type, false otherwise.
        Q_INVOKABLE void remove_address_entry(const QString& type, const QString& key) noexcept; // Removes an address entry from the current contact.
        Q_INVOKABLE void reload();                                                               // Reinitializes data from the persistent data ignoring pending changes.
        Q_INVOKABLE void save();                                                                 // Saves the current contact pending changes in the persistent data.
    
        // QML API Properties
        Q_PROPERTY(QString name READ get_name WRITE set_name NOTIFY nameChanged)
        Q_PROPERTY(QStringList categories READ get_categories WRITE set_categories NOTIFY categoriesChanged)
        Q_PROPERTY(addressbook_contact_proxy_filter_model* proxy_filter READ get_proxy_filter NOTIFY proxyFilterChanged)
        
        // QML API Properties Signals
      signals:
        void nameChanged();
        void categoriesChanged();
        void proxyFilterChanged();

      private:
        ag::ecs::system_manager&                m_system_manager;
    
        QString                                 m_name;
    
        QStringList                             m_categories;
        
        QVector<address_entry>                  m_address_entries;
    
        addressbook_contact_proxy_filter_model* m_proxy_filter;
    };
}