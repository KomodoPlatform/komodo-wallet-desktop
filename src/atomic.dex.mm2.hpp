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

#include <reproc++/reproc.hpp>
#include <antara/gaming/ecs/system.hpp>

namespace atomic_dex {
    namespace ag = antara::gaming;

    class mm2 : public ag::ecs::pre_update_system<mm2> {
        reproc::process mm2_instance_;
        //! Maybe change it latter ?
        static constexpr const char *passphrase_{"atomicdexpassphrase"};
    public:
        mm2(entt::registry &registry) noexcept;
        ~mm2() noexcept;
        void update() noexcept final;
    };
}

REFL_AUTO(type(atomic_dex::mm2))