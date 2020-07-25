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
#include <QAbstractTableModel>

//! PCH
#include "atomic.dex.pch.hpp"

//! Project Header
#include "atomic.dex.ma.series.data.hpp"

namespace atomic_dex
{
    class ma_average_series_model final : public QAbstractTableModel
    {
        Q_OBJECT
      public:
        ma_average_series_model(QObject* parent = nullptr);
        ~ma_average_series_model() noexcept final;
        int      rowCount(const QModelIndex& parent = QModelIndex()) const final;
        int      columnCount(const QModelIndex& parent) const final;
        QVariant data(const QModelIndex& index, int role) const final;

        void
        set_model_data(std::vector<ma_series_data> model_data) noexcept;

      private:
        std::vector<ma_series_data> m_model_data;
    };
} // namespace atomic_dex