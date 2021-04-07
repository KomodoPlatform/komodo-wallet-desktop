//
// Created by Sztergbaum Roman on 04/04/2021.
//

#include <QFile>

//! Project
#include "atomicdex/events/events.hpp"
#include "atomicdex/utilities/global.utilities.hpp"
#include "qt.download.manager.hpp"

namespace atomic_dex
{
    qt_download_manager::qt_download_manager(entt::dispatcher& dispatcher) : m_dispatcher(dispatcher)
    {
        SPDLOG_INFO("qt_download_manager created");
        connect(&m_manager, &QNetworkAccessManager::finished, this, &qt_download_manager::download_finished);
    }

    void
    qt_download_manager::do_download(const QUrl& url)
    {
        m_current_filename     = atomic_dex::utils::u8string(fs::path(url.toString().toStdString()).filename());
        m_last_downloaded_path = fs::temp_directory_path() / m_current_filename;
        QNetworkRequest request(url);
        request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::RedirectPolicy::NoLessSafeRedirectPolicy);
        QNetworkReply* reply = m_manager.get(request);
        connect(reply, &QNetworkReply::downloadProgress, this, &qt_download_manager::download_progress);
        m_current_downloads.append(reply);
    }

    void
    qt_download_manager::download_progress(qint64 bytes_received, qint64 bytes_total)
    {
        m_current_progress = float(bytes_received) / float(bytes_total);
        m_dispatcher.trigger(qt_download_progressed{m_current_progress});
        SPDLOG_INFO("bytes_received : {}, bytes_total: {}, percent {}%", bytes_received, bytes_total, m_current_progress * 100);
    }

    void
    qt_download_manager::download_finished(QNetworkReply* reply)
    {
        auto save_disk_functor = [this](QIODevice* data) {
            QFile file(utils::u8string(m_last_downloaded_path).c_str());
            if (!file.open(QIODevice::WriteOnly))
            {
                SPDLOG_ERROR("Could not open {} for writing: {}", utils::u8string(m_last_downloaded_path), file.errorString().toStdString());
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
            SPDLOG_INFO("Successfully downloaded: {}", m_current_filename);
            if (save_disk_functor(reply))
            {
                SPDLOG_INFO("Successfully saved {} to {}", url.toString().toStdString(), utils::u8string(m_last_downloaded_path));
                m_dispatcher.trigger<download_release_finished>();
            }
        }

        m_current_downloads.removeAll(reply);
        reply->deleteLater();
    }

    fs::path
    qt_download_manager::get_last_download_path() const
    {
        return m_last_downloaded_path;
    }

    qt_download_manager::~qt_download_manager() {}
} // namespace atomic_dex