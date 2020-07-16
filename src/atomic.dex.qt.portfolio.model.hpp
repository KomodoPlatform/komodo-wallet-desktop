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
#include <QSortFilterProxyModel>
#include <QString>
#include <QVector>

//! PCH Header
#include "atomic.dex.pch.hpp"

//! Project headers
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"

namespace atomic_dex
{
    struct portfolio_data
    {
        //! eg: BTC,ETH,KMD (constant)
        const QString ticker;

        //! eg: Bitcoin
        const QString name;

        //! eg: 1
        QString balance;

        //! eg: 18800 $
        QString main_currency_balance;

        //! eg: +2.4%
        QString change_24h;

        //! eg: 9400 $
        QString main_currency_price_for_one_unit;
    };

    class portfolio_proxy_model : public QSortFilterProxyModel
    {
        Q_OBJECT
      public:
        portfolio_proxy_model(QObject* parent);
        ~portfolio_proxy_model();

      protected:
        bool lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const override;

      private:
    };

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
            MainCurrencyPriceForOneUnit
        };

      private:
        //! Typedef
        using t_portfolio_datas = QVector<portfolio_data>;

      public:
        //! Constructor / Destructor
        explicit portfolio_model(ag::ecs::system_manager& system_manager, atomic_dex::cfg& config, QObject* parent = nullptr) noexcept;
        ~portfolio_model() noexcept final;

        //! Overrides
        QVariant               data(const QModelIndex& index, int role) const final;
        bool                   setData(const QModelIndex& index, const QVariant& value, int role) final; //< Will be used internally
        int                    rowCount(const QModelIndex& parent) const final;
        QHash<int, QByteArray> roleNames() const final;
        bool                   removeRows(int row, int count, const QModelIndex& parent) final;

        //! Public api
        void initialize_portfolio(std::string ticker);
        void update_currency_values();
        void disable_coins(const QStringList& coins);

        //! Properties
        portfolio_proxy_model* get_portfolio_proxy_mdl() const noexcept;

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