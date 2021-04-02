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

        Q_PROPERTY(QString last_release_tag_name READ get_last_release_tag_name NOTIFY last_release_tag_nameChanged)
        Q_PROPERTY(bool update_needed READ is_update_needed NOTIFY update_neededChanged)
        Q_PROPERTY(bool update_ready READ is_update_ready NOTIFY update_readyChanged)
        
        boost::synchronized_value<github_api::repository_release> last_release_info;
        boost::synchronized_value<bool>                           update_ready{false};
        
        std::chrono::high_resolution_clock::time_point clock;
        
      public:
        explicit self_update_service(entt::registry& entity_registry);
        
        // ecs::pre_update_system::update implementation
        // Basically it fetches last release info and notifies the frontend if a new release is available.
        // Notification happens by modifying Q_PROPERTY `update_info`.
        void update();
        
        // Fetches last release info and notifies the frontend if a new release is available.
        // Notification happens by modifying Q_PROPERTY `update_info`.
        Q_INVOKABLE void fetch_last_release_info();
        
        // Downloads last release.
        Q_INVOKABLE void download_update();
        
        // Updates the program to the latest release (downloaded by self_update_service::download_update()).
        Q_INVOKABLE static void perform_update();
    
        [[nodiscard]] QString get_last_release_tag_name() const noexcept;
    
        // Compares fetched last release version to this build version then tells if an update can be performed or not.
        [[nodiscard]] bool is_update_needed() const noexcept;
        
        [[nodiscard]] bool is_update_ready() const noexcept;
        
      signals:
        void last_release_tag_nameChanged();
        void update_neededChanged();
        void update_readyChanged();
    };
}

REFL_AUTO(type(atomic_dex::self_update_service));