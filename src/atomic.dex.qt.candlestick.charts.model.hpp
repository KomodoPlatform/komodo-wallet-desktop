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
#include "atomic.dex.qt.ma.series.model.hpp"

namespace atomic_dex
{
    class candlestick_charts_model final : public QAbstractTableModel
    {
        Q_OBJECT
        Q_PROPERTY(int series_size READ get_series_size NOTIFY seriesSizeChanged)
        Q_PROPERTY(QString current_range READ get_current_range WRITE set_current_range NOTIFY rangeChanged)
        Q_PROPERTY(QDateTime series_from READ get_series_from WRITE set_series_from NOTIFY seriesFromChanged)
        Q_PROPERTY(QDateTime series_to READ get_series_to WRITE set_series_to NOTIFY seriesToChanged)
        Q_PROPERTY(double min_value READ get_min_value WRITE set_min_value NOTIFY minValueChanged)
        Q_PROPERTY(double max_value READ get_max_value WRITE set_max_value NOTIFY maxValueChanged)
        Q_PROPERTY(double global_max_value READ get_global_max_value NOTIFY globalMaxValueChanged)
        Q_PROPERTY(double global_min_value READ get_global_min_value NOTIFY globalMinValueChanged)
        Q_PROPERTY(ma_average_series_model* ma_20_series_mdl READ get_ma_20_series NOTIFY maTwentySeriesChanged)
        Q_PROPERTY(ma_average_series_model* ma_50_series_mdl READ get_ma_50_series NOTIFY maFiftySeriesChanged)

      public:
        candlestick_charts_model(ag::ecs::system_manager& system_manager, QObject* parent = nullptr);
        ~candlestick_charts_model() noexcept final;

        [[nodiscard]] int      rowCount(const QModelIndex& parent = QModelIndex()) const final;
        [[nodiscard]] int      columnCount(const QModelIndex& parent) const final;
        [[nodiscard]] QVariant data(const QModelIndex& index, int role) const final;

        //! Public API
        void init_data();
        void update_data();
        void clear_data();

        //! Property
        [[nodiscard]] ma_average_series_model* get_ma_20_series() const noexcept;
        [[nodiscard]] ma_average_series_model* get_ma_50_series() const noexcept;
        [[nodiscard]] int                      get_series_size() const noexcept;
        [[nodiscard]] QDateTime                get_series_from() const noexcept;
        [[nodiscard]] QDateTime                get_series_to() const noexcept;
        [[nodiscard]] double                   get_min_value() const noexcept;
        [[nodiscard]] double                   get_max_value() const noexcept;
        [[nodiscard]] double                   get_global_min_value() const noexcept;
        [[nodiscard]] double                   get_global_max_value() const noexcept;
        [[nodiscard]] QString                  get_current_range() const noexcept;
        void                                   set_current_range(const QString& range) noexcept;
        void                                   set_min_value(double value);
        void                                   set_max_value(double value);
        void                                   set_series_from(QDateTime value);
        void                                   set_series_to(QDateTime value);

      signals:
        void seriesSizeChanged(int value);
        void seriesFromChanged(QDateTime date);
        void seriesToChanged(QDateTime date);
        void minValueChanged(double value);
        void maxValueChanged(double value);
        void globalMinValueChanged(double value);
        void globalMaxValueChanged(double value);
        void rangeChanged();
        void maTwentySeriesChanged();
        void maFiftySeriesChanged();

      private:
        void set_global_min_value(double value);
        void set_global_max_value(double value);

        bool common_reset_data();

        ag::ecs::system_manager& m_system_manager;
        ma_average_series_model* m_ma_20_series;
        ma_average_series_model* m_ma_50_series;


        nlohmann::json m_model_data;

        std::string m_current_range{"3600"}; //! 1h

        double    m_min_value{0};
        double    m_max_value{0};
        double    m_global_max_value{0};
        double    m_global_min_value{0};
        QDateTime m_series_from;
        QDateTime m_series_to;
    };
} // namespace atomic_dex