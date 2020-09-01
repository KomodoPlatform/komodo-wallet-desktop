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

//! QT Headers
#include <QtNetwork>

//! PCH
#include "atomic.dex.pch.hpp"

//! Project headers
#include "atomic.dex.qt.utilities.hpp"

namespace atomic_dex
{
    bool
    am_i_able_to_reach_this_endpoint(const QString& endpoint)
    {
        return RestClient::get(endpoint.toStdString()).code == 200;
    }

    QJsonArray
    nlohmann_json_array_to_qt_json_array(const nlohmann::json& j)
    {
        QJsonArray    out;
        QJsonDocument q_json = QJsonDocument::fromJson(QString::fromStdString(j.dump()).toUtf8());
        out                  = q_json.array();
        return out;
    }

    QJsonObject
    nlohmann_json_object_to_qt_json_object(const json& j)
    {
        QJsonObject   obj;
        QJsonDocument q_json = QJsonDocument::fromJson(QString::fromStdString(j.dump()).toUtf8());
        obj                  = q_json.object();
        return obj;
    }

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

    QStringList
    vector_std_string_to_qt_string_list(const std::vector<std::string>& vec)
    {
        QStringList out;
        out.reserve(vec.size());
        for (auto&& cur: vec) { out.append(QString::fromStdString(cur)); }
        return out;
    }
} // namespace atomic_dex
