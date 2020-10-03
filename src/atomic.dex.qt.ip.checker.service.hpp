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

#include <QObject>

namespace atomic_dex
{
    class ip_service_checker final : public QObject, public ag::ecs::pre_update_system<ip_service_checker>
    {
        //! Q_Object definition
        Q_OBJECT

        //! Properties
        Q_PROPERTY(bool ip_authorized READ is_my_ip_authorized NOTIFY ipAuthorizedStatusChanged)

        //! Private typedefs
        using t_update_time_point = std::chrono::high_resolution_clock::time_point;

        //! Private members
        t_update_time_point              m_update_clock;
        double                           m_timer;
        std::string                      m_external_ip;
        std::atomic_bool                 m_external_ip_authorized{true}; ///< true by default
        const std::array<const char*, 7> m_non_authorized_countries{"CA", "IL", "IR", "SS", "USA", "HK", "SG"};

      signals:
        void ipAuthorizedStatusChanged();

      public:
        //! Constructor
        explicit ip_service_checker(entt::registry& registry, QObject* parent = nullptr);
        ~ip_service_checker() noexcept final = default;

        //! Public override
        void update() noexcept final;

        [[nodiscard]] bool is_my_ip_authorized() const noexcept;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::ip_service_checker))