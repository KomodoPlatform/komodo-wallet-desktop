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

#include <QFile>

//! Project
#include "atomicdex/events/events.hpp"
#include "atomicdex/services/update/zcash.params.service.hpp"
#include "atomicdex/utilities/global.utilities.hpp"
#include "atomicdex/utilities/qt.download.manager.hpp"

namespace atomic_dex
{
    qt_downloader::qt_downloader(entt::dispatcher& dispatcher) : m_dispatcher(dispatcher)
    {
        connect(&m_manager, &QNetworkAccessManager::finished, this, &qt_downloader::download_finished);
    }

    void
    qt_downloader::do_download(const QUrl& url, std::string filename, fs::path folder)
    {
        m_download_filename            = filename;
        m_download_status.insert("filename", QString::fromStdString(filename));
        m_download_path = folder / m_download_filename;
        QNetworkRequest request(url);
        request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::RedirectPolicy::NoLessSafeRedirectPolicy);
        QNetworkReply* reply = m_manager.get(request);
        connect(reply, &QNetworkReply::downloadProgress, this, &qt_downloader::download_progress);
        m_download_reply = reply;
        m_current_downloads.append(reply);
        m_dispatcher.trigger<download_started>();
    }

    void
    qt_downloader::download_progress(qint64 bytes_received, qint64 bytes_total)
    {
        m_download_progress = float(bytes_received) / float(bytes_total);
        m_download_status.insert("progress", m_download_progress);
        emit downloadStatusChanged(m_download_status);
        m_dispatcher.trigger(m_download_status);
        // SPDLOG_INFO("{} bytes_received : {}, bytes_total: {}, percent {}%", m_download_filename, bytes_received, bytes_total, m_download_progress * 100);
    }

    void
    qt_downloader::download_finished(QNetworkReply* reply)
    {
        auto save_disk_functor = [this](QIODevice* data) {
            // Todo: handle download fail on front end
            QFile file(utils::u8string(m_download_path).c_str());
            if (!file.open(QIODevice::WriteOnly))
            {
                SPDLOG_ERROR("Could not open {} for writing: {}", utils::u8string(m_download_path), file.errorString().toStdString());
                m_dispatcher.trigger<download_failed>();
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
                m_dispatcher.trigger<download_complete>();
            }
        }

        m_current_downloads.removeAll(reply);
        reply->deleteLater();
    }

    QNetworkReply*
    qt_downloader::get_reply() const
    {
        return m_download_reply;
    }

    fs::path
    qt_downloader::get_last_download_path() const
    {
        return m_download_path;
    }

    QJsonObject
    qt_downloader::get_download_status() const
    {
        return m_download_status;
    }

    qt_downloader::~qt_downloader() {}
} // namespace atomic_dex
