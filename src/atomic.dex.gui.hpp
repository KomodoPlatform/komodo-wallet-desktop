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

#if defined(ENABLE_CODE_RELOAD_UNIX)

#include <jet/live/Utility.hpp>
#include <jet/live/Live.hpp>

#endif

#include <antara/gaming/ecs/system.hpp>
#include <antara/gaming/event/key.pressed.hpp>
#include "atomic.dex.gui.style.hpp"
#include "atomic.dex.mm2.hpp"

namespace atomic_dex {
    namespace ag = antara::gaming;

    class gui final : public ag::ecs::post_update_system<gui> {
        void reload_code();

#if defined(ENABLE_CODE_RELOAD_UNIX)
        std::unique_ptr<jet::Live> live_{nullptr};
#endif
    public:
        void on_key_pressed(const ag::event::key_pressed &evt) noexcept;

        explicit gui(entt::registry &registry, atomic_dex::mm2& mm2_system) noexcept;

        void update() noexcept final;

        void init_live_coding();

        void update_live_coding();

    private:
        atomic_dex::mm2& mm2_system_;
    };
}

REFL_AUTO(type(atomic_dex::gui))