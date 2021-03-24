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

#pragma once

//! QT
#include <QObject>

//! Project headers
#include "atomicdex/models/qt.global.coins.cfg.model.hpp"
#include "atomicdex/models/qt.portfolio.model.hpp"


namespace atomic_dex
{
    class portfolio_page final : public QObject, public ag::ecs::pre_update_system<portfolio_page>
    {
        //! Q_Object definition
        Q_OBJECT

        //! Properties
        Q_PROPERTY(portfolio_model* portfolio_mdl READ get_portfolio NOTIFY portfolioChanged)
        Q_PROPERTY(QString oracle_last_price_reference READ get_oracle_last_price_reference NOTIFY oraclePriceUpdated)
        Q_PROPERTY(QStringList oracle_price_supported_pairs READ get_oracle_price_supported_pairs NOTIFY oraclePriceUpdated)
        Q_PROPERTY(QString balance_fiat_all READ get_balance_fiat_all WRITE set_current_balance_fiat_all NOTIFY onFiatBalanceAllChanged)
        Q_PROPERTY(global_coins_cfg_model* global_cfg_mdl READ get_global_cfg NOTIFY globalCfgMdlChanged)

        //! Private members fields
        ag::ecs::system_manager& m_system_manager;
        portfolio_model*         m_portfolio_mdl;
        global_coins_cfg_model*  m_global_cfg_mdl;
        QString                  m_current_balance_all{"0"};

      public:
        //! Constructor
        explicit portfolio_page(entt::registry& registry, ag::ecs::system_manager& system_manager, QObject* parent = nullptr);
        ~portfolio_page()  final;

        //! Public override
        void update()  final;

        //! CPP API
        void initialize_portfolio(const std::vector<std::string>& tickers);
        void disable_coins(const QStringList& coins);

        [[nodiscard]] portfolio_model*        get_portfolio() const ;
        [[nodiscard]] global_coins_cfg_model* get_global_cfg() const ;
        [[nodiscard]] QString                 get_oracle_last_price_reference() const ;
        [[nodiscard]] QStringList             get_oracle_price_supported_pairs() const ;
        [[nodiscard]] Q_INVOKABLE QStringList get_all_enabled_coins() const ;
        [[nodiscard]] Q_INVOKABLE QStringList get_all_coins_by_type(const QString& coin_type) const ;
        [[nodiscard]] Q_INVOKABLE bool        is_coin_enabled(const QString& coin_name) const ;

        [[nodiscard]] QString get_balance_fiat_all() const ;
        void                  set_current_balance_fiat_all(QString current_fiat_all_balance) ;

        //! Events
        void on_band_oracle_refreshed([[maybe_unused]] const band_oracle_refreshed& evt);
        void on_update_portfolio_values_event(const update_portfolio_values&) ;
        void on_coin_cfg_parsed(const coin_cfg_parsed& evt) ;

      signals:
        void portfolioChanged();
        void oraclePriceUpdated();
        void onFiatBalanceAllChanged();
        void globalCfgMdlChanged();
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::portfolio_page))
