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
#include <QVector>

//! PCH
#include "atomic.dex.pch.hpp"

//! Project
#include "atomic.dex.qt.orders.data.hpp"

namespace atomic_dex
{
    class orders_model final : public QAbstractListModel
    {
        Q_OBJECT
        Q_ENUMS(OrdersRoles)
      public:
        enum OrdersRoles
        {
            BaseCoinRole = Qt::UserRole + 1,
            RelCoinRole,
            BaseCoinAmountRole,
            RelCoinAmountRole,
            OrderTypeRole,
            HumanDateRole,
            UnixTimestampRole,
            SwapIdRole,
            SwapStatusRole,
            MakePaymentSpentIdRole,
            TakerPaymentSentIdRole
        };


        orders_model(ag::ecs::system_manager& system_manager, QObject* parent = nullptr) noexcept;
        ~orders_model() noexcept final;
        int      rowCount(const QModelIndex& parent) const final;
        QVariant data(const QModelIndex& index, int role) const final;
        bool     removeRows(int row, int count, const QModelIndex& parent) final;

      private:
        ag::ecs::system_manager& m_system_manager;

        using t_orders_datas = QVector<order_data>;
        t_orders_datas m_datas;
    };
} // namespace atomic_dex