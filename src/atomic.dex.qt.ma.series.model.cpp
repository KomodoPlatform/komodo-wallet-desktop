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

//! Project headers
#include "atomic.dex.qt.ma.series.model.hpp"

namespace atomic_dex
{
    ma_average_series_model::ma_average_series_model(QObject* parent) : QAbstractTableModel(parent)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("ma average series created");
    }

    ma_average_series_model::~ma_average_series_model() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("ma average series destroyed");
    }

    int
    ma_average_series_model::rowCount(const QModelIndex& parent) const
    {
        return m_model_data.size();
    }

    int
    ma_average_series_model::columnCount(const QModelIndex& parent) const
    {
        return 2;
    }

    QVariant
    ma_average_series_model::data(const QModelIndex& index, int role) const
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
            return quint64(m_model_data.at(index.row()).m_timestamp) * 1000;
        case 1:
            return m_model_data.at(index.row()).m_average;
        }
        return QVariant();
    }

    void
    ma_average_series_model::set_model_data(std::vector<ma_series_data> model_data) noexcept
    {
        this->beginResetModel();
        m_model_data = std::move(model_data);
        this->endResetModel();
    }
} // namespace atomic_dex