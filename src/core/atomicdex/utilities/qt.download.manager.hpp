#pragma once

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QUrl>
#include <QVector>

#include <entt/signal/dispatcher.hpp>
//! Deps
#include <antara/gaming/ecs/system.manager.hpp>

#include "atomicdex/events/events.hpp"

namespace atomic_dex
{
    class qt_download_manager final : public QObject, public ag::ecs::pre_update_system<qt_download_manager>
    {
        Q_OBJECT

        //! Private typedefs
        using t_update_time_point = std::chrono::high_resolution_clock::time_point;

        //! Private members
        ag::ecs::system_manager& m_system_manager;
        t_update_time_point      m_update_clock;
        double                   m_timer;

        entt::dispatcher&        m_dispatcher;
        QNetworkAccessManager    m_manager;
        std::string              m_current_filename;
        fs::path                 m_last_downloaded_path;
        QVector<QNetworkReply*>  m_current_downloads;
        float                    m_current_progress;

      public:

        //! Constructor
        explicit qt_download_manager(
            entt::registry& registry, ag::ecs::system_manager& system_manager,
            entt::dispatcher& dispatcher, QObject* parent = nullptr);
        ~qt_download_manager() final = default;

        //! QT Properties
        void                   do_download(const QUrl& url);
        [[nodiscard]] fs::path get_last_download_path() const;

        //! Public override
        void update()  final;
        
        //! Events
        void on_download_started([[maybe_unused]] const download_started& evt);

      public slots:
        void download_finished(QNetworkReply* reply);
        void download_progress(qint64 bytes_received, qint64 bytes_total);
    };
    
    struct qt_download_progressed
    {
        float progress;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::qt_download_manager))
