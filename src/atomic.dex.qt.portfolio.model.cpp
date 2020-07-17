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
#include "atomic.dex.qt.utilities.hpp"

//! Utils
namespace
{
    QString
    retrieve_change_24h(const atomic_dex::coinpaprika_provider& paprika, const atomic_dex::coin_config& coin, const atomic_dex::cfg& config)
    {
        auto    ticker_infos = paprika.get_ticker_infos(coin.ticker).answer;
        QString change_24h   = "0";
        if (not ticker_infos.empty() && ticker_infos.contains(config.current_currency))
        {
            auto change_24h_str =
                std::to_string(paprika.get_ticker_infos(coin.ticker).answer.at(config.current_currency).at("percent_change_24h").get<double>());
            std::replace(begin(change_24h_str), end(change_24h_str), ',', '.');
            change_24h = QString::fromStdString(change_24h_str);
        }
        return change_24h;
    }

    void
    update_value(atomic_dex::portfolio_model::PortfolioRoles role, const QString& value, const QModelIndex& idx, atomic_dex::portfolio_model& model)
    {
        if (value != model.data(idx, role).toString())
        {
            model.setData(idx, value, role);
        }
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
        this->m_model_proxy->setDynamicSortFilter(true);
        this->m_model_proxy->sort_by_currency_balance(false);
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
            .main_currency_price_for_one_unit = QString::fromStdString(paprika.get_rate_conversion(m_config.current_currency, coin.ticker, ec, true)),
            .trend_7d                         = nlohmann_json_array_to_qt_json_array(paprika.get_ticker_historical(coin.ticker).answer)};
        spdlog::trace(
            "inserting ticker {} with name {} balance {} main currency balance {}", coin.ticker, coin.name, data.balance.toStdString(),
            data.main_currency_balance.toStdString());
        this->m_model_data.push_back(std::move(data));
        endInsertRows();
    }

    void
    portfolio_model::update_currency_values()
    {
        const auto&        mm2_system = this->m_system_manager.get_system<mm2>();
        const auto&        paprika    = this->m_system_manager.get_system<coinpaprika_provider>();
        t_coins            coins      = mm2_system.get_enabled_coins();
        const std::string& currency   = m_config.current_currency;
        for (auto&& coin: coins)
        {
            const std::string& ticker = coin.ticker;
            if (const auto res = this->match(this->index(0, 0), TickerRole, QString::fromStdString(ticker)); not res.isEmpty())
            {
                std::error_code    ec;
                const QModelIndex& idx                         = res.at(0);
                const QString      main_currency_balance_value = QString::fromStdString(paprika.get_price_in_fiat(currency, ticker, ec));
                update_value(MainCurrencyBalanceRole, main_currency_balance_value, idx, *this);
                const QString currency_price_for_one_unit = QString::fromStdString(paprika.get_rate_conversion(currency, ticker, ec, true));
                update_value(MainCurrencyPriceForOneUnit, currency_price_for_one_unit, idx, *this);
                QString change24_h = retrieve_change_24h(paprika, coin, m_config);
                update_value(Change24H, change24_h, idx, *this);
                const QString balance = QString::fromStdString(mm2_system.my_balance(coin.ticker, ec));
                update_value(BalanceRole, balance, idx, *this);
            }
        }
    }

    void
    portfolio_model::update_balance_values(const std::string& ticker) noexcept
    {
        if (const auto res = this->match(this->index(0, 0), TickerRole, QString::fromStdString(ticker)); not res.isEmpty())
        {
            const auto&        mm2_system = this->m_system_manager.get_system<mm2>();
            const auto&        paprika    = this->m_system_manager.get_system<coinpaprika_provider>();
            std::error_code    ec;
            const std::string& currency = m_config.current_currency;
            const QModelIndex& idx      = res.at(0);
            const QString      balance  = QString::fromStdString(mm2_system.my_balance(ticker, ec));
            update_value(BalanceRole, balance, idx, *this);
            const QString main_currency_balance_value = QString::fromStdString(paprika.get_price_in_fiat(currency, ticker, ec));
            update_value(MainCurrencyBalanceRole, main_currency_balance_value, idx, *this);
            const QString currency_price_for_one_unit = QString::fromStdString(paprika.get_rate_conversion(currency, ticker, ec, true));
            update_value(MainCurrencyPriceForOneUnit, currency_price_for_one_unit, idx, *this);
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
        case Trend7D:
            return item.trend_7d;
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
        case Trend7D:
            item.trend_7d = value.toJsonArray();
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
        for (int row = 0; row < rows; ++row) { this->m_model_data.removeAt(position); }
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
                {Change24H, "change_24h"}, {MainCurrencyPriceForOneUnit, "main_currency_price_for_one_unit"},
                {Trend7D, "trend_7d"}};
    }

    portfolio_proxy_model*
    atomic_dex::portfolio_model::get_portfolio_proxy_mdl() const noexcept
    {
        return m_model_proxy;
    }
} // namespace atomic_dex