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

//! QT Headers
#include <QClipboard>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>

//! Deps
#include <QrCode.hpp>

//! Project headers
#include "atomicdex/utilities/qt.utilities.hpp"
#include "global.utilities.hpp"

namespace atomic_dex
{
    QJsonArray
    nlohmann_json_array_to_qt_json_array(const nlohmann::json& j)
    {
        QJsonArray    out;
        QJsonDocument q_json = QJsonDocument::fromJson(QString::fromStdString(j.dump()).toUtf8());
        out                  = q_json.array();
        return out;
    }

    QJsonObject
    nlohmann_json_object_to_qt_json_object(const nlohmann::json& j)
    {
        QJsonObject   obj;
        QJsonDocument q_json = QJsonDocument::fromJson(QString::fromStdString(j.dump()).toUtf8());
        obj                  = q_json.object();
        return obj;
    }

    QString
    retrieve_change_24h(
        const atomic_dex::coingecko_provider& coingecko, const atomic_dex::coin_config& coin, const atomic_dex::cfg& config,
        [[maybe_unused]] const ag::ecs::system_manager& system_manager)
    {
        QString change_24h = "0";
        if (is_this_currency_a_fiat(config, config.current_currency))
        {
            change_24h = QString::fromStdString(coingecko.get_change_24h(coin.ticker));
            if (config.current_currency != "USD")
            {
                // system_manager.get_system<>()
                t_float_50 change_24h_f(change_24h.toStdString());
            }
        }
        else
        {
            const auto res = coingecko.get_change_24h(config.current_currency);

            if (res != "0" && coin.ticker != config.current_currency)
            {
                t_float_50 change_24h_f(res);
                t_float_50 final_result = t_float_50(coingecko.get_change_24h(coin.ticker)) - change_24h_f;
                change_24h              = QString::fromStdString(final_result.str(2));
            }
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

    QStringList
    qt_variant_list_to_qt_string_list(const QVariantList& variant_list)
    {
        QStringList out;

        out.reserve(variant_list.size());
        for (auto&& cur: variant_list) { out.append(cur.value<QString>()); }
        return out;
    }

    void
    qt_utilities::copy_text_to_clipboard(const QString& text)
    {
        QClipboard* clipboard = QGuiApplication::clipboard();

        clipboard->setText(text);
    }

    QString
    qt_utilities::get_qrcode_svg_from_string(const QString& str)
    {
        qrcodegen::QrCode qr0 = qrcodegen::QrCode::encodeText(str.toStdString().c_str(), qrcodegen::QrCode::Ecc::MEDIUM);
        std::string       svg = qr0.toSvgString(2);

        return QString::fromStdString("data:image/svg+xml;base64,") + QString::fromStdString(svg).toLocal8Bit().toBase64();
    }
} // namespace atomic_dex
