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
        if (m_model_data.empty() || !m_model_data.contains(m_current_range))
        {
            return 0;
        }
        return m_model_data.at(m_current_range).size();
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
            return m_model_data.at(m_current_range).at(index.row()).at("timestamp").get<int>() * 1000;
        case 1:
            return m_model_data.at(m_current_range).at(index.row()).at("open").get<double>();
        case 2:
            return m_model_data.at(m_current_range).at(index.row()).at("high").get<double>();
        case 3:
            return m_model_data.at(m_current_range).at(index.row()).at("low").get<double>();
        case 4:
            return m_model_data.at(m_current_range).at(index.row()).at("close").get<double>();

        default:
            return QVariant();
        }
    }

    void
    candlestick_charts_model::update_data()
    {
        this->beginResetModel();
        this->m_model_data = this->m_system_manager.get_system<cex_prices_provider>().get_all_ohlc_data();
        this->endResetModel();

        emit seriesFromChanged();
        emit seriesToChanged();
        emit seriesSizeChanged();
    }

    int
    candlestick_charts_model::get_series_size() const noexcept
    {
        return rowCount();
    }

    void
    candlestick_charts_model::clear_data()
    {
        beginResetModel();
        this->m_model_data.clear();
        endResetModel();
        emit seriesSizeChanged();
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
        if (this->m_model_data.empty() || !m_model_data.contains(m_current_range))
            return QDateTime();
        QDateTime date_time;
        date_time.setSecsSinceEpoch(m_model_data.at(m_current_range).back().at("timestamp").get<int>());
        return date_time;
    }

    QDateTime
    atomic_dex::candlestick_charts_model::get_series_from() const noexcept
    {
        if (this->m_model_data.empty() || !m_model_data.contains(m_current_range))
            return QDateTime();
        QDateTime date_time;
        date_time.setSecsSinceEpoch(m_model_data.at(m_current_range)[0].at("timestamp").get<int>());
        return date_time;
    }
} // namespace atomic_dex