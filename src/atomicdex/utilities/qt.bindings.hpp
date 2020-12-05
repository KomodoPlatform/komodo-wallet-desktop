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
#include <QVariantList>
#include <QJsonDocument>

//! Project Headers
#include "atomicdex/services/mm2/mm2.service.hpp"

namespace atomic_dex
{
    inline nlohmann::json
    to_qt_binding(t_coins::value_type&& coin)
    {
        nlohmann::json j{
            {"active", coin.active},
            {"is_claimable", coin.is_claimable},
            {"minimal_balance_for_asking_rewards", coin.minimal_claim_amount},
            {"ticker", coin.ticker},
            {"name", coin.name},
            {"type", coin.type},
            {"explorer_url", coin.explorer_url},
            {"tx_uri", coin.tx_uri},
            {"address_uri", coin.address_url},
            {"is_custom_coin", coin.is_custom_coin}};
        return j;
    }

    QVariantList inline to_qt_binding(t_coins&& coins)
    {
        QVariantList out;
        out.reserve(coins.size());
        nlohmann::json j = nlohmann::json::array();
        for (auto&& coin: coins) { j.push_back(to_qt_binding(std::move(coin))); }
        QJsonDocument q_json = QJsonDocument::fromJson(QString::fromStdString(j.dump()).toUtf8());
        out                  = q_json.array().toVariantList();
        return out;
    }
} // namespace atomic_dex
