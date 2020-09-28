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

#include <QJsonArray>
#include <QJsonObject>
#include <QString>

namespace atomic_dex
{
    struct portfolio_data
    {
        //! eg: BTC,ETH,KMD (constant)
        QString ticker;

        //! eg: Bitcoin
        QString name;

        //! eg: 1
        QString balance;

        //! eg: 18800 $
        QString main_currency_balance;

        //! eg: +2.4%
        QString change_24h;

        //! eg: 9400 $
        QString main_currency_price_for_one_unit;

        //! Paprika data rates
        QJsonArray trend_7d;

        bool is_excluded{false};

        QString display;

        QString ticker_and_name;

        bool is_multi_ticker_enabled{false};

        std::optional<QJsonObject> multi_ticker_data{std::nullopt};
    };
} // namespace atomic_dex