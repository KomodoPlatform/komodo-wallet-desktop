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

//! Project Headers
#include "atomic.dex.app.hpp"
#include "atomic.dex.gui.hpp"
#include "atomic.dex.gui.v2.hpp"
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"

namespace atomic_dex
{
    application::application() noexcept
    {
        auto& graphic_system = system_manager_.create_system<ag::sdl::graphic_system>();
        graphic_system.set_framerate_limit(30);
        system_manager_.create_system<ag::sdl::input_system>(graphic_system.get_window());

        //! Create virtual input system
        system_manager_.create_system<ag::ecs::virtual_input_system>();

        //! MM2 system need to be created before the GUI and give the instance to the gui
        auto& mm2_system     = system_manager_.create_system<mm2>();
        auto& paprika_system = system_manager_.create_system<coinpaprika_provider>(mm2_system);
#ifdef ATOMICDEX_V2_UI
        system_manager_.create_system<gui_v2>(mm2_system, paprika_system);
        system_manager_.prioritize_system<gui_v2, ag::sdl::graphic_system>();
#else
        system_manager_.create_system<gui>(mm2_system, paprika_system);
        system_manager_.prioritize_system<gui, ag::sdl::graphic_system>();
#endif
    }
} // namespace atomic_dex
