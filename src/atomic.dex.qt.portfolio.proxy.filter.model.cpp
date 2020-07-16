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

#include "atomic.dex.qt.portfolio.proxy.filter.model.hpp"
#include "atomic.dex.qt.portfolio.model.hpp"

namespace atomic_dex
{
    //! Constructor
    portfolio_proxy_model::portfolio_proxy_model(QObject* parent) : QSortFilterProxyModel(parent)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("portfolio proxy model created");
    }

    //! Destructor
    portfolio_proxy_model::~portfolio_proxy_model()
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("portfolio proxy model destroyed");
    }

    //! Override member functions
    bool
    portfolio_proxy_model::lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const
    {
        int      role       = this->sortRole();
        QVariant left_data  = sourceModel()->data(source_left, role);
        QVariant right_data = sourceModel()->data(source_right, role);
        switch (static_cast<atomic_dex::portfolio_model::PortfolioRoles>(role))
        {
        case atomic_dex::portfolio_model::TickerRole:
            return false;
        case atomic_dex::portfolio_model::BalanceRole:
            return t_float_50(left_data.toString().toStdString()) > t_float_50(right_data.toString().toStdString());
        case atomic_dex::portfolio_model::MainCurrencyBalanceRole:
            return t_float_50(left_data.toString().toStdString()) > t_float_50(right_data.toString().toStdString());
        case atomic_dex::portfolio_model::Change24H:
            return false;
        case atomic_dex::portfolio_model::MainCurrencyPriceForOneUnit:
            return false;
        case atomic_dex::portfolio_model::NameRole:
            return false;
        }
    }
} // namespace atomic_dex