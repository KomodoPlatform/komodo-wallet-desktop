/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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

//! STD
#include <unordered_set>

//! Deps
#include <antara/gaming/ecs/system.hpp>
#include <boost/thread/synchronized_value.hpp>
#include <range/v3/view.hpp>

//! QT
#include <QObject>

namespace atomic_dex
{
    class ip_service_checker final : public QObject, public ag::ecs::pre_update_system<ip_service_checker>
    {
        //! Q_Object definition
        Q_OBJECT

        //! Properties
        Q_PROPERTY(bool ip_authorized READ is_my_ip_authorized NOTIFY ipAuthorizedStatusChanged)
        Q_PROPERTY(QString ip_country READ my_country_ip NOTIFY ipCountryChanged)

        //! Private typedefs
        using t_update_time_point = std::chrono::high_resolution_clock::time_point;

        //! Private members
        t_update_time_point                    m_update_clock;
        double                                 m_timer;
        boost::synchronized_value<std::string> m_external_ip;
        boost::synchronized_value<std::string> m_country;
        std::atomic_bool                       m_external_ip_authorized{true}; ///< true by default
        const std::unordered_set<std::string>  m_non_authorized_countries{"CA", "IL", "IR", "SS", "USA", "HK", "SG", "AT", "US"};

      signals:
        void ipAuthorizedStatusChanged();
        void ipCountryChanged();

      public:
        //! Constructor
        explicit ip_service_checker(entt::registry& registry, QObject* parent = nullptr);
        ~ip_service_checker() noexcept final = default;

        //! Public override
        void update() noexcept final;

        [[nodiscard]] bool    is_my_ip_authorized() const noexcept;
        [[nodiscard]] QString my_country_ip() const noexcept;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::ip_service_checker))
