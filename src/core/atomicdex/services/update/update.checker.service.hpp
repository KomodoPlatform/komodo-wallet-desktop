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

#include <QObject>
#include <QVariant>

#include <boost/thread/synchronized_value.hpp>
#include <nlohmann/json_fwd.hpp>

#include <antara/gaming/ecs/system.hpp>

namespace atomic_dex
{
    class update_checker_service final : public QObject, public ag::ecs::pre_update_system<update_checker_service>
    {
        Q_OBJECT

        Q_PROPERTY(QVariant updateInfo READ get_update_info NOTIFY updateInfoChanged)
        Q_PROPERTY(bool isFetching READ get_is_fetching NOTIFY isFetchingChanged)

        using t_update_time_point = std::chrono::high_resolution_clock::time_point;
        using t_json_synchronized = boost::synchronized_value<nlohmann::json>;

        t_json_synchronized             m_update_info;
        t_update_time_point             m_update_clock;
        boost::synchronized_value<bool> is_fetching;

        void fetch_update_info();

      public:
        explicit update_checker_service(entt::registry& registry, QObject* parent = nullptr);
        ~update_checker_service() final = default;

        void update() final;

        [[nodiscard]] QVariant get_update_info() const;
        [[nodiscard]] bool     get_is_fetching() const noexcept { return *is_fetching; }

      signals:
        void updateInfoChanged();
        void isFetchingChanged();
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::update_checker_service))
