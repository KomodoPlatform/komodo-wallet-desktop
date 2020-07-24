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

#include <QAbstractTableModel>

//! PCH
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.mm2.hpp"

namespace atomic_dex
{
    class candlestick_charts_model final : public QAbstractTableModel
    {
        Q_OBJECT
      public:
        candlestick_charts_model(ag::ecs::system_manager& system_manager, QObject* parent = nullptr);
        ~candlestick_charts_model() noexcept final;

        int      rowCount(const QModelIndex& parent) const override;
        int      columnCount(const QModelIndex& parent) const override;
        QVariant data(const QModelIndex& index, int role) const override;

      private:
        ag::ecs::system_manager& m_system_manager;

        nlohmann::json m_model_data;
    };
} // namespace atomic_dex