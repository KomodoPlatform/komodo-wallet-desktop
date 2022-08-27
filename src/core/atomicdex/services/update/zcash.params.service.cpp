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

#include "atomicdex/pch.hpp"

#include <QJsonDocument>
#include <QTranslator>

#include <boost/algorithm/string/replace.hpp>
#include <nlohmann/json.hpp>

#include "atomicdex/events/events.hpp"
#include "atomicdex/services/update/zcash.params.service.hpp"
#include "atomicdex/utilities/cpprestsdk.utilities.hpp"
#include "atomicdex/version/version.hpp"

namespace atomic_dex
{
    zcash_params_service::zcash_params_service(entt::registry& registry, QObject* parent) : QObject(parent), system(registry)
    {
        m_update_clock  = std::chrono::high_resolution_clock::now();
        m_update_info = nlohmann::json::object();
    }

    void zcash_params_service::update() 
    {
        using namespace std::chrono_literals;

        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - m_update_clock);
        if (s >= 1h)
        {
        }
    }

    void zcash_params_service::fetch_update_info() 
    {
    }

    QVariant zcash_params_service::get_update_info() const 
    {
        nlohmann::json info = *m_update_info;
        QJsonDocument  doc  = QJsonDocument::fromJson(QString::fromStdString(info.dump()).toUtf8());
        return doc.toVariant();
    }
} // namespace atomic_dex
