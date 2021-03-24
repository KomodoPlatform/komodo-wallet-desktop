/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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

//! SDK Headers
#include "antara/gaming/core/safe.refl.hpp"      ///< REFL_AUTO
#include "antara/gaming/event/event.invoker.hpp" ///< event::invoker_dispatcher

namespace antara::gaming::event
{
    /**
     * @struct quit_game
     * @brief Event that allows us to leave a game with a return value
     *
     * @verbatim embed:rst:leading-asterisk
     *      .. note::
     *         This class is automatically reflected for scripting systems such as lua, python.
     * @endverbatim
     */
    struct quit_game
    {
        //! Static fields
        static constexpr const event::invoker_dispatcher<quit_game, int> invoker{};

        //! Constructors

        /**
         * constructor with args
         * @param return_value The return value of the program when leaving the game
         *
         * @verbatim embed:rst:leading-asterisk
         *      .. note::
         *         Principal Constructor.
         * @endverbatim
         *
         * Example:
         * @code{cpp}
         *          #include <entt/entity/registry.hpp>
         *          #include <entt/dispatcher/dispatcher.hpp>
         *          #include <antara/gaming/event/quit_game.hpp>
         *
         *          int main()
         *          {
         *              entt::registry entity_registry;
         *              entt::dispatcher& dispatcher{registry.set<entt::dispatcher>()};
         *              dispatcher.trigger<quit_game>(0);
         *          }
         * @endcode
         */
        quit_game(int return_value) ;

        /**
         * default constructor (for scripting systems convenience)
         */
        quit_game();

        //! Fields
        int return_value_; ///< the return value of the program when leaving the game
    };
} // namespace antara::gaming::event

REFL_AUTO(type(antara::gaming::event::quit_game));