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
        case orders_model::TickerPairRole:
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
            return left_data.toULongLong() < right_data.toULongLong();
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
        case orders_model::OrdersRoles::OrderErrorStateRole:
            break;
        case orders_model::OrdersRoles::OrderErrorMessageRole:
            break;
        case orders_model::EventsRole:
            break;
        case orders_model::SuccessEventsRole:
            break;
        case orders_model::ErrorEventsRole:
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
        if (is_history != this->m_is_history)
        {
            this->m_is_history = is_history;
            emit isHistoryChanged();
            this->invalidateFilter();
            emit qobject_cast<orders_model*>(this->sourceModel())->lengthChanged();
        }
    }

    bool
    orders_proxy_model::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const
    {
        QModelIndex idx = this->sourceModel()->index(source_row, 0, source_parent);
        assert(this->sourceModel()->hasIndex(idx.row(), 0));
        auto data      = this->sourceModel()->data(idx, orders_model::OrdersRoles::OrderStatusRole).toString();
        auto timestamp = this->sourceModel()->data(idx, orders_model::OrdersRoles::UnixTimestampRole).toULongLong();
        auto date      = QDateTime::fromMSecsSinceEpoch(timestamp).date();
        // qDebug() << date;

        assert(not data.isEmpty());
        if (not date_in_range(date))
        {
            return false;
        }
        if (this->m_is_history)
        {
            if (data == "matching" || data == "ongoing" || data == "matched" || data == "refunding")
            {
                return false;
            }
        }
        else
        {
            if (data == "successful" || data == "failed")
            {
                return false;
            }
        }
        return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
    }

    QDate
    orders_proxy_model::filter_minimum_date() const
    {
        return m_min_date;
    }

    void
    orders_proxy_model::set_filter_minimum_date(QDate date)
    {
        m_min_date = date;
        emit filterMinimumDateChanged();
        invalidateFilter();
    }

    QDate
    orders_proxy_model::filter_maximum_date() const
    {
        return m_max_date;
    }

    void
    orders_proxy_model::set_filter_maximum_date(QDate date)
    {
        m_max_date = date;
        emit filterMaximumDateChanged();
        invalidateFilter();
    }

    bool
    orders_proxy_model::date_in_range(QDate date) const
    {
        return (!m_min_date.isValid() || date > m_min_date) && (!m_max_date.isValid() || date < m_max_date);
    }

    QStringList
    orders_proxy_model::get_filtered_ids() const noexcept
    {
        QStringList out;
        int         nb_items = this->rowCount();
        out.reserve(nb_items);
        qDebug() << nb_items;
        for (int cur_idx = 0; cur_idx < nb_items; ++cur_idx)
        {
            QModelIndex idx = this->index(cur_idx, 0);
            out << this->data(idx, orders_model::OrdersRoles::OrderIdRole).toString();
        }
        return out;
    }
} // namespace atomic_dex