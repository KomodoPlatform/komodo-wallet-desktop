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
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QUrl>
#include <QVector>

#include <entt/signal/dispatcher.hpp>

namespace atomic_dex
{
    class qt_downloader : public QObject
    {
        Q_OBJECT

        Q_PROPERTY(QJsonObject download_status READ get_download_status NOTIFY downloadStatusChanged)

        entt::dispatcher&       m_dispatcher;
        QNetworkAccessManager   m_manager;
        std::string             m_download_filename;
        std::filesystem::path                m_download_path;
        QVector<QNetworkReply*> m_current_downloads;
        float                   m_download_progress;
        QJsonObject             m_download_status;
        QNetworkReply*          m_download_reply;

      public:
        qt_downloader(entt::dispatcher& dispatcher);
        ~qt_downloader();

        void                          do_download(const QUrl& url, std::string filename, std::filesystem::path folder);
        [[nodiscard]] std::filesystem::path        get_last_download_path() const;
        [[nodiscard]] QJsonObject     get_download_status() const;
        [[nodiscard]] QJsonObject     get_combined_download_status() const;
        [[nodiscard]] QNetworkReply*  get_reply() const;

      signals:
        void downloadStatusChanged(QJsonObject &status);

      public slots:
        void download_finished(QNetworkReply* reply);
        void download_progress(qint64 bytes_received, qint64 bytes_total);
    };
    
} // namespace atomic_dex
