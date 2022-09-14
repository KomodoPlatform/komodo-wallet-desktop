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

//! Project Headers
#include "atomicdex/models/qt.portfolio.proxy.filter.model.hpp"
#include "atomicdex/models/qt.portfolio.model.hpp"
#include "atomicdex/pages/qt.portfolio.page.hpp"

namespace atomic_dex
{
    //! Constructor
    portfolio_proxy_model::portfolio_proxy_model(ag::ecs::system_manager& system_manager, QObject* parent) :
        QSortFilterProxyModel(parent), m_system_mgr(system_manager)
    {
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
        case atomic_dex::portfolio_model::GuiTickerRole:
            return left_data.toString() > right_data.toString();
        case atomic_dex::portfolio_model::NameRole:
            return left_data.toString().toLower() < right_data.toString().toLower();
        case atomic_dex::portfolio_model::BalanceRole:
            return safe_float(left_data.toString().toStdString()) < safe_float(right_data.toString().toStdString());
        case atomic_dex::portfolio_model::MainCurrencyBalanceRole:
            if (left_data.toFloat() == right_data.toFloat())
            {
                left_data  = sourceModel()->data(source_left, atomic_dex::portfolio_model::BalanceRole);
                right_data = sourceModel()->data(source_right, atomic_dex::portfolio_model::BalanceRole);
            }
            return left_data.toFloat() < right_data.toFloat();
        case atomic_dex::portfolio_model::Change24H:
            return left_data.toFloat() < right_data.toFloat();
        case atomic_dex::portfolio_model::MainCurrencyPriceForOneUnit:
            return safe_float(left_data.toString().toStdString()) < safe_float(right_data.toString().toStdString());
        case portfolio_model::MainFiatPriceForOneUnit:
        case portfolio_model::Trend7D:
        case portfolio_model::ActivationStatus:
        case portfolio_model::Excluded:
        case portfolio_model::Display:
        case portfolio_model::NameAndTicker:
        case portfolio_model::MultiTickerCurrentlyEnabled:
        case portfolio_model::MultiTickerData:
        case portfolio_model::MultiTickerError:
        case portfolio_model::MultiTickerPrice:
        case portfolio_model::MultiTickerReceiveAmount:
        case portfolio_model::MultiTickerFeesInfo:
        case portfolio_model::CoinType:
        case portfolio_model::Address:
        case portfolio_model::PrivKey:
        case portfolio_model::PercentMainCurrency:
        case portfolio_model::PriceProvider:
        case portfolio_model::LastPriceTimestamp:
            return false;
        }
    }

    bool
    portfolio_proxy_model::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const
    {
        QModelIndex idx       = this->sourceModel()->index(source_row, 0, source_parent);
        assert(this->sourceModel()->hasIndex(idx.row(), 0));
        QString     ticker    = this->sourceModel()->data(idx, atomic_dex::portfolio_model::TickerRole).toString();
        QString     type      = this->sourceModel()->data(idx, atomic_dex::portfolio_model::CoinType).toString();

        if (this->filterRole() == atomic_dex::portfolio_model::MultiTickerCurrentlyEnabled)
        {
            bool is_enabled = this->sourceModel()->data(idx, atomic_dex::portfolio_model::MultiTickerCurrentlyEnabled).toBool();
            if (not is_enabled)
            {
                return false;
            }
        }

        // Filter by ticker name if `m_search_exp` is not empty.
        if (!m_search_exp.isEmpty())
        {
            if (not ticker.contains(m_search_exp, Qt::CaseInsensitive))
            {
                return false;
            }
        }

        if (am_i_a_market_selector && m_system_mgr.get_system<portfolio_page>().get_global_cfg()->get_coin_info(ticker.toStdString()).wallet_only)
        {
            return false;
        }

        if (m_excluded_coin == ticker)
        {
            return false;
        }

        if (m_with_balance)
        {
            if (this->sourceModel()->data(idx, portfolio_model::BalanceRole).toString().toFloat() == 0.F)
            {
                return false;
            }
        }

        if (m_with_fiat_balance)
        {
            if (this->sourceModel()->data(idx, portfolio_model::MainCurrencyBalanceRole).toFloat() == 0.F)
            {
                return false;
            }
        }

        return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
    }

    void
    portfolio_proxy_model::reset()
    {
        this->beginResetModel();
        this->endResetModel();
    }

    void
    portfolio_proxy_model::set_excluded_coin(const QString& ticker)
    {
        m_excluded_coin = ticker;
        this->invalidateFilter();
    }

    void
    portfolio_proxy_model::is_a_market_selector(bool is_market_selector)
    {
        this->am_i_a_market_selector = is_market_selector;
    }
} // namespace atomic_dex

//! QML API
namespace atomic_dex
{
    void
    portfolio_proxy_model::sort_by_name(bool is_ascending)
    {
        this->setSortRole(atomic_dex::portfolio_model::NameRole);
        this->sort(0, is_ascending ? Qt::AscendingOrder : Qt::DescendingOrder);
    }

    void
    portfolio_proxy_model::sort_by_currency_balance(bool is_ascending)
    {
        this->setSortRole(atomic_dex::portfolio_model::MainCurrencyBalanceRole);
        this->sort(0, is_ascending ? Qt::AscendingOrder : Qt::DescendingOrder);
    }

    void
    portfolio_proxy_model::sort_by_change_last24h(bool is_ascending)
    {
        this->setSortRole(atomic_dex::portfolio_model::Change24H);
        this->sort(0, is_ascending ? Qt::AscendingOrder : Qt::DescendingOrder);
    }

    void
    portfolio_proxy_model::sort_by_currency_unit(bool is_ascending)
    {
        this->setSortRole(atomic_dex::portfolio_model::MainCurrencyPriceForOneUnit);
        this->sort(0, is_ascending ? Qt::AscendingOrder : Qt::DescendingOrder);
    }

    bool
    portfolio_proxy_model::get_with_balance() const
    {
        return m_with_balance;
    }

    void
    portfolio_proxy_model::set_with_balance(bool value)
    {
        if (value != m_with_balance)
        {
            m_with_balance = value;
            this->invalidateFilter();
        }
    }

    void
    portfolio_proxy_model::set_with_fiat_balance(bool value)
    {
        if (value != m_with_fiat_balance)
        {
            m_with_fiat_balance = value;
            this->invalidateFilter();
        }
    }

    void
    portfolio_proxy_model::set_search_exp(QString search_exp)
    {
        if (search_exp != m_search_exp)
        {
            m_search_exp = std::move(search_exp);
            this->invalidateFilter();
        }
    }

    QString
    portfolio_proxy_model::get_search_exp() const
    {
        return m_search_exp;
    }

    QVariantMap
    atomic_dex::portfolio_proxy_model::get(int row)
    {
        QHash<int, QByteArray>         names = roleNames();
        QHashIterator<int, QByteArray> i(names);
        QVariantMap                    res;
        while (i.hasNext())
        {
            i.next();
            QModelIndex idx  = index(row, 0);
            QVariant    data = idx.data(i.key());
            res[i.value()]   = data;
        }
        return res;
    }
} // namespace atomic_dex
