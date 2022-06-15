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

// Qt Headers
#include <QSortFilterProxyModel> //> QSortFilterProxyModel

// Deps Headers
#include <antara/gaming/ecs/system.manager.hpp> //> antara::gaming, ag::ecs::system_manager

namespace ag = antara::gaming;

namespace atomic_dex
{
    class addressbook_proxy_model final : public QSortFilterProxyModel
    {
        Q_OBJECT
        
        ag::ecs::system_manager& m_system_manager;
        
        QString                  m_search_exp;
        
        QString                  m_type_filter; // Contains the address type that a contact should have on one of its addresses to validate the filtering.
        
    public:
        addressbook_proxy_model(ag::ecs::system_manager& system_manager, QObject* parent);
        ~addressbook_proxy_model() final = default;
        
        // QSortFilterProxyModel Functions
        [[nodiscard]] bool lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const final; // Only if sort role equals addressbook_model::SubModelRole, sorts contacts by their name in ascending order.
        [[nodiscard]] bool filterAcceptsRow(int source_row, const QModelIndex& source_parent) const override;     // Only if filter role equals addressbook_model::NameRoleAndCategoriesRole, accepts rows which match each word (not case sensitive) of m_search_exp. Also filters contacts which have at least one address of type equivalent to the one specified by the member `m_filter_type`.
    
        // Getters/Setters
        [[nodiscard]] const QString& get_search_exp() const ;
        void                         set_search_exp(QString expression) ;
        [[nodiscard]] const QString& get_type_filter() const ;
        void                         set_type_filter(QString value) ;
        
        // QML Properties
        Q_PROPERTY(QString searchExp READ get_search_exp WRITE set_search_exp NOTIFY searchExpChanged)
        Q_PROPERTY(QString typeFilter READ get_type_filter WRITE set_type_filter NOTIFY typeFilterChanged)
        
        // QML Properties Signals
    signals:
        void searchExpChanged();
        void typeFilterChanged();
    };
} // namespace atomic_dex
