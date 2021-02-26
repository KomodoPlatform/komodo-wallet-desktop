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

#pragma once

//! QT Headers
#include <QJsonObject>
#include <QModelIndex>
#include <QString>
#include <QVariant>
#include <QVariantList>

//! Project Headers
#include "atomicdex/config/app.cfg.hpp"
#include "atomicdex/config/coins.cfg.hpp"
#include "atomicdex/config/wallet.cfg.hpp"
#include "atomicdex/services/price/coingecko/coingecko.provider.hpp"

namespace atomic_dex
{
    template <typename TModel>
    auto
    update_value(int role, const QVariant& value, const QModelIndex& idx, TModel& model)
    {
        if (auto prev_value = model.data(idx, role); value != prev_value)
        {
            model.setData(idx, value, role);
            return std::make_tuple(prev_value, value, true);
        }
        return std::make_tuple(value, value, false);
    }

    QStringList          vector_std_string_to_qt_string_list(const std::vector<std::string>& vec);
    ENTT_API QStringList qt_variant_list_to_qt_string_list(const QVariantList& variant_list);
    QJsonArray           nlohmann_json_array_to_qt_json_array(const nlohmann::json& j);
    QJsonObject          nlohmann_json_object_to_qt_json_object(const nlohmann::json& j);
    QString              retrieve_change_24h(
                     const atomic_dex::coingecko_provider& coingecko, const atomic_dex::coin_config& coin, const atomic_dex::cfg& config,
                     const ag::ecs::system_manager& system_manager);

    class ENTT_API qt_utilities : public QObject
    {
        Q_OBJECT

      public:
        Q_INVOKABLE static void copy_text_to_clipboard(const QString& text);

        Q_INVOKABLE static QString get_qrcode_svg_from_string(const QString& str);
    };
} // namespace atomic_dex
