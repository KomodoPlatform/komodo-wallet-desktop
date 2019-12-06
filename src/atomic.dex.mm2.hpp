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

#include <thread>
#include <vector>
#include <atomic>
#include <reproc++/reproc.hpp>
#include <antara/gaming/ecs/system.hpp>
#include <unordered_map>
#include "atomic.dex.coins.config.hpp"

namespace atomic_dex {
    namespace ag = antara::gaming;

    class mm2 : public ag::ecs::pre_update_system<mm2> {
        reproc::process mm2_instance_;
        std::atomic<bool> mm2_initialized_{false};
        std::thread mm2_init_thread_;
        using coins_enabled_array = std::vector<std::string>;
        coins_enabled_array active_coins_;
        using coins_registry = std::unordered_map<std::string, atomic_dex::coins_config>;
        coins_registry coins_informations_;
    public:
        bool enable_default_coins() noexcept;
        bool enable_coin(const std::string& ticker) noexcept;

        explicit mm2(entt::registry &registry) noexcept;

        ~mm2() noexcept;

        void update() noexcept final;

        [[nodiscard]] const std::atomic<bool> &is_mm2_initialized() const noexcept;

        //! Get coins that are currently activated
        std::vector<coins_config> get_enabled_coins() const noexcept;

        //! Get coins that can be activated
        std::vector<coins_config> get_enableable_coins() const noexcept;

        //! Get Specific info about one coin
        const coins_config& get_coin_info(const std::string& ticker) const noexcept;
    };
}

REFL_AUTO(type(atomic_dex::mm2))