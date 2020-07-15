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

//! Project Headers
#include "atomic.dex.qt.portfolio.model.hpp"

namespace atomic_dex
{
    portfolio_model::portfolio_model(ag::ecs::system_manager& system_manager, QObject* parent) noexcept :
        QAbstractListModel(parent), m_system_manager(system_manager)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("portfolio model created");

        //! TMP
        {
            beginInsertRows(QModelIndex(), this->m_model_data.count(), this->m_model_data.count() + 1);
            this->m_model_data.push_back(portfolio_data{
                .ticker = "BTC", .balance = "2", .main_currency_balance = "18400", .change_24h = "2.4", .main_currency_price_for_one_unit = "9200"});
            endInsertRows();
        }
    }

    portfolio_model::~portfolio_model() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("portfolio model destroyed");
    }

    QVariant
    atomic_dex::portfolio_model::data(const QModelIndex& index, int role) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()))
        {
            return {};
        }

        const portfolio_data& item = m_model_data.at(index.row());
        switch (static_cast<PortfolioRoles>(role))
        {
        case TickerRole:
            return item.ticker;
        case BalanceRole:
            return item.balance;
        case MainCurrencyBalanceRole:
            return item.main_currency_balance;
        case Change24H:
            return item.change_24h;
        case MainCurrencyPriceForOneUnit:
            return item.main_currency_price_for_one_unit;
        }
        return {};
    }

    bool
    atomic_dex::portfolio_model::setData(const QModelIndex& index, const QVariant& value, int role)
    {
        (void)index;
        (void)value;
        (void)role;
        return false;
    }

    int
    atomic_dex::portfolio_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return this->m_model_data.count();
    }

    QHash<int, QByteArray>
    portfolio_model::roleNames() const
    {
        return {
            {TickerRole, "ticker"},
            {BalanceRole, "balance"},
            {MainCurrencyBalanceRole, "main_currency_balance"},
            {Change24H, "change_24h"},
            {MainCurrencyPriceForOneUnit, "main_currency_price_for_one_unit"}};
    }
} // namespace atomic_dex