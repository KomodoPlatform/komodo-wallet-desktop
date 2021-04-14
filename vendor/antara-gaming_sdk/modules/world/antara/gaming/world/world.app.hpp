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

//! C++ System Headers
#include <string> ///< std::string

//! Dependencies Headers
#include <entt/entity/registry.hpp>   ///< entt::registry
#include <entt/signal/dispatcher.hpp> ///< entt::dispatcher

//! SDK Headers
#include "antara/gaming/ecs/system.manager.hpp" ///< ecs::system_manager
#include "antara/gaming/event/quit.game.hpp"    ///< event::quit_game

namespace antara::gaming::world
{
    class app
    {
        //! Private fields
        bool is_running_{false};
        int  game_return_value_{0};

      public:
        //! Constructors
        app(std::string config_maker_name = "game.config.maker.json") ;

        //! Destructor
        ~app() ;

        //! Public callbacks
        void receive_quit_game(const event::quit_game& evt) ;

        //! Public member functions
        int run() ;

        void process_one_frame();

      protected:
        //! Protected Fields
        entt::registry      entity_registry_;
        entt::dispatcher&   dispatcher_{this->entity_registry_.set<entt::dispatcher>()};
        ecs::system_manager system_manager_{entity_registry_};
    };
} // namespace antara::gaming::world