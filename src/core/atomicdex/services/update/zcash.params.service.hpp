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

#include <QDebug>
#include <QObject>
#include <QVariant>
#include <QJsonObject>
#include <QJsonDocument>
#include <QTranslator>

#include <antara/gaming/ecs/system.manager.hpp>
#include <boost/thread/synchronized_value.hpp>
#include <nlohmann/json_fwd.hpp>
#include <entt/signal/dispatcher.hpp>
#include "atomicdex/utilities/qt.download.manager.hpp"


namespace atomic_dex
{
    class zcash_params_service final : public QObject, public ag::ecs::pre_update_system<zcash_params_service>
    {
        Q_OBJECT

        Q_PROPERTY(QJsonObject m_download_status READ get_download_status WRITE set_download_status NOTIFY downloadStatusChanged)

        using t_update_time_point = std::chrono::high_resolution_clock::time_point;
        using t_json_synchronized = boost::synchronized_value<nlohmann::json>;

        ag::ecs::system_manager&        m_system_manager;
        entt::dispatcher&               m_dispatcher;
        t_json_synchronized             m_update_info;
        t_update_time_point             m_update_clock;
        QJsonObject                     m_download_status;
        boost::synchronized_value<bool> is_fetching;

        void fetch_update_info();

      public:
        explicit zcash_params_service(
            entt::registry& registry, ag::ecs::system_manager& system_manager,
            entt::dispatcher& dispatcher, QObject* parent = nullptr);
        ~zcash_params_service() final = default;

        void update() final;

        [[nodiscard]] QJsonObject             get_download_status() const;
        [[nodiscard]] fs::path                get_zcash_params_folder();
        Q_INVOKABLE   void                    download_zcash_params();
        Q_INVOKABLE   QString                 get_download_progress();

      signals:
        void downloadStatusChanged();

      public slots:
        void                        set_download_status(QJsonObject& status);

    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::zcash_params_service))
