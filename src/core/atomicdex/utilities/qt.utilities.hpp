/******************************************************************************
 * Copyright © 2013-2022 The Komodo Platform Developers.                      *
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

#include <QJsonObject>
#include <QModelIndex>
#include <QString>
#include <QStringList>
#include <QVariant>
#include <QVariantList>
#include <QCryptographicHash> //> QCryptographicHash::hash, QCryptographicHash::Keccak_256
#include <filesystem>

#include "atomicdex/config/app.cfg.hpp"
#include "atomicdex/config/coins.cfg.hpp"
#include "atomicdex/config/wallet.cfg.hpp"
#include "atomicdex/services/price/komodo_prices/komodo.prices.provider.hpp"

namespace atomic_dex
{
    template <typename QtModel>
    inline auto update_value(int role, const QVariant& value, const QModelIndex& idx, QtModel& model)
    {
        if (auto prev_value = model.data(idx, role); value != prev_value)
        {
            model.setData(idx, value, role);
            return std::make_tuple(prev_value, value, true);
        }
        return std::make_tuple(value, value, false);
    }

    QString              std_path_to_qstring(const std::filesystem::path& path);
    QStringList          vector_std_string_to_qt_string_list(const std::vector<std::string>& vec);
    ENTT_API QStringList qt_variant_list_to_qt_string_list(const QVariantList& variant_list);
    QJsonArray           nlohmann_json_array_to_qt_json_array(const nlohmann::json& j);
    QJsonObject          nlohmann_json_object_to_qt_json_object(const nlohmann::json& j);
    QString              retrieve_change_24h(
                     const atomic_dex::komodo_prices_provider& provider, const atomic_dex::coin_config& coin, const atomic_dex::cfg& config,
                     const ag::ecs::system_manager& system_manager);
    
    [[nodiscard]] QString inline sha256_qstring_from_qt_byte_array(const QByteArray& byte_array)
    {
        return QLatin1String(QCryptographicHash::hash(byte_array, QCryptographicHash::Sha256).toHex());
    }

    class ENTT_API qt_utilities : public QObject
    {
        Q_OBJECT

      public:
        Q_INVOKABLE static void copy_text_to_clipboard(const QString& text);

        Q_INVOKABLE static QString get_qrcode_svg_from_string(const QString& str);

        //! Themes
        Q_INVOKABLE [[nodiscard]] QStringList get_themes_list() const ;

        /**
         *
         * @param filename -> my_theme.json
         * @param theme_object -> json object of my_theme.json
         * @param overwrite -> if true replace current theme
         * @return ->  if it's was overwritten or not
         * @example -> save_theme(my_theme.json, "{}", false)
         */
        Q_INVOKABLE bool save_theme(const QString& filename, const QVariantMap& theme_object, bool overwrite = false);

        /**
         * @param theme_name
         * @return theme as a json object
         * @example -> load_theme(dark);
         */
        Q_INVOKABLE QVariantMap load_theme(const QString& theme_name) const;

        /**
         *
         * @param ticker
         * @return a ticker
         * @example -> retrieve_main_ticker("BUSD") -> BUSD retrieve_main_ticker("BUSD-ERC20") -> BUSD
         */
        Q_INVOKABLE QString retrieve_main_ticker(const QString& ticker) const;
    };
} // namespace atomic_dex
