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

#include <QDebug>

//! PCH
#include "atomic.dex.pch.hpp"

//! Project
#include "atomic.dex.qt.orders.model.hpp"
#include "atomic.dex.qt.orders.proxy.model.hpp"

namespace atomic_dex
{
    orders_proxy_model::orders_proxy_model(QObject* parent) : QSortFilterProxyModel(parent)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("orders proxy model created");
    }

    orders_proxy_model::~orders_proxy_model()
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("orders proxy model destroyed");
    }

    bool
    orders_proxy_model::lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const
    {
        int      role       = this->sortRole();
        QVariant left_data  = sourceModel()->data(source_left, role);
        QVariant right_data = sourceModel()->data(source_right, role);
        switch (static_cast<atomic_dex::orders_model::OrdersRoles>(role))
        {
        case orders_model::BaseCoinRole:
            break;
        case orders_model::RelCoinRole:
            break;
        case orders_model::BaseCoinAmountRole:
            break;
        case orders_model::RelCoinAmountRole:
            break;
        case orders_model::OrderTypeRole:
            break;
        case orders_model::IsMakerRole:
            break;
        case orders_model::HumanDateRole:
            break;
        case orders_model::UnixTimestampRole:
            return left_data.toInt() < right_data.toInt();
        case orders_model::OrderIdRole:
            break;
        case orders_model::OrderStatusRole:
            break;
        case orders_model::MakerPaymentIdRole:
            break;
        case orders_model::TakerPaymentIdRole:
            break;
        case orders_model::IsSwapRole:
            break;
        case orders_model::CancellableRole:
            break;
        case orders_model::IsRecoverableRole:
            break;
        }
        return true;
    }

    bool
    orders_proxy_model::am_i_in_history() const noexcept
    {
        return m_is_history;
    }

    void
    orders_proxy_model::set_is_history(bool is_history) noexcept
    {
        if(is_history != this->m_is_history) {
            this->m_is_history = is_history;
            emit isHistoryChanged();
            this->invalidateFilter();
            emit qobject_cast<orders_model *>(this->sourceModel())->lengthChanged();
        }
    }

    bool
    orders_proxy_model::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const
    {
        QModelIndex idx  = this->sourceModel()->index(source_row, 0, source_parent);
        spdlog::trace("asking idx_row: {}, idx: {}, source_parent: {}", source_row, idx.row(), source_parent.row());
        assert(this->sourceModel()->hasIndex(idx.row(), 0));
        auto        data = this->sourceModel()->data(idx, orders_model::OrdersRoles::OrderStatusRole).toString();
        assert(not data.isEmpty());
        if (this->m_is_history)
        {
            if (data == "matching" || data == "ongoing" || data == "matched")
                return false;
        }
        else
        {
            if (data == "successful" || data == "failed")
                return false;
        }
        return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
    }
} // namespace atomic_dex