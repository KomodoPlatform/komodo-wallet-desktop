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

#pragma once

//! QT
#include <QObject>

//! Project headers
#include "atomic.dex.qt.portfolio.model.hpp"


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

        //! Private members fields
        ag::ecs::system_manager& m_system_manager;
        portfolio_model*         m_portfolio_mdl;
        QString                  m_current_balance_all{"0"};

      public:
        //! Constructor
        explicit portfolio_page(entt::registry& registry, ag::ecs::system_manager& system_manager, QObject* parent = nullptr);
        ~portfolio_page() noexcept final;

        //! Public override
        void update() noexcept final;

        [[nodiscard]] portfolio_model* get_portfolio() const noexcept;
        [[nodiscard]] QString          get_oracle_last_price_reference() const noexcept;
        [[nodiscard]] QStringList      get_oracle_price_supported_pairs() const noexcept;

        [[nodiscard]] QString get_balance_fiat_all() const noexcept;
        void                  set_current_balance_fiat_all(QString current_fiat_all_balance) noexcept;

        //! Events
        void on_band_oracle_refreshed([[maybe_unused]] const band_oracle_refreshed& evt);
        void on_update_portfolio_values_event(const update_portfolio_values&) noexcept;;

      signals:
        void portfolioChanged();
        void oraclePriceUpdated();
        void onFiatBalanceAllChanged();
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::portfolio_page))