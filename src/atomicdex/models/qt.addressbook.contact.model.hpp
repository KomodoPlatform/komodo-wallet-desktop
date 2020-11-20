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
#include <QAbstractListModel> //> QAbstractListModel.
#include <QObject>            //> Q_OBJECT, Q_PROPERTY, QObject.

//! Deps
#include <spdlog/spdlog.h>

//! Project Headers
#include "atomicdex/managers/addressbook.manager.hpp" //> addressbook_manager.

namespace atomic_dex
{
    class addressbook_contact_model final : public QAbstractListModel
    {
        friend class addressbook_model;
        
        /// \brief Tells QT this class uses signal/slots mechanisms and/or has GUI elements.
        Q_OBJECT
        
        /// \defgroup Members
        /// {@
        
        addressbook_manager& m_addressbook_manager;
        
        QString              m_name;
        
        QStringList          m_categories;

        /// @} End of Members section.
        
        Q_ENUMS(ContactRoles)
    public:
        enum ContactRoles
        {
            TypeRole,
            AddressesRole
        };
        
    public:
        /// \defgroup Constructors
        /// {@
        
        explicit addressbook_contact_model(addressbook_manager& addrbook_manager, QString name, QObject* parent = nullptr);
        ~addressbook_contact_model() noexcept;
    
        /// @} End of Constructors section.
    
        /// \defgroup QAbstractListModel implementation.
        /// {@
    
        [[nodiscard]] QVariant               data(const QModelIndex& index, int role) const final;
        bool                                 setData(const QModelIndex& index, const QVariant& value, int role) final;
        [[nodiscard]] int                    rowCount(const QModelIndex& parent = QModelIndex()) const final;
        bool                                 insertRows(int position, int rows, const QModelIndex& parent) final;
        bool                                 removeRows(int position, int rows, const QModelIndex& parent = QModelIndex()) final;
        [[nodiscard]] QHash<int, QByteArray> roleNames() const final;
    
        /// @} End of QAbstractListModel implementation section.
    
        [[nodiscard]]
        const QString& get_name() const noexcept;
        
        void set_name(const QString& name) noexcept;
        
        [[nodiscard]]
        const QStringList& get_categories() const noexcept;
        
        /// \defgroup QML API.
        /// {@
        
        Q_PROPERTY(QString name READ get_name WRITE set_name NOTIFY nameChanged)
        
      signals:
        void nameChanged();
        void categoriesChanged();
        void walletsInfoChanged();
        
        /// @} End of QML API section.
    };
}