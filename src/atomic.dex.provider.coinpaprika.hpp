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

#include <antara/gaming/ecs/system.hpp>

namespace atomic_dex {
    namespace ag = antara::gaming;

    class coinpaprika_provider final : public ag::ecs::pre_update_system<coinpaprika_provider> {
    public:
        coinpaprika_provider(entt::registry &registry);

        void update() noexcept final;
    };
}

REFL_AUTO(type(atomic_dex::coinpaprika_provider))