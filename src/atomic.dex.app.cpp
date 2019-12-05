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

#include <antara/gaming/sfml/graphic.system.hpp>
#include <antara/gaming/sfml/input.system.hpp>
#include "atomic.dex.gui.hpp"
#include "atomic.dex.app.hpp"

namespace atomic_dex {
    application::application() noexcept {
        auto &graphic_system = system_manager_.create_system<ag::sfml::graphic_system>();
        system_manager_.create_system<ag::sfml::input_system>(graphic_system.get_window());
        system_manager_.create_system<atomic_dex::gui>();
        system_manager_.prioritize_system<atomic_dex::gui, ag::sfml::graphic_system>();
    }
}
