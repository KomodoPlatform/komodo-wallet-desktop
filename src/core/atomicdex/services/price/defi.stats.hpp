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

#include <antara/gaming/ecs/system.manager.hpp>
#include <boost/thread/synchronized_value.hpp>
#include <nlohmann/json.hpp>
#include "atomicdex/config/app.cfg.hpp"
#include "atomicdex/services/kdf/kdf.service.hpp"

namespace atomic_dex::kdf
{
    struct defi_stats_volumes_answer
    {
        nlohmann::json                 result;
        int                            status_code;
    };
    void from_json(const nlohmann::json& j, defi_stats_volumes_answer& answer);
} // namespace atomic_dex::kdf


namespace atomic_dex
{
    using t_defi_stats_volumes_answer         = kdf::defi_stats_volumes_answer;
} // namespace atomic_dex

namespace atomic_dex
{
    class global_defi_stats_service final : public ag::ecs::pre_update_system<global_defi_stats_service>
    {

        //! Private typedefs
        using t_defi_stats_time_point     = std::chrono::high_resolution_clock::time_point;
        using t_json_synchronized         = boost::synchronized_value<nlohmann::json>;

        //! Private member fields
        ag::ecs::system_manager&          m_system_manager;
        t_json_synchronized               m_defi_stats_volumes;
        t_defi_stats_time_point           m_update_clock;

        //! private functions
        void                              process_update();

      public:
        //! Constructor
        explicit global_defi_stats_service(entt::registry& registry, ag::ecs::system_manager& system_manager);

        //! Destructor
        ~global_defi_stats_service()  final = default;

        //! Public override
        void update()  final;

        //! Public API
        void                  process_defi_stats();
        std::string           get_trades_24h(const std::string& base, const std::string& quote) const;
        std::string           get_volume_24h_usd(const std::string& base, const std::string& quote) const;

        
        
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::global_defi_stats_service))
