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


#include <QDebug>
#include <QFile>

//! Project
#include "atomicdex/events/events.hpp"
#include "atomicdex/utilities/global.utilities.hpp"
#include "atomicdex/utilities/qt.download.manager.hpp"

namespace atomic_dex
{
    qt_download_manager::qt_download_manager(
        entt::registry& registry, ag::ecs::system_manager& system_manager,
        entt::dispatcher& dispatcher, QObject* parent) :
        QObject(parent), system(registry),
        m_system_manager(system_manager), m_dispatcher(dispatcher)
    {
        dispatcher.sink<download_started>().connect<&qt_download_manager::on_download_started>(*this);
        SPDLOG_INFO("qt_download_manager created");
        connect(&m_manager, &QNetworkAccessManager::finished, this, &qt_download_manager::download_finished);
    }

    void
    qt_download_manager::do_download(const std::string url, const fs::path folder, std::string filename)
    {
        m_download_filename     = filename;
        m_download_path         = folder / m_download_filename;
        SPDLOG_INFO("[do_download] Downloading: {}", url);
        QNetworkRequest request(QUrl(QString::fromStdString(url)));
        request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::RedirectPolicy::NoLessSafeRedirectPolicy);
        QNetworkReply* reply = m_manager.get(request);
        connect(reply, &QNetworkReply::downloadProgress, this, &qt_download_manager::download_progress);
        m_current_downloads.append(reply);
    }

    void
    qt_download_manager::download_progress(qint64 bytes_received, qint64 bytes_total)
    {
        m_download_progress = float(bytes_received) / float(bytes_total);
        m_dispatcher.trigger(qt_download_progressed{m_download_progress});
        SPDLOG_INFO("bytes_received : {}, bytes_total: {}, percent {}%", bytes_received, bytes_total, m_download_progress * 100);
    }

    void
    qt_download_manager::download_finished(QNetworkReply* reply)
    {
        auto save_disk_functor = [this](QIODevice* data) {
            QFile file(utils::u8string(m_download_path).c_str());
            if (!file.open(QIODevice::WriteOnly))
            {
                SPDLOG_ERROR("Could not open {} for writing: {}", utils::u8string(m_download_path), file.errorString().toStdString());
                return false;
            }

            file.write(data->readAll());
            file.close();

            return true;
        };
        QUrl url = reply->url();
        if (reply->error())
        {
            SPDLOG_ERROR("Download of {} failed: {}\n", QString(url.toEncoded().constData()).toStdString(), reply->errorString().toStdString());
        }
        else
        {
            SPDLOG_INFO("Successfully downloaded: {}", m_download_filename);
            if (save_disk_functor(reply))
            {
                SPDLOG_INFO("Successfully saved {} to {}", url.toString().toStdString(), utils::u8string(m_download_path));
                m_dispatcher.trigger<download_release_finished>();
            }
        }

        m_current_downloads.removeAll(reply);
        reply->deleteLater();
    }

    fs::path
    qt_download_manager::get_last_download_path()
    {
        return m_download_path;
    }

    void
    qt_download_manager::on_download_started([[maybe_unused]] const download_started& evt)
    {
        SPDLOG_INFO("Default coins are enabled, we can now check internet with mm2 too");
        //g_mm2_default_coins_ready = true;
    }

    void
    qt_download_manager::update()
    {
        using namespace std::chrono_literals;

        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - m_update_clock);
        //set_seconds_left_to_auto_retry(60.0 - s.count());
        if (s >= 60s)
        {
            //this->fetch_internet_connection();
            //m_update_clock = std::chrono::high_resolution_clock::now();
            //set_seconds_left_to_auto_retry(60.0);
        }
    }
} // namespace atomic_dex