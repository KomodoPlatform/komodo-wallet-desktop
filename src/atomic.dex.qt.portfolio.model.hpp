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

//! QT Headers
#include <QAbstractListModel>
#include <QString>
#include <QVector>

//! PCH Header
#include "atomic.dex.pch.hpp"

//! Project headers
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"
#include "atomic.dex.qt.portfolio.data.hpp"
#include "atomic.dex.qt.portfolio.proxy.filter.model.hpp"

namespace atomic_dex
{
    class portfolio_model final : public QAbstractListModel
    {
        Q_OBJECT
        Q_PROPERTY(portfolio_proxy_model* portfolio_proxy_mdl READ get_portfolio_proxy_mdl NOTIFY portfolioProxyChanged);
        Q_ENUMS(PortfolioRoles)
      public:
        enum PortfolioRoles
        {
            TickerRole = Qt::UserRole + 1,
            NameRole,
            BalanceRole,
            MainCurrencyBalanceRole,
            Change24H,
            MainCurrencyPriceForOneUnit,
            Trend7D
        };

      private:
        //! Typedef
        using t_portfolio_datas = QVector<portfolio_data>;

      public:
        //! Constructor / Destructor
        explicit portfolio_model(ag::ecs::system_manager& system_manager, atomic_dex::cfg& config, QObject* parent = nullptr) noexcept;
        ~portfolio_model() noexcept final;

        //! Overrides
        [[nodiscard]] QVariant               data(const QModelIndex& index, int role) const final;
        bool                                 setData(const QModelIndex& index, const QVariant& value, int role) final; //< Will be used internally
        [[nodiscard]] int                    rowCount(const QModelIndex& parent) const final;
        [[nodiscard]] QHash<int, QByteArray> roleNames() const final;
        bool                                 removeRows(int row, int count, const QModelIndex& parent) final;

        //! Public api
        void initialize_portfolio(std::string ticker);
        void update_currency_values();
        void update_balance_values(const std::string& ticker) noexcept;
        void disable_coins(const QStringList& coins);

        //! Properties
        [[nodiscard]] portfolio_proxy_model* get_portfolio_proxy_mdl() const noexcept;

      signals:
        void portfolioProxyChanged();

      private:
        //! From project
        ag::ecs::system_manager& m_system_manager;
        atomic_dex::cfg&         m_config;

        //! Properties
        portfolio_proxy_model* m_model_proxy;
        //! Data holders
        t_portfolio_datas m_model_data;
    };

} // namespace atomic_dex