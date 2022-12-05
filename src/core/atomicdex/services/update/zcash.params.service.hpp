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


#include <QJsonObject>
#include <QJsonDocument>
#include <filesystem>

#include <antara/gaming/ecs/system.manager.hpp>
#include <boost/thread/synchronized_value.hpp>
#include <entt/signal/dispatcher.hpp>
#include <nlohmann/json.hpp>

#include "atomicdex/pch.hpp"


namespace atomic_dex
{
    class zcash_params_service final : public QObject, public ag::ecs::pre_update_system<zcash_params_service>
    {
        Q_OBJECT

        Q_PROPERTY(QJsonObject m_combined_download_status READ get_combined_download_status NOTIFY combinedDownloadStatusChanged)

        using t_update_time_point = std::chrono::high_resolution_clock::time_point;
        using t_json_synchronized = boost::synchronized_value<nlohmann::json>;

        ag::ecs::system_manager&        m_system_manager;
        entt::dispatcher&               m_dispatcher;
        t_json_synchronized             m_update_info;
        t_update_time_point             m_update_clock;
        QJsonObject                     m_combined_download_status;
        bool                            m_is_downloading{false};
        QStringList                     m_enable_after_download;

        void fetch_update_info();

      public:
        explicit zcash_params_service(
            entt::registry& registry, ag::ecs::system_manager& system_manager,
            entt::dispatcher& dispatcher, QObject* parent = nullptr);
        ~zcash_params_service() final = default;

        void update() final;

        Q_INVOKABLE   void                        enable_after_download(const QString& coin);
        Q_INVOKABLE   QStringList                 get_enable_after_download();
        Q_INVOKABLE   void                        clear_enable_after_download();
        Q_INVOKABLE   void                        download_zcash_params();
        Q_INVOKABLE   bool                        is_downloading();
        Q_INVOKABLE   QString                     get_combined_download_progress();
        [[nodiscard]] QJsonObject                 get_combined_download_status() const;
        [[nodiscard]] std::filesystem::path       get_zcash_params_folder();

      signals:
        void          combinedDownloadStatusChanged();

      public slots:
        void          set_combined_download_status(QJsonObject& status);
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::zcash_params_service))
