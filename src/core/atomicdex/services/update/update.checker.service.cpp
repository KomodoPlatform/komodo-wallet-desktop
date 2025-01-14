/******************************************************************************
 * Copyright © 2013-2024 The Komodo Platform Developers.                      *
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
#include "atomicdex/services/update/update.checker.service.hpp"
#include "atomicdex/utilities/cpprestsdk.utilities.hpp"
#include "atomicdex/version/version.hpp"

namespace
{
    constexpr const char* g_komodolive_endpoint = "https://komodo.earth/adexproversion";
    t_http_client_ptr     g_komodolive_client{std::make_unique<t_http_client>(FROM_STD_STR(g_komodolive_endpoint))};

    pplx::task<web::http::http_response> async_check_retrieve() 
    {
        // Uncomment this when testing the next release.
        // nlohmann::json json_data{{"testing", true}};
        nlohmann::json json_data{{"testing", false}};
        return g_komodolive_client->request(create_json_post_request(std::move(json_data)));
    }

    nlohmann::json process_update_info_resp(web::http::http_response resp_http)
    {
        using namespace std::string_literals;
        nlohmann::json resp;
        nlohmann::json result;
        std::string    resp_str = TO_STD_STR(resp_http.extract_string(true).get());
        if (resp_http.status_code() != 200)
        {
            SPDLOG_ERROR("Cannot reach the endpoint [{}]: {}", g_komodolive_endpoint);
            result["status"] = (QObject::tr("Cannot reach the endpoint: ") + g_komodolive_endpoint).toStdString();
        }
        else
        {

            resp = nlohmann::json::parse(resp_str);
            // SPDLOG_ERROR("Update check response: {}", resp_str);
        }
        result["rpcCode"]        = resp_http.status_code();
        result["currentVersion"] = atomic_dex::get_raw_version();
        if (resp_http.status_code() == 200)
        {
            int   current_version  = atomic_dex::get_num_version();
            int   endpoint_version = stoi(resp.at("version_num").get<std::string>());
            result["updateNeeded"] = current_version < endpoint_version;
            result["newVersion"]   = resp["new_version"];
            result["downloadUrl"]  = resp["download_url"];
            result["changelog"]    = resp["changelog"];
            result["status"]       = resp["status"];
            result["version_num"]  = resp["version_num"];
        }
        SPDLOG_INFO(result.dump());
        return result;
    }
}

namespace atomic_dex
{
    update_checker_service::update_checker_service(entt::registry& registry, QObject* parent) : QObject(parent), system(registry)
    {
        m_update_clock  = std::chrono::high_resolution_clock::now();
        m_update_info = nlohmann::json::object();
        fetch_update_info();
    }

    void update_checker_service::update() 
    {
        using namespace std::chrono_literals;

        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - m_update_clock);
        if (s >= 1h)
        {
            fetch_update_info();
            m_update_clock = std::chrono::high_resolution_clock::now();
        }
    }

    void update_checker_service::fetch_update_info() 
    {
        if (is_fetching)
            return;
        is_fetching = true;
        emit isFetchingChanged();
        async_check_retrieve()
            .then([this](web::http::http_response resp) {
                this->m_update_info = process_update_info_resp(resp);
                SPDLOG_INFO("UpdateInfo has updated...");
                is_fetching = false;
                emit isFetchingChanged();
                emit updateInfoChanged();
            })
            .then(&handle_exception_pplx_task);
    }

    QVariant update_checker_service::get_update_info() const 
    {
        nlohmann::json info = *m_update_info;
        QJsonDocument  doc  = QJsonDocument::fromJson(QString::fromStdString(info.dump()).toUtf8());
        return doc.toVariant();
    }
} // namespace atomic_dex
