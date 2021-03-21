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

//! PCH
#include "atomicdex/pch.hpp"

//! Project Headers
#include "atomicdex/pages/qt.portfolio.page.hpp"
#include "atomicdex/pages/qt.settings.page.hpp"
#include "atomicdex/pages/qt.wallet.page.hpp"
#include "atomicdex/services/price/global.provider.hpp"
#include "atomicdex/services/price/oracle/band.provider.hpp"

namespace atomic_dex
{
    portfolio_page::portfolio_page(entt::registry& registry, ag::ecs::system_manager& system_manager, QObject* parent) :
        QObject(parent), system(registry), m_system_manager(system_manager), m_portfolio_mdl(new portfolio_model(system_manager, dispatcher_, this)),
        m_global_cfg_mdl(new global_coins_cfg_model(this))
    {
        emit portfolioChanged();
        this->dispatcher_.sink<update_portfolio_values>().connect<&portfolio_page::on_update_portfolio_values_event>(*this);
        this->dispatcher_.sink<band_oracle_refreshed>().connect<&portfolio_page::on_band_oracle_refreshed>(*this);
        this->dispatcher_.sink<coin_cfg_parsed>().connect<&portfolio_page::on_coin_cfg_parsed>(*this);
    }

    portfolio_model*
    portfolio_page::get_portfolio() const noexcept
    {
        return m_portfolio_mdl;
    }

    void
    portfolio_page::update() noexcept
    {
    }

    portfolio_page::~portfolio_page() noexcept {}

    QStringList
    portfolio_page::get_oracle_price_supported_pairs() const noexcept
    {
        auto        result = m_system_manager.get_system<band_oracle_price_service>().supported_pair();
        QStringList out;
        out.reserve(result.size());
        for (auto&& cur: result) { out.push_back(QString::fromStdString(cur)); }
        return out;
    }

    QString
    portfolio_page::get_oracle_last_price_reference() const noexcept
    {
        return QString::fromStdString(m_system_manager.get_system<band_oracle_price_service>().last_oracle_reference());
    }

    void
    portfolio_page::on_band_oracle_refreshed(const band_oracle_refreshed&)
    {
        emit oraclePriceUpdated();
    }

    void
    portfolio_page::set_current_balance_fiat_all(QString current_fiat_all_balance) noexcept
    {
        if (this->m_current_balance_all != current_fiat_all_balance)
        {
            this->m_current_balance_all = std::move(current_fiat_all_balance);
            emit onFiatBalanceAllChanged();
        }
    }

    QString
    portfolio_page::get_balance_fiat_all() const noexcept
    {
        return m_current_balance_all;
    }

    void
    portfolio_page::on_update_portfolio_values_event(const update_portfolio_values& evt) noexcept
    {
        //SPDLOG_INFO("Updating portfolio values with model: {}", evt.with_update_model);

        if (evt.with_update_model)
        {
            m_portfolio_mdl->update_currency_values();
            m_system_manager.get_system<wallet_page>().refresh_ticker_infos();
        }

        std::error_code ec;
        const auto&     config           = m_system_manager.get_system<settings_page>().get_cfg();
        const auto&     price_service    = m_system_manager.get_system<global_price_service>();
        auto            fiat_balance_std = price_service.get_price_in_fiat_all(config.current_currency, ec);
        if (!ec)
        {
            set_current_balance_fiat_all(QString::fromStdString(fiat_balance_std));
        }
    }

    QStringList
    atomic_dex::portfolio_page::get_all_enabled_coins() const noexcept
    {
        return get_all_coins_by_type("All");
    }

    QStringList
    atomic_dex::portfolio_page::get_all_coins_by_type(const QString& coin_type) const noexcept
    {
        QStringList enabled_coins;
        const auto& portfolio_list = this->get_portfolio()->get_underlying_data();
        enabled_coins.reserve(portfolio_list.count());
        for (auto&& cur_coin: portfolio_list)
        {
            if (coin_type == "All")
            {
                enabled_coins.push_back(cur_coin.ticker);
            }
            else if (cur_coin.coin_type == coin_type)
            {
                enabled_coins.push_back(cur_coin.ticker);
            }
        }
        return enabled_coins;
    }

    bool
    atomic_dex::portfolio_page::is_coin_enabled(const QString& coin_name) const noexcept
    {
        return get_all_enabled_coins().contains(coin_name);
    }

    global_coins_cfg_model*
    portfolio_page::get_global_cfg() const noexcept
    {
        return m_global_cfg_mdl;
    }

    void
    portfolio_page::on_coin_cfg_parsed(const coin_cfg_parsed& evt) noexcept
    {
        this->m_global_cfg_mdl->initialize_model(evt.cfg);
    }

    void
    portfolio_page::initialize_portfolio(const std::vector<std::string>& tickers)
    {
        m_portfolio_mdl->initialize_portfolio(tickers);
        m_global_cfg_mdl->update_status(tickers, true);
    }

    void
    portfolio_page::disable_coins(const QStringList& coins)
    {
        m_portfolio_mdl->disable_coins(coins);
        m_global_cfg_mdl->update_status(coins, false);
    }
} // namespace atomic_dex
