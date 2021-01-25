/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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

//! QT Headers
#include <QAbstractTableModel>
#include <QDateTime>

//! Deps
#include <nlohmann/json_fwd.hpp>
#include <antara/gaming/ecs/system.manager.hpp>

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
        Q_PROPERTY(double visible_min_value READ get_visible_min_value WRITE set_visible_min_value NOTIFY visibleMinValueChanged)
        Q_PROPERTY(double visible_max_value READ get_visible_max_value WRITE set_visible_max_value NOTIFY visibleMaxValueChanged)
        Q_PROPERTY(double visible_max_volume READ get_visible_max_volume WRITE set_visible_max_volume NOTIFY visibleMaxVolumeChanged)
        Q_PROPERTY(bool is_current_pair_supported READ is_pair_supported WRITE set_is_pair_supported NOTIFY pairSupportedChanged)
        Q_PROPERTY(bool is_fetching READ is_currently_fetching WRITE set_is_currently_fetching NOTIFY fetchingStatusChanged)

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

        //! Public QML API
        Q_INVOKABLE QVariantMap    find_closest_ohlc_data(int timestamp);

        //! Property
        [[nodiscard]] bool      is_pair_supported() const noexcept;
        void                    set_is_pair_supported(bool is_support);
        [[nodiscard]] bool      is_currently_fetching() const noexcept;;
        void                    set_is_currently_fetching(bool is_fetching);;
        [[nodiscard]] int       get_series_size() const noexcept;
        [[nodiscard]] QDateTime get_series_from() const noexcept;
        [[nodiscard]] QDateTime get_series_to() const noexcept;
        [[nodiscard]] double    get_min_value() const noexcept;
        [[nodiscard]] double    get_max_value() const noexcept;
        [[nodiscard]] double    get_visible_min_value() const noexcept;
        [[nodiscard]] double    get_visible_max_value() const noexcept;
        [[nodiscard]] double    get_visible_max_volume() const noexcept;
        [[nodiscard]] double    get_global_min_value() const noexcept;
        [[nodiscard]] double    get_global_max_value() const noexcept;
        [[nodiscard]] QString   get_current_range() const noexcept;
        void                    set_current_range(const QString& range) noexcept;
        void                    set_min_value(double value);
        void                    set_max_value(double value);
        void                    set_visible_min_value(double value);
        void                    set_visible_max_value(double value);
        void                    set_visible_max_volume(double value);
        void                    set_series_from(QDateTime value);
        void                    set_series_to(QDateTime value);

      signals:
        void seriesSizeChanged(int value);
        void seriesFromChanged(QDateTime date);
        void seriesToChanged(QDateTime date);
        void minValueChanged(double value);
        void maxValueChanged(double value);
        void visibleMinValueChanged(double value);
        void visibleMaxValueChanged(double value);
        void visibleMaxVolumeChanged(double value);
        void globalMinValueChanged(double value);
        void globalMaxValueChanged(double value);
        void pairSupportedChanged(bool supported);
        void fetchingStatusChanged(bool fetching_status);
        void rangeChanged();
        void maTwentySeriesChanged();
        void maFiftySeriesChanged();
        void chartFullyModelReset();

      private:
        void set_global_min_value(double value);
        void set_global_max_value(double value);
        void update_visible_range();

        bool common_reset_data();

        ag::ecs::system_manager& m_system_manager;

        nlohmann::json m_model_data;

        std::string m_current_range{"3600"}; //! 1h

        bool      m_current_pair_supported{false};
        bool      m_currently_fetching{false};
        double    m_visible_min_value{0};
        double    m_visible_max_value{0};
        double    m_visible_max_volume{0};
        double    m_max_value{0};
        double    m_min_value{0};
        double    m_global_max_value{0};
        double    m_global_min_value{0};
        QDateTime m_series_from;
        QDateTime m_series_to;
    };
} // namespace atomic_dex
