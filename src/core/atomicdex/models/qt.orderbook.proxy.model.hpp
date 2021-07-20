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
    class orderbook_proxy_model final : public QSortFilterProxyModel
    {
      Q_OBJECT
      ag::ecs::system_manager& m_system_mgr;
      public:
        //! Constructor
        orderbook_proxy_model(ag::ecs::system_manager& system_manager, QObject* parent);

        //! Destructor
        ~orderbook_proxy_model()  final = default;

        Q_INVOKABLE void qml_sort(int column, Qt::SortOrder order = Qt::AscendingOrder) ;

      protected:
        //! Override member functions
        [[nodiscard]] bool lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const final;
        [[nodiscard]] bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const final;
    };
} // namespace atomic_dex
