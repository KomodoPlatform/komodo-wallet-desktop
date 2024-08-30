/******************************************************************************
 * Copyright © 2013-2024 The Komodo Platform Developers.                      *
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
    class timesync_checker_service final : public QObject, public ag::ecs::pre_update_system<timesync_checker_service>
    {
        Q_OBJECT

        Q_PROPERTY(QVariant timesyncInfo READ get_timesync_info NOTIFY timesyncInfoChanged)
        Q_PROPERTY(bool isTimesyncFetching READ get_is_timesync_fetching NOTIFY isTimesyncFetchingChanged)

        using t_timesync_time_point = std::chrono::high_resolution_clock::time_point;
        using t_bool_synchronized = boost::synchronized_value<bool>;

        t_bool_synchronized     m_timesync_status;
        t_timesync_time_point   m_timesync_clock;
        t_bool_synchronized     is_timesync_fetching;

        void fetch_timesync_status();

      public:
        explicit timesync_checker_service(entt::registry& registry, QObject* parent = nullptr);
        ~timesync_checker_service() final = default;

        void update() final;

        [[nodiscard]] bool     get_timesync_info() const;
        [[nodiscard]] bool     get_is_timesync_fetching() const noexcept { return *is_timesync_fetching; }

      signals:
        void timesyncInfoChanged();
        void isTimesyncFetchingChanged();
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::timesync_checker_service))
