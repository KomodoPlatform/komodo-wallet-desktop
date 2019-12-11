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
#include <antara/gaming/sdl/sdl.opengl.image.loading.hpp>
#include "atomic.dex.gui.style.hpp"
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"

namespace atomic_dex
{
	namespace ag = antara::gaming;

	struct gui_variables
	{
		ImVec2 main_window_size;
		std::vector<bool> enableable_coins_select_list;
		std::string curr_asset_code = "";
	};

	class gui final : public ag::ecs::post_update_system<gui>
	{
#if defined(ENABLE_CODE_RELOAD_UNIX)
        std::unique_ptr<jet::Live> live_{nullptr};
#endif
	public:
		using icons_registry = folly::ConcurrentHashMap<std::string, antara::gaming::sdl::opengl_image>;

		void on_key_pressed(const ag::event::key_pressed& evt) noexcept;

		explicit gui(entt::registry& registry, atomic_dex::mm2& mm2_system,
		             atomic_dex::coinpaprika_provider& paprika_system);

		// ReSharper disable once CppFinalFunctionInFinalClass
		void update() noexcept final;

		void init_live_coding();
		void reload_code();
		void update_live_coding();
		const icons_registry& get_icons() const noexcept { return icons_; }

	private:
		folly::ConcurrentHashMap<std::string, antara::gaming::sdl::opengl_image> icons_;
		gui_variables gui_vars_;
		atomic_dex::mm2& mm2_system_;
		atomic_dex::coinpaprika_provider& paprika_system_;
	};
}

REFL_AUTO(type(atomic_dex::gui))
