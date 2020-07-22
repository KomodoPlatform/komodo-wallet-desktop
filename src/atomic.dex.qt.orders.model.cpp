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

#include "atomic.dex.qt.orders.model.hpp"

namespace atomic_dex
{
    orders_model::orders_model(ag::ecs::system_manager& system_manager, QObject* parent) noexcept : QAbstractListModel(parent), m_system_manager(system_manager)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("orders model created");
    }

    orders_model::~orders_model() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("orders model destroyed");
    }

    int
    orders_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return this->m_datas.count();
    }

    QVariant
    orders_model::data(const QModelIndex& index, int role) const
    {
        return QVariant();
    }

    bool
    orders_model::removeRows(int position, int rows, [[maybe_unused]] const QModelIndex& parent)
    {
        spdlog::trace("(orders_model::removeRows) removing {} elements at position {}", rows, position);

        beginRemoveRows(QModelIndex(), position, position + rows - 1);
        for (int row = 0; row < rows; ++row)
        {
            this->m_datas.removeAt(position);
            // emit lengthChanged();
        }
        endRemoveRows();

        return true;
    }
} // namespace atomic_dex