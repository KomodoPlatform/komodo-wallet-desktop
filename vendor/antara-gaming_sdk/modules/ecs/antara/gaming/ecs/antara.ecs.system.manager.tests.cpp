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

#include "antara/gaming/ecs/lambda.system.hpp"
#include "antara/gaming/ecs/system.hpp"
#include "antara/gaming/ecs/system.manager.hpp"
#include <doctest/doctest.h>

class logic_concrete_system final : public antara::gaming::ecs::logic_update_system<logic_concrete_system>
{
  public:
    logic_concrete_system(entt::registry& registry) : system(registry)
    {
    }

    logic_concrete_system() = default;

    void
    update()  final
    {
    }

    ~logic_concrete_system()  final = default;
};

class pre_concrete_system final : public antara::gaming::ecs::pre_update_system<pre_concrete_system>
{
  public:
    pre_concrete_system(entt::registry& registry)  : system(registry)
    {
    }


    void
    update()  final
    {
    }

    ~pre_concrete_system()  final = default;
};

REFL_AUTO(type(logic_concrete_system))
REFL_AUTO(type(pre_concrete_system))

namespace antara::gaming::ecs::tests
{
    TEST_CASE("add system")
    {
        entt::registry    registry;
        entt::dispatcher& dispatcher{registry.set<entt::dispatcher>()};
        static_cast<void>(dispatcher);
        system_manager        manager{registry};
        const system_manager& c_mgr = manager;
        manager.start();

        //! add
        CHECK_EQ(manager.nb_systems(), 1u);
        manager.create_system<logic_concrete_system>();
        CHECK(manager.has_system<logic_concrete_system>());
        CHECK_EQ(manager.nb_systems(), 2u);
        CHECK_EQ(manager.nb_systems(logic_concrete_system::get_system_type()), 2u);
        manager.create_system<logic_concrete_system>();
        CHECK_EQ(manager.nb_systems(), 2u);
        CHECK_EQ(manager.nb_systems(logic_concrete_system::get_system_type()), 2u);

        //! evt
        ecs::event::add_base_system evt(std::make_unique<pre_concrete_system>(registry));
        manager.receive_add_base_system(evt);
        manager.update();
        CHECK_EQ(manager.nb_systems(), 3u);
        CHECK(manager.mark_system<pre_concrete_system>());
        manager.update();
        CHECK_EQ(manager.nb_systems(), 2u);

        manager.create_system_rt<pre_concrete_system>();
        CHECK_EQ(manager.nb_systems(), 2u);
        manager.update();
        CHECK_EQ(manager.nb_systems(), 3u);
        CHECK(manager.mark_system<pre_concrete_system>());
        manager.update();
        CHECK_EQ(manager.nb_systems(), 2u);


        //! remove
        CHECK_EQ(manager.nb_systems(), 2u);
        CHECK(manager.mark_system<logic_concrete_system>());
        manager.update();
        CHECK_FALSE(manager.has_system<logic_concrete_system>());
        CHECK_EQ(manager.nb_systems(), 1u);
        CHECK_FALSE(manager.mark_system<logic_concrete_system>());


        //! add multiple
        manager.load_systems<logic_concrete_system, pre_concrete_system>();
        CHECK_EQ(manager.nb_systems(), 3u);
        CHECK(manager.has_systems<logic_concrete_system, pre_concrete_system>());

        //! update/enable/disable systems from specific type
        CHECK_EQ(manager.update_systems(pre_update), 1ull);
        CHECK(manager.disable_system<pre_concrete_system>());
        CHECK_EQ(manager.update_systems(pre_update), 0ull);
        CHECK(manager.enable_system<pre_concrete_system>());

        CHECK(manager.disable_systems<logic_concrete_system, pre_concrete_system>());
        CHECK_GE(manager.update(), 0ull);
        CHECK(manager.enable_systems<logic_concrete_system, pre_concrete_system>());
        CHECK_GE(manager.update(), 1ull);

        //! get single
        auto& logic_system = manager.get_system<logic_concrete_system>();

        const auto& c_logic_system = c_mgr.get_system<logic_concrete_system>();
        CHECK_EQ(logic_system.get_name(), "logic_concrete_system");
        CHECK_EQ(c_logic_system.get_name(), "logic_concrete_system");

        //! get multiple
        auto&& [lgc_sys, pre_sys] = manager.get_systems<logic_concrete_system, pre_concrete_system>();
        CHECK_EQ(lgc_sys.get_name(), "logic_concrete_system");
        CHECK_EQ(pre_sys.get_name(), "pre_concrete_system");

        auto&& [c_lgc_sys, c_pre_sys] = c_mgr.get_systems<logic_concrete_system, pre_concrete_system>();
        CHECK_EQ(c_lgc_sys.get_name(), "logic_concrete_system");
        CHECK_EQ(c_pre_sys.get_name(), "pre_concrete_system");

        //! marked multiple
        CHECK(manager.has_systems<logic_concrete_system, pre_concrete_system>());
        CHECK(manager.mark_systems<logic_concrete_system, pre_concrete_system>());
        manager.update();
        CHECK_FALSE(manager.has_systems<logic_concrete_system, pre_concrete_system>());
        CHECK_FALSE(manager.enable_systems<logic_concrete_system, pre_concrete_system>());
        CHECK_FALSE(manager.disable_systems<logic_concrete_system, pre_concrete_system>());
        CHECK_GE(manager.update(), 0ull);
        CHECK_EQ(1ull, manager.nb_systems());

        manager += std::make_unique<lambda_pre_system>(
            registry, ecs::ftor{.on_post_update =
                                    []() {
                                    },
                                .on_destruct =
                                    []() {
                                    },
                                .on_create =
                                    []() {
                                    },
                                .on_update =
                                    []() {
                                    }});
        CHECK_GE(manager.update(), 1ull);
        CHECK_EQ(2ull, manager.nb_systems());
    }
} // namespace antara::gaming::ecs::tests