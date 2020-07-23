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
#include "atomic.dex.mm2.api.hpp"
#include "atomic.dex.qt.orders.data.hpp"
#include "atomic.dex.qt.orders.proxy.model.hpp"

namespace atomic_dex
{
    class orders_model final : public QAbstractListModel
    {
        Q_OBJECT
        Q_PROPERTY(orders_proxy_model* orders_proxy_mdl READ get_orders_proxy_mdl NOTIFY ordersProxyChanged);
        Q_PROPERTY(int length READ get_length NOTIFY lengthChanged);
        Q_ENUMS(OrdersRoles)
      public:
        enum OrdersRoles
        {
            BaseCoinRole = Qt::UserRole + 1,
            RelCoinRole,
            BaseCoinAmountRole,
            RelCoinAmountRole,
            OrderTypeRole,
            IsMakerRole,
            HumanDateRole,
            UnixTimestampRole,
            OrderIdRole,
            OrderStatusRole,
            MakerPaymentIdRole,
            TakerPaymentIdRole,
            IsSwapRole,
            CancellableRole,
            IsRecoverableRole,
            OrderErrorStateRole,
            OrderErrorMessageRole
        };


        orders_model(ag::ecs::system_manager& system_manager, QObject* parent = nullptr) noexcept;
        ~orders_model() noexcept final;
        int                    rowCount(const QModelIndex& parent) const final;
        QVariant               data(const QModelIndex& index, int role) const final;
        bool                   removeRows(int row, int count, const QModelIndex& parent) final;
        QHash<int, QByteArray> roleNames() const final;
        bool                   setData(const QModelIndex& index, const QVariant& value, int role) final;

        //! Public api
        void refresh_or_insert_orders() noexcept;
        void refresh_or_insert_swaps() noexcept;
        void clear_registry() noexcept;

        //! Properties
        [[nodiscard]] int                 get_length() const noexcept;
        [[nodiscard]] orders_proxy_model* get_orders_proxy_mdl() const noexcept;
      signals:
        void lengthChanged();
        void ordersProxyChanged();

      private:
        ag::ecs::system_manager& m_system_manager;

        using t_orders_datas       = QVector<order_data>;
        using t_orders_id_registry = std::unordered_set<std::string>;
        using t_swaps_id_registry  = std::unordered_set<std::string>;

        t_orders_id_registry m_orders_id_registry;
        t_swaps_id_registry  m_swaps_id_registry;
        t_orders_datas       m_model_data;

        orders_proxy_model* m_model_proxy;

        //! Private api
        void    initialize_order(const ::mm2::api::my_order_contents& contents) noexcept;
        void    update_existing_order(const ::mm2::api::my_order_contents& contents) noexcept;
        void    initialize_swap(const ::mm2::api::swap_contents& contents) noexcept;
        void    update_swap(const ::mm2::api::swap_contents& contents) noexcept;
        QString determine_order_status_from_last_event(const ::mm2::api::swap_contents& contents) noexcept;
        QString determine_payment_id(const ::mm2::api::swap_contents& contents, bool am_i_maker, bool want_taker_id) noexcept;
    };
} // namespace atomic_dex