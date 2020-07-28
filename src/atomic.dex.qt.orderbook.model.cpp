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
    orderbook_model::orderbook_model(kind orderbook_kind, QObject* parent) : QAbstractTableModel(parent), m_current_orderbook_kind(orderbook_kind)
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
        return 0;
    }

    int
    orderbook_model::columnCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return 0;
    }

    QVariant
    orderbook_model::data([[maybe_unused]] const QModelIndex& index, [[maybe_unused]] int role) const
    {
        return QVariant();
    }

} // namespace atomic_dex