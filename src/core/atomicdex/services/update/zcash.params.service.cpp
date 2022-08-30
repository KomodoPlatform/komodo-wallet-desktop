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

#include "atomicdex/services/update/zcash.params.service.hpp"

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
            connect(downloader, &qt_downloader::downloadStatusChanged, this, &zcash_params_service::set_combined_download_status);
        }
    }

    QString
    zcash_params_service::get_combined_download_progress()
    {
        return QString(QJsonDocument(m_combined_download_status).toJson());
    }

    QJsonObject
    zcash_params_service::get_combined_download_status() const
    {
        return m_combined_download_status;
    }

    void
    zcash_params_service::set_combined_download_status(QJsonObject& status)
    {
        QString filename  = status.value("filename").toString();
        m_combined_download_status.insert(filename, status.value("progress"));
        // SPDLOG_INFO("Filename: {} {}%", filename.toUtf8().constData(), std::to_string(status.value("progress").toDouble()));
        emit combinedDownloadStatusChanged();
    }

} // namespace atomic_dex
