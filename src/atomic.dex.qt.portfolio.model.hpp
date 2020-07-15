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

namespace atomic_dex
{
    struct portfolio_data
    {
        //! eg: BTC,ETH,KMD (constant)
        const QString ticker;

        //! eg: 1
        QString balance;

        //! eg: 18800 $
        QString main_currency_balance;

        //! eg: +2.4%
        QString change_24h;

        //! eg: 9400 $
        QString main_currency_price_for_one_unit;
    };

    class portfolio_model final : public QAbstractListModel
    {
        Q_OBJECT
        Q_ENUMS(PortfolioRoles)
      public:
        enum PortfolioRoles
        {
            TickerRole = Qt::UserRole + 1,
            BalanceRole,
            MainCurrencyBalanceRole,
            Change24H,
            MainCurrencyPriceForOneUnit
        };

      private:
        //! Typedef
        using t_ticker_currently_present = std::unordered_set<std::string>;
        using t_portfolio_datas = QVector<portfolio_data>;

      public:
        //! Constructor / Destructor
        explicit portfolio_model(ag::ecs::system_manager& system_manager, QObject* parent = nullptr) noexcept;
        ~portfolio_model() noexcept final;

        //! Overrides
        QVariant               data(const QModelIndex& index, int role) const final;
        bool                   setData(const QModelIndex& index, const QVariant& value, int role) final; //< Will be used internally
        int                    rowCount(const QModelIndex& parent) const final;
        QHash<int, QByteArray> roleNames() const final;

      private:
        //! From project
        ag::ecs::system_manager& m_system_manager;

        //! Data holders
        t_portfolio_datas m_model_data;
        t_ticker_currently_present m_ticker_registry;
    };
} // namespace atomic_dex