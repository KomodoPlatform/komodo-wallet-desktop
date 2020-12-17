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
    global_coins_cfg_proxy_model::global_coins_cfg_proxy_model(QObject* parent) : QSortFilterProxyModel(parent) {}
} // namespace atomic_dex

//! Override
namespace atomic_dex
{
    bool
    global_coins_cfg_proxy_model::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const
    {
        //! If we want only enableable coins let's refuse every rows that are already enabled
        if (m_exclude_enabled_coins)
        {
            [[maybe_unused]] QModelIndex idx = this->sourceModel()->index(source_row, 0, source_parent);
            assert(this->sourceModel()->hasIndex(idx.row(), 0));
            if (this->sourceModel()->data(idx, atomic_dex::global_coins_cfg_model::CurrentlyEnabled).toBool())
            {
                return false;
            }
        }

        //! Then use the filter by name
        return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
    }
} // namespace atomic_dex

//! QML API
namespace atomic_dex
{
    void
    global_coins_cfg_proxy_model::filter_by_enableable() noexcept
    {
        m_exclude_enabled_coins = true;
        this->invalidateFilter();
    }
} // namespace atomic_dex