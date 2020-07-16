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

//! Utils
namespace
{
    QString
    retrieve_change_24h(const atomic_dex::coinpaprika_provider& paprika, atomic_dex::coin_config& coin, atomic_dex::cfg& config)
    {
        auto    ticker_infos = paprika.get_ticker_infos(coin.ticker).answer;
        QString change_24h   = "0";
        if (not ticker_infos.empty() && ticker_infos.contains(config.current_currency))
        {
            auto change_24h_str = std::to_string(paprika.get_ticker_infos(coin.ticker).answer.at(config.current_currency).at("percent_change_24h").get<double>());
            std::replace(begin(change_24h_str), end(change_24h_str), ',', '.');
            change_24h = QString::fromStdString(change_24h_str);
        }
        return change_24h;
    }
} // namespace
namespace atomic_dex
{
    portfolio_model::portfolio_model(ag::ecs::system_manager& system_manager, atomic_dex::cfg& config, QObject* parent) noexcept :
        QAbstractListModel(parent), m_system_manager(system_manager), m_config(config), m_model_proxy(new portfolio_proxy_model(this))
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("portfolio model created");

        this->m_model_proxy->setSourceModel(this);
        this->m_model_proxy->setSortRole(MainCurrencyBalanceRole);
        this->m_model_proxy->setDynamicSortFilter(true);
        this->m_model_proxy->sort(0);
    }

    portfolio_model::~portfolio_model() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("portfolio model destroyed");
    }

    void
    atomic_dex::portfolio_model::initialize_portfolio(std::string ticker)
    {
        const auto& mm2_system = this->m_system_manager.get_system<mm2>();
        const auto& paprika    = this->m_system_manager.get_system<coinpaprika_provider>();
        auto        coin       = mm2_system.get_coin_info(ticker);

        beginInsertRows(QModelIndex(), this->m_model_data.count(), this->m_model_data.count());
        std::error_code ec;
        const QString   change_24h = retrieve_change_24h(paprika, coin, m_config);
        portfolio_data  data{
            .ticker                           = QString::fromStdString(coin.ticker),
            .name                             = QString::fromStdString(coin.name),
            .balance                          = QString::fromStdString(mm2_system.my_balance(coin.ticker, ec)),
            .main_currency_balance            = QString::fromStdString(paprika.get_price_in_fiat(m_config.current_currency, coin.ticker, ec)),
            .change_24h                       = change_24h,
            .main_currency_price_for_one_unit = QString::fromStdString(paprika.get_rate_conversion(m_config.current_currency, coin.ticker, ec, true))};
        spdlog::trace(
            "inserting ticker {} with name {} balance {} main currency balance {}", coin.ticker, coin.name, data.balance.toStdString(),
            data.main_currency_balance.toStdString());
        this->m_model_data.push_back(std::move(data));
        endInsertRows();
    }

    void
    portfolio_model::update_currency_values()
    {
        const auto&     mm2_system = this->m_system_manager.get_system<mm2>();
        const auto&     paprika    = this->m_system_manager.get_system<coinpaprika_provider>();
        auto            coins = mm2_system.get_enabled_coins();
        for (auto&& coin: coins)
        {
            std::error_code ec;
            const auto res = this->match(this->index(0, 0), TickerRole, QString::fromStdString(coin.ticker));
            assert(not res.empty());
            const auto idx           = res.at(0);
            const auto balance_value = QString::fromStdString(paprika.get_price_in_fiat(m_config.current_currency, coin.ticker, ec));
            ec = {};
            spdlog::trace("new balance_value {} for ticker {} with currency {}", balance_value.toStdString(), coin.ticker, m_config.current_currency);
            if (balance_value != this->data(idx, MainCurrencyBalanceRole).toString())
            {
                this->setData(idx, balance_value, MainCurrencyBalanceRole);
            }
            const auto currency_price_for_one_unit = QString::fromStdString(paprika.get_rate_conversion(m_config.current_currency, coin.ticker, ec, true));
            ec = {};
            if (currency_price_for_one_unit != this->data(idx, MainCurrencyPriceForOneUnit).toString())
            {
                this->setData(idx, currency_price_for_one_unit, MainCurrencyPriceForOneUnit);
            }
            const auto change24_h = retrieve_change_24h(paprika, coin, m_config);
            if (change24_h != this->data(idx, Change24H).toString())
            {
                this->setData(idx, change24_h, Change24H);
            }
        }
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
        case NameRole:
            return item.name;
        }
        return {};
    }

    bool
    atomic_dex::portfolio_model::setData(const QModelIndex& index, const QVariant& value, int role)
    {
        if (!hasIndex(index.row(), index.column(), index.parent()) || !value.isValid())
        {
            return false;
        }

        portfolio_data& item = m_model_data[index.row()];
        switch (static_cast<PortfolioRoles>(role))
        {
        case BalanceRole:
            item.balance = value.toString();
            break;
        case MainCurrencyBalanceRole:
            item.main_currency_balance = value.toString();
            break;
        case Change24H:
            item.change_24h = value.toString();
            break;
        case MainCurrencyPriceForOneUnit:
            item.main_currency_price_for_one_unit = value.toString();
            break;
        default:
            return false;
        }

        emit dataChanged(index, index, {role});
        return true;
    }

    bool
    portfolio_model::removeRows(int position, int rows, [[maybe_unused]] const QModelIndex& parent)
    {
        spdlog::trace("(portfolio_model::removeRows) removing {} elements at position {}", rows, position);
        beginRemoveRows(QModelIndex(), position, position + rows - 1);

        for (int row = 0; row < rows; ++row)
        {
            //! remove at
            this->m_model_data.removeAt(position);
        }

        endRemoveRows();
        return true;
    }

    void
    portfolio_model::disable_coins(const QStringList& coins)
    {
        for (auto&& coin: coins)
        {
            auto res = this->match(this->index(0, 0), TickerRole, coin);
            assert(not res.empty());
            this->removeRow(res.at(0).row());
        }
    }

    int
    atomic_dex::portfolio_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return this->m_model_data.count();
    }

    QHash<int, QByteArray>
    portfolio_model::roleNames() const
    {
        return {{TickerRole, "ticker"},    {NameRole, "name"},
                {BalanceRole, "balance"},  {MainCurrencyBalanceRole, "main_currency_balance"},
                {Change24H, "change_24h"}, {MainCurrencyPriceForOneUnit, "main_currency_price_for_one_unit"}};
    }

    atomic_dex::portfolio_proxy_model*
    atomic_dex::portfolio_model::get_portfolio_proxy_mdl() const noexcept
    {
        return m_model_proxy;
    }
} // namespace atomic_dex

namespace atomic_dex
{
    portfolio_proxy_model::portfolio_proxy_model(QObject* parent) : QSortFilterProxyModel(parent)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("portfolio proxy model created");
    }
    portfolio_proxy_model::~portfolio_proxy_model()
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("portfolio proxy model destroyed");
    }

    bool
    portfolio_proxy_model::lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const
    {
        int      role       = this->sortRole();
        QVariant left_data  = sourceModel()->data(source_left, role);
        QVariant right_data = sourceModel()->data(source_right, role);
        switch (static_cast<portfolio_model::PortfolioRoles>(role))
        {
        case portfolio_model::TickerRole:
            return false;
        case portfolio_model::BalanceRole:
            return t_float_50(left_data.toString().toStdString()) > t_float_50(right_data.toString().toStdString());
        case portfolio_model::MainCurrencyBalanceRole:
            return t_float_50(left_data.toString().toStdString()) > t_float_50(right_data.toString().toStdString());
        case portfolio_model::Change24H:
            return false;
        case portfolio_model::MainCurrencyPriceForOneUnit:
            return false;
        case portfolio_model::NameRole:
            return false;
        }
    }
} // namespace atomic_dex