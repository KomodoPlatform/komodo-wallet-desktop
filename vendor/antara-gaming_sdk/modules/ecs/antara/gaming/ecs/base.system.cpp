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

//! SDK Headers
#include "antara/gaming/ecs/base.system.hpp"

namespace antara::gaming::ecs
{
    base_system::base_system(entt::registry& entity_registry, bool im_a_plugin_system)  :
        entity_registry_(entity_registry), dispatcher_(entity_registry_.ctx<entt::dispatcher>()), is_plugin_{im_a_plugin_system}
    {
    }

    void
    base_system::mark() 
    {
        marked_ = true;
    }

    void
    base_system::unmark() 
    {
        marked_ = false;
    }

    bool
    base_system::is_marked() const 
    {
        return marked_;
    }

    void
    base_system::enable() 
    {
        enabled_ = true;
    }

    void
    base_system::disable() 
    {
        enabled_ = false;
    }

    bool
    base_system::is_enabled() const 
    {
        return enabled_;
    }

    void
    base_system::im_a_plugin() 
    {
        is_plugin_ = true;
    }

    bool
    base_system::is_a_plugin() const 
    {
        return is_plugin_;
    }

    void*
    base_system::get_user_data() 
    {
        return user_data_;
    }

    void
    base_system::set_user_data(void* data) 
    {
        user_data_ = data;
    }
} // namespace antara::gaming::ecs