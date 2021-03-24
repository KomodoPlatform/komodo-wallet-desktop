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

#include <doctest/doctest.h>

//! SDK Headers
#include "antara/gaming/ecs/interpolation.system.hpp" ///< ecs::interpolation_system
#include "antara/gaming/world/world.app.hpp"          ///< world::app

namespace antara::gaming::world::tests
{
    class empty_concrete_world : public world::app
    {
      public:
        empty_concrete_world()
        {
            system_manager_.mark_system<ecs::interpolation_system>();
            system_manager_.start();
            system_manager_.update();
            assert(system_manager_.nb_systems() == 0);
        };
    };


    class concrete_pre_system final : public ecs::pre_update_system<concrete_pre_system>
    {
      public:
        concrete_pre_system(entt::registry& registry) : system(registry)
        {
        }

        void
        update()  final
        {
            counter += 1;
            if (counter == 10ull)
            {
                this->dispatcher_.trigger<event::quit_game>(42);
            }
        }

      private:
        std::size_t counter{0ull};
    };

    class concrete_world : public world::app
    {
      public:
        concrete_world()
        {
            system_manager_.mark_system<ecs::interpolation_system>();
            system_manager_.start();
            system_manager_.update();
            assert(system_manager_.nb_systems() == 0);
            system_manager_.create_system<concrete_pre_system>();
        }
    };

    TEST_SUITE("world test suite")
    {
        TEST_CASE("empty world")
        {
            empty_concrete_world world;
            CHECK_EQ(world.run(), 0);
        }

        TEST_CASE("concrete world")
        {
            concrete_world world;
            CHECK_EQ(world.run(), 42);
        }
    }
} // namespace antara::gaming::world::tests

REFL_AUTO(type(antara::gaming::world::tests::concrete_pre_system));