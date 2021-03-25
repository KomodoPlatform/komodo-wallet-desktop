#pragma once

//! Qt
#include <QObject>
#include <QVariant>

//! Deps
#include <boost/thread/synchronized_value.hpp>
#include <antara/gaming/ecs/system.hpp>

//! Project Headers
#include "atomicdex/api/github/github.api.hpp"

namespace atomic_dex
{
    class self_update_service : public QObject, public ag::ecs::pre_update_system<self_update_service>
    {
        Q_OBJECT

        Q_PROPERTY(QVariant last_release_info READ get_last_release_info NOTIFY last_release_infoChanged)
        
        boost::synchronized_value<github_api::repository_release> last_release_info;
        
        std::chrono::high_resolution_clock::time_point clock;
        
      public:
        // ecs::pre_update_system::update implementation
        // Basically it fetches last release info and notifies the frontend if a new release is available.
        // Notification happens by modifying Q_PROPERTY `update_info`.
        void update() noexcept;
        
        // Fetches last release info and notifies the frontend if a new release is available.
        // Notification happens by modifying Q_PROPERTY `update_info`.
        Q_INVOKABLE void fetch_last_release_info();
        
        // Updates the program to the latest release.
        Q_INVOKABLE void run_update();
        
        [[nodiscard]] QVariant get_last_release_info() const noexcept;
        
      signals:
        void last_release_infoChanged();
    };
}

REFL_AUTO(type(atomic_dex::self_update_service));