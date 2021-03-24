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

#include "antara/gaming/core/real.path.hpp"           ///< core::assets_real_path
#include "antara/gaming/event/start.game.hpp"         ///< event::start_game, event::quit_game
#include "antara/gaming/world/world.app.hpp"

namespace antara::gaming::world
{
    //! Constructor
    app::app([[maybe_unused]] std::string config_maker_name) 
    {
        dispatcher_.sink<event::quit_game>().connect<&app::receive_quit_game>(*this);
    }

    //! Public callbacks
    void
    app::receive_quit_game(const event::quit_game& evt) 
    {
        this->is_running_        = false;
        this->game_return_value_ = evt.return_value_;
    }

    int
    app::run() 
    {
        if (not system_manager_.nb_systems())
        {
            return this->game_return_value_;
        }

        this->dispatcher_.trigger<event::start_game>();
        this->is_running_ = true;
        this->system_manager_.start();

        while (this->is_running_) { process_one_frame(); }

        return this->game_return_value_;
    }

    void
    app::process_one_frame()
    {
        this->system_manager_.update();
    }

    app::~app()  {}
} // namespace antara::gaming::world