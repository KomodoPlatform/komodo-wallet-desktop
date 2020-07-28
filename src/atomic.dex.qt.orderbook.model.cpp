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

//! PCH
#include "atomic.dex.pch.hpp"

//! Project
#include "atomic.dex.qt.orderbook.model.hpp"

namespace atomic_dex
{
    orderbook_model::orderbook_model(t_orderbook_answer& orderbook, kind orderbook_kind, QObject* parent) :
        QAbstractListModel(parent), m_current_orderbook_kind(orderbook_kind), m_model_data(orderbook)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("orderbook model created");
    }

    orderbook_model::~orderbook_model() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("orderbook model destroyed");
    }

    int
    orderbook_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return m_current_orderbook_kind == kind::asks ? m_model_data.asks.size() : m_model_data.bids.size();
    }

    QVariant
    orderbook_model::data(const QModelIndex& index, int role) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()) || this->rowCount() == 0)
        {
            return {};
        }
        switch (static_cast<OrderbookRoles>(role))
        {
        case PriceRole:
            return m_current_orderbook_kind == kind::asks ? QString::fromStdString(m_model_data.asks.at(index.row()).price)
                                                          : QString::fromStdString(m_model_data.bids.at(index.row()).price);
        case QuantityRole:
            return m_current_orderbook_kind == kind::asks ? QString::fromStdString(m_model_data.asks.at(index.row()).maxvolume)
                                                          : QString::fromStdString(m_model_data.bids.at(index.row()).maxvolume);
        case TotalRole:
            return m_current_orderbook_kind == kind::asks ? QString::fromStdString(m_model_data.asks.at(index.row()).total)
                                                          : QString::fromStdString(m_model_data.bids.at(index.row()).total);
        }
    }

    QHash<int, QByteArray>
    orderbook_model::roleNames() const
    {
        return {{PriceRole, "price"}, {QuantityRole, "quantity"}, {TotalRole, "total"}};
    }

    void
    orderbook_model::reset_orderbook(t_orderbook_answer& orderbook) noexcept
    {
        this->beginResetModel();
        m_model_data = orderbook;
        this->endResetModel();
    }

} // namespace atomic_dex