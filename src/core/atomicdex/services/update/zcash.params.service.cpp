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
#include "atomicdex/utilities/global.utilities.hpp"
#include "atomicdex/utilities/qt.download.manager.hpp"
#include "atomicdex/version/version.hpp"

namespace atomic_dex
{
    zcash_params_service::zcash_params_service(
        entt::registry& registry, ag::ecs::system_manager& system_manager,
        entt::dispatcher& dispatcher, QObject* parent) :
        QObject(parent), system(registry),
        m_system_manager(system_manager), m_dispatcher(dispatcher)
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

    fs::path zcash_params_service::get_zcash_params_folder()
    {
        fs::path zcash_params_path;
#if defined(_WIN32) || defined(WIN32)
        std::wstring out = _wgetenv(L"APPDATA");
        zcash_params_path = fs::path(out) / "ZcashParams";
#elif defined(__APPLE__)
        zcash_params_path = fs::path(std::getenv("HOME")) / "Library" / "Application Support" / "ZcashParams";
#else
        zcash_params_path = fs::path(std::getenv("HOME")) / (std::string(".zcash-params"));
#endif
        return zcash_params_path;
    }

    void zcash_params_service::download_zcash_params() 
    {
        SPDLOG_INFO("Starting zcash params download");
        using namespace std::chrono_literals;
        const fs::path folder = this->get_zcash_params_folder();
        if (not fs::exists(folder))
        {
            fs::create_directories(folder);
        }
        std::string zcash_params[5] = {
            "https://z.cash/downloads/sprout-proving.key.deprecated-sworn-elves",
            "https://z.cash/downloads/sprout-verifying.key",
            "https://z.cash/downloads/sapling-spend.params",
            "https://z.cash/downloads/sapling-output.params",
            "https://z.cash/downloads/sprout-groth16.params"
        };

        for(const std::string &url: zcash_params)
        {
            std::string filename = atomic_dex::utils::u8string(fs::path(url).filename());
            if (filename.find("deprecated-sworn-elves") > -1)
            {
                filename = "sprout-proving.key";
            }
            SPDLOG_INFO("Downloading {}...", filename);
            qt_downloader* downloader = new qt_downloader(m_dispatcher);
            downloader->do_download(QUrl(QString::fromStdString(url)), filename, folder);
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
