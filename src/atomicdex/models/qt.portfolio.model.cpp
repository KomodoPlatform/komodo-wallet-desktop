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

#include <QJSValue>
#include <taskflow/taskflow.hpp>

//! PCH
#include "src/atomicdex/pch.hpp"

//! Project Headers
#include "atomicdex/services/price/global.provider.hpp"
#include "qt.portfolio.model.hpp"
#include "src/atomicdex/events/qt.events.hpp"
#include "src/atomicdex/pages/qt.wallet.page.hpp"
#include "src/atomicdex/utilities/qt.utilities.hpp"

//! Utils
namespace
{
    template <typename TModel>
    auto
    update_value(int role, const QVariant& value, const QModelIndex& idx, TModel& model)
    {
        if (auto prev_value = model.data(idx, role); value != prev_value)
        {
            model.setData(idx, value, role);
            return std::make_tuple(prev_value, value, true);
        }
        return std::make_tuple(value, value, false);
    }
} // namespace

namespace atomic_dex
{
    portfolio_model::portfolio_model(ag::ecs::system_manager& system_manager, entt::dispatcher& dispatcher, QObject* parent) noexcept :
        QAbstractListModel(parent), m_system_manager(system_manager), m_dispatcher(dispatcher), m_model_proxy(new portfolio_proxy_model(parent))
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("portfolio model created");

        this->m_model_proxy->setSourceModel(this);
        this->m_model_proxy->setDynamicSortFilter(true);
        this->m_model_proxy->sort_by_currency_balance(false);
        this->m_model_proxy->setFilterRole(NameAndTicker);
        this->m_model_proxy->setFilterCaseSensitivity(Qt::CaseInsensitive);
    }

    portfolio_model::~portfolio_model() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("portfolio model destroyed");
    }

    void
    atomic_dex::portfolio_model::initialize_portfolio(const std::vector<std::string>& tickers)
    {
        QVector<portfolio_data> datas;

        for (auto&& ticker: tickers)
        {
            if (m_ticker_registry.find(ticker) != m_ticker_registry.end())
                continue;
            const auto& mm2_system    = this->m_system_manager.get_system<mm2_service>();
            const auto& price_service = this->m_system_manager.get_system<global_price_service>();
            const auto& paprika       = this->m_system_manager.get_system<coinpaprika_provider>();
            auto        coin          = mm2_system.get_coin_info(ticker);


            std::error_code ec;
            const QString   change_24h = retrieve_change_24h(paprika, coin, *m_config);
            portfolio_data  data{
                .ticker                = QString::fromStdString(coin.ticker),
                .coin_type = QString::fromStdString(coin.type),
                .name                  = QString::fromStdString(coin.name),
                .balance               = QString::fromStdString(mm2_system.my_balance(coin.ticker, ec)),
                .main_currency_balance = QString::fromStdString(price_service.get_price_in_fiat(m_config->current_currency, coin.ticker, ec)),
                .change_24h            = change_24h,
                .main_currency_price_for_one_unit =
                    QString::fromStdString(price_service.get_rate_conversion(m_config->current_currency, coin.ticker, ec, true)),
                .main_fiat_price_for_one_unit = QString::fromStdString(price_service.get_rate_conversion(m_config->current_fiat, coin.ticker, ec)),
                .trend_7d                     = nlohmann_json_array_to_qt_json_array(paprika.get_ticker_historical(coin.ticker).answer),
                .is_excluded                  = false,
            };
            data.display         = data.ticker + " (" + data.balance + ")";
            data.ticker_and_name = data.ticker + data.name;
            spdlog::trace(
                "inserting ticker {} with name {} balance {} main currency balance {}", coin.ticker, coin.name, data.balance.toStdString(),
                data.main_currency_balance.toStdString());
            datas.push_back(std::move(data));
            m_ticker_registry.emplace(ticker);
        }
        if (not datas.isEmpty())
        {
            beginInsertRows(QModelIndex(), this->m_model_data.count(), this->m_model_data.count() + tickers.size() - 1);
            this->m_model_data.append(datas);
            endInsertRows();
            spdlog::trace("size of the portfolio {}", this->get_length());
            emit lengthChanged();
        }
    }

    void
    portfolio_model::update_currency_values()
    {
        const auto&        mm2_system    = this->m_system_manager.get_system<mm2_service>();
        const auto&        price_service = this->m_system_manager.get_system<global_price_service>();
        const auto&        paprika       = this->m_system_manager.get_system<coinpaprika_provider>();
        t_coins            coins         = mm2_system.get_enabled_coins();
        const std::string& currency      = m_config->current_currency;
        const std::string& fiat          = m_config->current_fiat;
        tf::Executor       executor;
        tf::Taskflow       taskflow;
        for (auto&& coin: coins)
        {
            // spdlog::trace("trying updating currency values of: {}", coin.ticker);
            if (m_ticker_registry.find(coin.ticker) == m_ticker_registry.end())
            {
                spdlog::debug("ticker: {} not inserted yet in the model, skipping", coin.ticker);
                continue;
            }
            auto update_functor = [coin, &paprika, &mm2_system, &price_service, currency, fiat, this]() {
                const std::string& ticker = coin.ticker;
                if (const auto res = this->match(this->index(0, 0), TickerRole, QString::fromStdString(ticker)); not res.isEmpty())
                {
                    std::error_code    ec;
                    const QModelIndex& idx                         = res.at(0);
                    const QString      main_currency_balance_value = QString::fromStdString(price_service.get_price_in_fiat(currency, ticker, ec));
                    update_value(MainCurrencyBalanceRole, main_currency_balance_value, idx, *this);
                    const QString currency_price_for_one_unit = QString::fromStdString(price_service.get_rate_conversion(currency, ticker, ec, true));
                    update_value(MainCurrencyPriceForOneUnit, currency_price_for_one_unit, idx, *this);
                    const QString currency_fiat_for_one_unit = QString::fromStdString(price_service.get_rate_conversion(fiat, ticker, ec, false));
                    update_value(MainFiatPriceForOneUnit, currency_fiat_for_one_unit, idx, *this);
                    QString change24_h = retrieve_change_24h(paprika, coin, *m_config);
                    update_value(Change24H, change24_h, idx, *this);
                    const QString balance                           = QString::fromStdString(mm2_system.my_balance(coin.ticker, ec));
                    auto&& [prev_balance, new_balance, is_change_b] = update_value(BalanceRole, balance, idx, *this);
                    const QString display                           = QString::fromStdString(coin.ticker) + " (" + balance + ")";
                    update_value(Display, display, idx, *this);
                    if (is_change_b)
                    {
                        t_float_50 prev_balance_f(prev_balance.toString().toStdString());
                        t_float_50 new_balance_f(new_balance.toString().toStdString());
                        bool       am_i_sender = false;
                        if (prev_balance_f > new_balance_f)
                        {
                            am_i_sender = true;
                        }
                        t_float_50 amount_f = am_i_sender ? prev_balance_f - new_balance_f : new_balance_f - prev_balance_f;
                        QString    amount   = QString::fromStdString(amount_f.str(8, std::ios_base::fixed));
                        using namespace std::chrono;
                        qint64  timestamp  = duration_cast<seconds>(system_clock::now().time_since_epoch()).count();
                        QString human_date = QString::fromStdString(to_human_date<std::chrono::seconds>(timestamp, "%e %b %Y, %H:%M"));
                        spdlog::debug(
                            "balance update notification from update_currency_values prev[{}], new[{}]", prev_balance.toString().toStdString(),
                            new_balance.toString().toStdString());
                        this->m_dispatcher.trigger<balance_update_notification>(am_i_sender, amount, QString::fromStdString(ticker), human_date, timestamp);
                    }
                    // spdlog::trace("updated currency values of: {}", ticker);
                }
            };
            taskflow.emplace(update_functor);
        }
        executor.run(taskflow).wait();
    }

    void
    portfolio_model::update_balance_values(const std::vector<std::string>& tickers) noexcept
    {
        for (auto&& ticker: tickers)
        {
            if (m_ticker_registry.find(ticker) == m_ticker_registry.end())
            {
                spdlog::debug("ticker: {} not inserted yet in the model, skipping", ticker);
                continue;
            }
            // spdlog::trace("trying updating balance values of: {}", ticker);
            if (const auto res = this->match(this->index(0, 0), TickerRole, QString::fromStdString(ticker)); not res.isEmpty())
            {
                const auto&        mm2_system    = this->m_system_manager.get_system<mm2_service>();
                auto               coin          = mm2_system.get_coin_info(ticker);
                const auto&        price_service = this->m_system_manager.get_system<global_price_service>();
                const auto&        paprika       = this->m_system_manager.get_system<coinpaprika_provider>();
                std::error_code    ec;
                const std::string& currency                     = m_config->current_currency;
                const std::string& fiat                         = m_config->current_fiat;
                const QModelIndex& idx                          = res.at(0);
                const QString      balance                      = QString::fromStdString(mm2_system.my_balance(ticker, ec));
                auto&& [prev_balance, new_balance, is_change_b] = update_value(BalanceRole, balance, idx, *this);
                const QString main_currency_balance_value       = QString::fromStdString(price_service.get_price_in_fiat(currency, ticker, ec));
                auto&& [_1, _2, is_change_mc]                   = update_value(MainCurrencyBalanceRole, main_currency_balance_value, idx, *this);
                const QString currency_price_for_one_unit       = QString::fromStdString(price_service.get_rate_conversion(currency, ticker, ec, true));
                auto&& [_3, _4, is_change_mcpfo]                = update_value(MainCurrencyPriceForOneUnit, currency_price_for_one_unit, idx, *this);
                const QString currency_fiat_for_one_unit        = QString::fromStdString(price_service.get_rate_conversion(fiat, ticker, ec, false));
                update_value(MainFiatPriceForOneUnit, currency_fiat_for_one_unit, idx, *this);
                const QString display = QString::fromStdString(ticker) + " (" + balance + ")";
                update_value(Display, display, idx, *this);
                QString change24_h = retrieve_change_24h(paprika, coin, *m_config);
                update_value(Change24H, change24_h, idx, *this);
                if (is_change_b)
                {
                    t_float_50 prev_balance_f(prev_balance.toString().toStdString());
                    t_float_50 new_balance_f(new_balance.toString().toStdString());
                    bool       am_i_sender = false;
                    if (prev_balance_f > new_balance_f)
                    {
                        am_i_sender = true;
                    }
                    t_float_50 amount_f = am_i_sender ? prev_balance_f - new_balance_f : new_balance_f - prev_balance_f;
                    QString    amount   = QString::fromStdString(amount_f.str(8, std::ios_base::fixed));
                    using namespace std::chrono;
                    qint64  timestamp  = duration_cast<seconds>(system_clock::now().time_since_epoch()).count();
                    QString human_date = QString::fromStdString(to_human_date<std::chrono::seconds>(timestamp, "%e %b %Y, %H:%M"));
                    spdlog::debug(
                        "balance update notification from update_balance_values prev[{}], new[{}]", prev_balance.toString().toStdString(),
                        new_balance.toString().toStdString());
                    this->m_dispatcher.trigger<balance_update_notification>(am_i_sender, amount, QString::fromStdString(ticker), human_date, timestamp);
                    emit portfolioItemDataChanged();
                }
                if (ticker == mm2_system.get_current_ticker() && (is_change_b || is_change_mc || is_change_mcpfo))
                {
                    m_system_manager.get_system<wallet_page>().refresh_ticker_infos();
                }
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
        case MainFiatPriceForOneUnit:
            return item.main_fiat_price_for_one_unit;
        case NameRole:
            return item.name;
        case Trend7D:
            return item.trend_7d;
        case Excluded:
            return item.is_excluded;
        case Display:
            return item.display;
        case NameAndTicker:
            return item.ticker_and_name;
        case IsMultiTickerCurrentlyEnabled:
            return item.is_multi_ticker_enabled;
        case MultiTickerData:
            return item.multi_ticker_data.has_value() ? item.multi_ticker_data.value() : QJsonObject{};
        case CoinType:
            return item.coin_type;
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
        case CoinType:
            item.coin_type = value.toString();
            break;
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
        case MainFiatPriceForOneUnit:
            item.main_fiat_price_for_one_unit = value.toString();
            break;
        case Trend7D:
            item.trend_7d = value.toJsonArray();
            break;
        case Excluded:
            item.is_excluded = value.toBool();
            break;
        case Display:
            item.display = value.toString();
            break;
        case NameAndTicker:
            item.ticker_and_name = value.toString();
            break;
        case IsMultiTickerCurrentlyEnabled:
            if (item.is_multi_ticker_enabled != value.toBool())
            {
                item.is_multi_ticker_enabled = value.toBool();
                if (item.is_multi_ticker_enabled == true)
                {
                    this->m_dispatcher.trigger<multi_ticker_enabled>(item.ticker);
                }
            }
            break;
        case MultiTickerData:
            item.multi_ticker_data = QJsonObject::fromVariantMap(value.value<QVariantMap>());
            // qDebug() << value;
            /*if (value.isValid())
            {
                item.multi_ticker_data = nlohmann_json_object_to_qt_json_object(nlohmann::json::parse(value.toString().toStdString()));
            }*/
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
            this->m_ticker_registry.erase(this->m_model_data.at(position).ticker.toStdString());
            this->m_model_data.removeAt(position);
            emit lengthChanged();
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
            //assert(not res.empty());
            if (not res.empty())
            {
                this->removeRow(res.at(0).row());
            }
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
        return {
            {TickerRole, "ticker"},
            {CoinType, "type"},
            {NameRole, "name"},
            {BalanceRole, "balance"},
            {MainCurrencyBalanceRole, "main_currency_balance"},
            {Change24H, "change_24h"},
            {MainCurrencyPriceForOneUnit, "main_currency_price_for_one_unit"},
            {MainFiatPriceForOneUnit, "main_fiat_price_for_one_unit"},
            {Trend7D, "trend_7d"},
            {Excluded, "excluded"},
            {Display, "display"},
            {NameAndTicker, "name_and_ticker"},
            {IsMultiTickerCurrentlyEnabled, "is_multi_ticker_currently_enabled"},
            {MultiTickerData, "multi_ticker_data"}};
    }

    portfolio_proxy_model*
    atomic_dex::portfolio_model::get_portfolio_proxy_mdl() const noexcept
    {
        return m_model_proxy;
    }

    int
    portfolio_model::get_length() const noexcept
    {
        return this->rowCount(QModelIndex());
    }

    void
    portfolio_model::set_cfg(cfg& cfg) noexcept
    {
        m_config = &cfg;
    }

    void
    portfolio_model::reset()
    {
        this->m_ticker_registry.clear();
        this->beginResetModel();
        this->m_model_data.clear();
        this->endResetModel();
    }
} // namespace atomic_dex
