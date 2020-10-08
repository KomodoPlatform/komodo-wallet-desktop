/******************************************************************************
 * Copyright © 2013-2019 The Komodo Platform Developers.                      *
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

//! Deps
#include <antara/gaming/ecs/system.hpp>

//! QT
#include <QObject>

namespace atomic_dex
{
    class internet_service_checker final : public QObject, public ag::ecs::pre_update_system<internet_service_checker>
    {
        //! Q_Object definition
        Q_OBJECT

        Q_PROPERTY(bool internet_reacheable READ is_internet_alive WRITE set_internet_alive NOTIFY internetStatusChanged)
        Q_PROPERTY(
            double seconds_left_to_auto_retry READ get_seconds_left_to_auto_retry WRITE set_seconds_left_to_auto_retry NOTIFY secondsLeftToAutoRetryChanged)
        //! Private typedefs
        using t_update_time_point = std::chrono::high_resolution_clock::time_point;

        //! Private members
        t_update_time_point m_update_clock;
        double              m_timer;
        std::atomic_bool    is_internet_reacheable{true};
        std::atomic_bool    is_paprika_provider_alive{true};
        std::atomic_bool    is_cipig_electrum_alive{true};
        std::atomic_bool    is_google_reacheable{true};
        std::atomic_bool    is_our_private_endpoint_reacheable{true};

        //! Private functions
        void fetch_internet_connection();

      signals:
        void internetStatusChanged();
        void secondsLeftToAutoRetryChanged();

      public:
        //! Constructor
        explicit internet_service_checker(entt::registry& registry, QObject* parent = nullptr);
        ~internet_service_checker() noexcept final = default;

        //! Public override
        void update() noexcept final;

        //! QT Properties
        [[nodiscard]] bool is_internet_alive() const noexcept;
        [[nodiscard]] double get_seconds_left_to_auto_retry() const noexcept;
        void set_seconds_left_to_auto_retry(double time_left) noexcept;

        void set_internet_alive(bool internet_status) noexcept;
        void query_internet(t_http_client_ptr& client, const std::string uri, std::atomic_bool internet_service_checker::*p) noexcept;

        Q_INVOKABLE void retry() noexcept;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::internet_service_checker))