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

//! Project Headers
#include "atomic.dex.provider.cex.prices.hpp"

namespace
{
    constexpr const float g_margin = 0.02f;
}

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
        if (m_model_data.empty())
        {
            return 0;
        }
        return m_model_data.size();
    }

    int
    candlestick_charts_model::columnCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return 5;
    }

    QVariant
    candlestick_charts_model::data([[maybe_unused]] const QModelIndex& index, [[maybe_unused]] int role) const
    {
        Q_UNUSED(role)

        if (!index.isValid())
        {
            return QVariant();
        }

        if (index.row() >= rowCount() || index.row() < 0)
        {
            return QVariant();
        }

        switch (index.column())
        {
        case 0:
            return m_model_data.at(index.row()).at("timestamp").get<unsigned long long>() * 1000ull;
        case 1:
            return m_model_data.at(index.row()).at("open").get<double>();
        case 2:
            return m_model_data.at(index.row()).at("high").get<double>();
        case 3:
            return m_model_data.at(index.row()).at("low").get<double>();
        case 4:
            return m_model_data.at(index.row()).at("close").get<double>();

        default:
            return QVariant();
        }
    }

    void
    candlestick_charts_model::update_data()
    {
        auto& provider = this->m_system_manager.get_system<cex_prices_provider>();
        if (not provider.is_ohlc_data_available())
        {
            this->clear_data();
            return;
        }

        this->beginResetModel();
        this->m_model_data = provider.get_ohlc_data(m_current_range);
        this->endResetModel();

        assert(not m_model_data.empty());
        double max_value = std::numeric_limits<double>::min();
        double min_value = std::numeric_limits<double>::max();
        for (auto&& cur: m_model_data)
        {
            if (auto min_to_compare = cur.at("low").get<double>(); min_value > min_to_compare)
            {
                min_value = min_to_compare;
            }
            if (auto max_to_compare = cur.at("high").get<double>(); max_value < max_to_compare)
            {
                max_value = max_to_compare;
            }
        }
        spdlog::trace("new range value IS: min: {} / max: {}", min_value, max_value);
        this->set_min_value(min_value);
        this->set_max_value(max_value);
        emit seriesFromChanged(get_series_from());
        emit seriesToChanged(get_series_to());
        emit seriesSizeChanged(get_series_size());
    }

    int
    candlestick_charts_model::get_series_size() const noexcept
    {
        return rowCount();
    }

    void
    candlestick_charts_model::clear_data()
    {
        //! If it's already empty dont reset the model
        if (this->m_model_data.empty())
        {
            spdlog::trace("already empty, skipping");
            return;
        }

        spdlog::trace("clearing the chart candlestick model");
        beginResetModel();
        this->m_model_data.clear();
        this->set_min_value(0);
        this->set_max_value(0);
        endResetModel();
        emit seriesFromChanged(get_series_from());
        emit seriesToChanged(get_series_to());
        emit seriesSizeChanged(get_series_size());
    }

    QString
    candlestick_charts_model::get_current_range() const noexcept
    {
        return QString::fromStdString(m_current_range);
    }

    void
    candlestick_charts_model::set_current_range(const QString& range) noexcept
    {
        this->m_current_range = range.toStdString();
        update_data();
        emit rangeChanged();
    }

    QDateTime
    atomic_dex::candlestick_charts_model::get_series_to() const noexcept
    {
        if (this->m_model_data.empty())
        {
            return QDateTime();
        }
        QDateTime date_time;
        date_time.setSecsSinceEpoch(m_model_data.back().at("timestamp").get<int>());
        return date_time;
    }

    QDateTime
    atomic_dex::candlestick_charts_model::get_series_from() const noexcept
    {
        if (this->m_model_data.empty())
        {
            return QDateTime();
        }
        QDateTime date_time;
        date_time.setSecsSinceEpoch(m_model_data[int(this->m_model_data.size() * 0.9)].at("timestamp").get<int>());
        return date_time;
    }

    double
    candlestick_charts_model::get_min_value() const noexcept
    {
        return m_min_value;
    }

    double
    candlestick_charts_model::get_max_value() const noexcept
    {
        return m_max_value;
    }

    void
    candlestick_charts_model::set_max_value(double value)
    {
        qWarning("Floating point comparison needs context sanity check");
        if (qFuzzyCompare(m_max_value, value))
        {
            return;
        }

        m_max_value = value * (1 + g_margin);
        emit maxValueChanged(m_max_value);
    }

    void
    candlestick_charts_model::set_min_value(double value)
    {
        qWarning("Floating point comparison needs context sanity check");
        if (qFuzzyCompare(m_min_value, value))
        {
            return;
        }

        m_min_value = value * (1 - g_margin);
        emit minValueChanged(m_min_value);
    }
} // namespace atomic_dex