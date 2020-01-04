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

namespace {
    atomic_dex::e_gui_state guess_initial_state() {
        using namespace atomic_dex;
        return fs::exists(ag::core::assets_real_path() / "config/encrypted.seed") ? e_gui_state::credential_view : e_gui_state::first_run_view;
    }
}

namespace atomic_dex
{
    class gui_v2
    {
        e_gui_state m_current_state{guess_initial_state()};
    };
}