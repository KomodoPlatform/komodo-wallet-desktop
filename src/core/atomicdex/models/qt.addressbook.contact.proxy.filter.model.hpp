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
    class addressbook_contact_proxy_filter_model final : public QSortFilterProxyModel
    {
        Q_OBJECT
        
        ag::ecs::system_manager& m_system_manager;
        
        QString m_search_expression;
        QString m_filter_type;
        
      public:
        explicit addressbook_contact_proxy_filter_model(ag::ecs::system_manager& system_manager, QObject* parent);
        ~addressbook_contact_proxy_filter_model() final = default;
        
        [[nodiscard]] const QString& get_search_expression() const ;
        void                         set_search_expression(QString value) ;
        [[nodiscard]] const QString& get_filter_type() const ;
        void                         set_filter_type(QString value) ;
        
        // QSortFilterProxyModel Functions
        [[nodiscard]] bool filterAcceptsRow(int source_row, const QModelIndex& source_parent) const override;
        [[nodiscard]] bool lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const final; // Sorts address entries by type then by key.
    
        // QML API Properties
        Q_PROPERTY(QString searchExpression READ get_search_expression WRITE set_search_expression NOTIFY searchExpressionChanged)
        Q_PROPERTY(QString filterType READ get_filter_type WRITE set_filter_type NOTIFY filterTypeChanged)
        
        // QML API Properties Signals
      signals:
        void searchExpressionChanged();
        void filterTypeChanged();
    };
}