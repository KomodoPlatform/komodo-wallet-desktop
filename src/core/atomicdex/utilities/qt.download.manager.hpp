#pragma once

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QVariant>
#include <QJsonObject>
#include <QUrl>
#include <QVector>

#include <boost/thread/synchronized_value.hpp>
#include <entt/signal/dispatcher.hpp>

//! Deps
#include <antara/gaming/ecs/system.manager.hpp>

#include "atomicdex/events/events.hpp"


namespace atomic_dex
{
    class qt_download_manager final : public QObject, public ag::ecs::pre_update_system<qt_download_manager>
    {
        Q_OBJECT

        Q_PROPERTY(QJsonObject download_status READ get_download_status WRITE set_download_status NOTIFY downloadStatusChanged)
        Q_PROPERTY(bool download_complete READ get_download_complete WRITE set_download_complete NOTIFY downloadFinishedChanged)

        //! Private typedefs
        using t_update_time_point      = std::chrono::high_resolution_clock::time_point;
        using t_qt_synchronized_json   = boost::synchronized_value<QJsonObject>;

        //! Private members
        ag::ecs::system_manager& m_system_manager;
        t_update_time_point      m_update_clock;
        double                   m_timer;

        entt::dispatcher&        m_dispatcher;
        QNetworkAccessManager    m_manager;
        std::string              m_download_filename;
        fs::path                 m_download_path;
        QVector<QNetworkReply*>  m_current_downloads;
        float                    m_download_progress;
        bool                     m_download_complete{false};
        QJsonObject              m_download_status;

      public:

        //! Constructor
        explicit qt_download_manager(
            entt::registry& registry, ag::ecs::system_manager& system_manager,
            entt::dispatcher& dispatcher, QObject* parent = nullptr);
        ~qt_download_manager() final = default;

        //! QT Properties
        void                   do_download(const std::string url, const fs::path folder, std::string filename);
        [[nodiscard]] fs::path get_last_download_path();

        //! Public override
        void update()  final;

        //! Events
        void on_download_started([[maybe_unused]] const download_started& evt);
        void download_finished(QNetworkReply* reply);

        //! Get / Set
        QJsonObject get_download_status();
        void set_download_status(QJsonObject data);
        bool get_download_complete();
        void set_download_complete(bool finished);

      signals:
        void downloadStatusChanged();
        void downloadFinishedChanged();

      public slots:
        void download_progress(qint64 bytes_received, qint64 bytes_total);
    };
    
    struct qt_download_progressed
    {
        std::string filename;
        float progress;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::qt_download_manager))
