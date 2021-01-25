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

//! Qt
#include <QSortFilterProxyModel>

namespace atomic_dex
{
    class addressbook_proxy_model final : public QSortFilterProxyModel
    {
        Q_OBJECT
        
        QString m_search_exp;
        
    public:
        addressbook_proxy_model(QObject* parent);
        ~addressbook_proxy_model() final = default;
    
        // Getters/Setters
        [[nodiscard]] const QString& get_search_exp() const noexcept;
        void                         set_search_exp(QString expression) noexcept;
        
        // QML Properties
        Q_PROPERTY(QString search_exp READ get_search_exp WRITE set_search_exp NOTIFY search_expChanged)
        
        // QML Properties Signals
    signals:
        void search_expChanged();
      
    protected:
        // QSortFilterProxyModel Functions
        [[nodiscard]] bool lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const final; // Only if sort role equals addressbook_model::SubModelRole, sorts contacts by their name in ascending order.
        [[nodiscard]] bool filterAcceptsRow(int source_row, const QModelIndex& source_parent) const override;     // Only if filter role equals addressbook_model::NameRoleAndCategoriesRole, accepts rows which match each word (not case sensitive) of m_search_exp.
    };
} // namespace atomic_dex
