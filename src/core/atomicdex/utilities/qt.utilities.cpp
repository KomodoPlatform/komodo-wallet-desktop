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
#include <QFile>

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
        const atomic_dex::komodo_prices_provider& provider, const atomic_dex::coin_config& coin, const atomic_dex::cfg& config,
        [[maybe_unused]] const ag::ecs::system_manager& system_manager)
    {
        QString change_24h = "0";
        if (is_this_currency_a_fiat(config, config.current_currency))
        {
            change_24h = QString::fromStdString(provider.get_change_24h(utils::retrieve_main_ticker(coin.ticker)));
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

    QString
    std_path_to_qstring(const std::filesystem::path& path)
    {
        QString out;
#if defined(_WIN32) || defined(WIN32)
        return QString::fromStdWString(path.wstring());
#else
        return QString::fromStdString(path.string());
#endif
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

    QStringList
    qt_utilities::get_themes_list() const 
    {
        QStringList    out;
        const std::filesystem::path theme_path = atomic_dex::utils::get_themes_path();
        for (auto&& cur: std::filesystem::directory_iterator(theme_path)) 
        {
            if (!std::filesystem::exists(cur.path() / "colors.json")) continue;

            out << std_path_to_qstring(cur.path().filename()); 
        }
        return out;
    }

    bool
    qt_utilities::save_theme(const QString& filename, const QVariantMap& theme_object, bool overwrite)
    {
        bool     result    = true;
        std::filesystem::path file_path = atomic_dex::utils::get_themes_path() / filename.toStdString() / "colors.json";
        if (!overwrite && std::filesystem::exists(file_path))
        {
            result = false;
        }
        else
        {
            LOG_PATH("saving new theme: {}", file_path);
            QFile file;
            file.setFileName(std_path_to_qstring(file_path));
            file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate);
            file.write(QJsonDocument(QJsonObject::fromVariantMap(theme_object)).toJson(QJsonDocument::Indented));
            file.close();
        }
        return result;
    }

    QVariantMap
    atomic_dex::qt_utilities::load_theme(const QString& theme_name) const 
    {
        QVariantMap out;
        using namespace std::string_literals;
        
        // Loads color scheme.
        std::filesystem::path file_path = atomic_dex::utils::get_themes_path() / theme_name.toStdString() / "colors.json";
        if (std::filesystem::exists(file_path))
        {
            LOG_PATH("load theme: {}", file_path);
            QFile file;
            file.setFileName(std_path_to_qstring(file_path));
            file.open(QIODevice::ReadOnly | QIODevice::Text);
            QString val = file.readAll();
            file.close();
            out = QJsonDocument::fromJson(val.toUtf8()).object().toVariantMap();
        }
        return out;
    }

    QString
    qt_utilities::retrieve_main_ticker(const QString& ticker) const
    {
        return QString::fromStdString(atomic_dex::utils::retrieve_main_ticker(ticker.toStdString()));
    }
} // namespace atomic_dex
