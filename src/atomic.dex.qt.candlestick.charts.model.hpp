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
#include <QDateTime>

//! PCH
#include "atomic.dex.pch.hpp"

namespace atomic_dex
{
    class candlestick_charts_model final : public QAbstractTableModel
    {
        Q_OBJECT
        Q_PROPERTY(int series_size READ get_series_size NOTIFY seriesSizeChanged)
        Q_PROPERTY(QString current_range READ get_current_range WRITE set_current_range NOTIFY rangeChanged)
        Q_PROPERTY(QDateTime series_from READ get_series_from NOTIFY seriesFromChanged)
        Q_PROPERTY(QDateTime series_to READ get_series_to NOTIFY seriesToChanged)
      public:
        candlestick_charts_model(ag::ecs::system_manager& system_manager, QObject* parent = nullptr);
        ~candlestick_charts_model() noexcept final;

        [[nodiscard]] int      rowCount(const QModelIndex& parent = QModelIndex()) const final;
        [[nodiscard]] int      columnCount(const QModelIndex& parent) const final;
        [[nodiscard]] QVariant data(const QModelIndex& index, int role) const final;

        //! Public API
        void update_data();
        void clear_data();

        //! Property
        [[nodiscard]] int       get_series_size() const noexcept;
        [[nodiscard]] QDateTime get_series_from() const noexcept;
        [[nodiscard]] QDateTime get_series_to() const noexcept;
        [[nodiscard]] QString   get_current_range() const noexcept;
        void                    set_current_range(const QString& range) noexcept;

      signals:
        void seriesSizeChanged();
        void seriesFromChanged();
        void seriesToChanged();
        void rangeChanged();

      private:
        ag::ecs::system_manager& m_system_manager;

        nlohmann::json m_model_data;

        std::string m_current_range{"3600"}; //! 1h
    };
} // namespace atomic_dex