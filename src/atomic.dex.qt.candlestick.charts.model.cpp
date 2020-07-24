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

#include "atomic.dex.qt.candlestick.charts.model.hpp"

namespace atomic_dex
{
    candlestick_charts_model::candlestick_charts_model(ag::ecs::system_manager& system_manager, QObject* parent) :
        QAbstractTableModel(parent), m_system_manager(system_manager)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("candlestick charts model created");
    }

    candlestick_charts_model::~candlestick_charts_model() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("candlestick charts model destroyed");
    }

    int
    candlestick_charts_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return 0;
    }

    int
    candlestick_charts_model::columnCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return 5;
    }

    QVariant
    candlestick_charts_model::data([[maybe_unused]] const QModelIndex& index, [[maybe_unused]] int role) const
    {
        return QVariant();
    }
} // namespace atomic_dex