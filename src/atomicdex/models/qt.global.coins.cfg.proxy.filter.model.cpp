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

#include "atomicdex/models/qt.global.coins.cfg.model.hpp"
#include "atomicdex/models/qt.global.coins.cfg.proxy.filter.model.hpp"

namespace atomic_dex
{
    global_coins_cfg_proxy_model::global_coins_cfg_proxy_model(QObject* parent) : QSortFilterProxyModel(parent)
    {}
} // namespace atomic_dex

//! Override
namespace atomic_dex
{
    bool
    global_coins_cfg_proxy_model::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const
    {
        [[maybe_unused]] QModelIndex idx = this->sourceModel()->index(source_row, 0, source_parent);
        assert(this->sourceModel()->hasIndex(idx.row(), 0));

        //! If we want only enableable coins let's refuse every rows that are already enabled
        if (m_exclude_enabled_coins)
        {
            if (this->sourceModel()->data(idx, atomic_dex::global_coins_cfg_model::CurrentlyEnabled).toBool())
            {
                return false;
            }
        }

        if (m_type < CoinType::AllDisabled)
        {
            if (this->sourceModel()->data(idx, atomic_dex::global_coins_cfg_model::CoinType) != static_cast<int>(m_type))
            {
                return false;
            }
        }

        //! Then use the filter by name
        return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
    }
    
    bool global_coins_cfg_proxy_model::lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const
    {
        int      role       = sortRole();
        QVariant left_data  = sourceModel()->data(source_left, role);
        QVariant right_data = sourceModel()->data(source_right, role);
    
        switch (static_cast<global_coins_cfg_model::CoinsRoles>(role))
        {
            case global_coins_cfg_model::CoinsRoles::NameRole:
            {
                QString left_coin  = left_data.toString();
                QString right_coin = right_data.toString();
                if (left_coin == "All")
                {
                    return true;
                }
                return left_coin.toLower() < right_coin.toLower();
            }
            default:
                break;
        }
        return false;
    }
} // namespace atomic_dex

//! QML API
namespace atomic_dex
{
    void
    global_coins_cfg_proxy_model::filter_by_enableable() noexcept
    {
        if (m_type == CoinType::All)
        {
            return;
        }
        m_exclude_enabled_coins = true;
        this->invalidateFilter();
    }

    void
    global_coins_cfg_proxy_model::filter_by_type(CoinType type) noexcept
    {
        m_type = type;
        this->invalidateFilter();
    }
} // namespace atomic_dex

//! Properties
namespace atomic_dex
{
    int global_coins_cfg_proxy_model::get_length() const noexcept
    {
        return rowCount();
    }
}