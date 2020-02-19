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

//! PCH Headers
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.gui.v2.state.hpp"
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"


namespace atomic_dex
{
    class gui_v2 final : public ag::ecs::post_update_system<gui_v2>
    {
        mm2&                  m_mm2_instance;
        coinpaprika_provider& m_paprika_system;
        e_gui_state           m_current_state;

        void first_run_view();
        void login_view();
        void waiting_view();
        void portfolio_view();
        void trading_view();

      public:
        //! Constructor
        explicit gui_v2(entt::registry& registry, mm2& mm2_system, coinpaprika_provider& paprika_system);

        //! Public member method
        void update() noexcept final;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::gui_v2))