#pragma once

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QUrl>
#include <QVector>

#include <entt/signal/dispatcher.hpp>

namespace atomic_dex
{
    class qt_download_manager : public QObject
    {
        Q_OBJECT

        entt::dispatcher&       m_dispatcher;
        QNetworkAccessManager   m_manager;
        std::string             m_current_filename;
        fs::path                m_last_downloaded_path;
        QVector<QNetworkReply*> m_current_downloads;
        float                   m_current_progress;

      public:
        qt_download_manager(entt::dispatcher& dispatcher);
        ~qt_download_manager();

        void                   do_download(const QUrl& url);
        [[nodiscard]] fs::path get_last_download_path() const;

      public slots:
        void download_finished(QNetworkReply* reply);
        void download_progress(qint64 bytes_received, qint64 bytes_total);
    };
    
    struct qt_download_progressed
    {
        float progress;
    };
} // namespace atomic_dex