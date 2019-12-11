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

#if defined(ATOMIC_DEX_GLFW)
    #include <antara/gaming/glfw/graphic.system.hpp>
    #include <antara/gaming/glfw/input.system.hpp>
#endif
#if defined(ATOMIC_DEX_SFML)
//#include <antara/gaming/resources/resources.system.hpp>
//#include <antara/gaming/sfml/resources.manager.hpp>
    #include <antara/gaming/sfml/graphic.system.hpp>
    #include <antara/gaming/sfml/input.system.hpp>
#endif

#if defined(ATOMIC_DEX_SDL)
#include <antara/gaming/sdl/graphic.system.hpp>
#include <antara/gaming/sdl/input.system.hpp>
#endif


#include <antara/gaming/ecs/virtual.input.system.hpp>
#include "atomic.dex.gui.hpp"
#include "atomic.dex.app.hpp"
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"

namespace atomic_dex
{
	application::application() noexcept
	{
		//! Load the resources system
#if defined(ATOMIC_DEX_GLFW)
        auto &graphic_system = system_manager_.create_system<ag::glfw::graphic_system>();
        system_manager_.create_system<ag::glfw::input_system>(graphic_system.get_window());
#endif

#if defined(ATOMIC_DEX_SFML)
        auto &graphic_system = system_manager_.create_system<ag::sfml::graphic_system>();
        system_manager_.create_system<ag::sfml::input_system>(graphic_system.get_window());
#endif

#if defined(ATOMIC_DEX_SDL)
		auto& graphic_system = system_manager_.create_system<ag::sdl::graphic_system>();
		graphic_system.set_framerate_limit(30);
		system_manager_.create_system<ag::sdl::input_system>(graphic_system.get_window());
#endif

		//! Create virtual input system
		system_manager_.create_system<ag::ecs::virtual_input_system>();

		//! MM2 system need to be created before the GUI and give the instance to the gui
		auto& mm2_system = system_manager_.create_system<mm2>();
		auto& paprika_system = system_manager_.create_system<coinpaprika_provider>(mm2_system);
		system_manager_.create_system<gui>(mm2_system, paprika_system);
#if defined(ATOMIC_DEX_GLFW)
        system_manager_.prioritize_system<atomic_dex::gui, ag::glfw::graphic_system>();
#endif
#if defined(ATOMIC_DEX_SFML)
        system_manager_.prioritize_system<atomic_dex::gui, ag::sfml::graphic_system>();
#endif
#if defined(ATOMIC_DEX_SDL)
		system_manager_.prioritize_system<gui, ag::sdl::graphic_system>();
#endif
	}
}
