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
#include <string>

#include "antara/gaming/core/safe.refl.hpp"
#include "antara/gaming/ecs/base.system.hpp"
#include "antara/gaming/ecs/lambda.system.hpp"
#include "antara/gaming/ecs/system.hpp"
#include "antara/gaming/ecs/virtual.input.system.hpp"

namespace antara::gaming::ecs::tests
{
    class logic_concrete_system final : public logic_update_system<logic_concrete_system>
    {
      public:
        logic_concrete_system(entt::registry& registry) : system(registry)
        {
        }

        void
        update()  final
        {
        }

        ~logic_concrete_system()  final = default;
    };

    class pre_concrete_system final : public pre_update_system<pre_concrete_system>
    {
      public:
        pre_concrete_system(entt::registry& registry) : system(registry)
        {
        }

        void
        update()  final
        {
        }

        ~pre_concrete_system()  final = default;
    };

    class post_concrete_system final : public post_update_system<post_concrete_system>
    {
      public:
        post_concrete_system(entt::registry& registry) : system(registry)
        {
        }

        void
        update()  final
        {
        }

        ~post_concrete_system()  final = default;
    };

    TEST_SUITE("antara-gaming ecs test suite")
    {
        TEST_CASE("base system abstract object tests")
        {
            struct concrete_system final : base_system
            {
                concrete_system(entt::registry& registry) : base_system(registry)
                {
                }

                [[nodiscard]] system_type
                get_system_type_rtti() const  final
                {
                    return logic_update;
                }

                void
                update()  final
                {
                    //!
                }

                [[nodiscard]] std::string
                get_name() const  final
                {
                    return "concrete_system";
                }

                ~concrete_system()  final = default;
            };

            entt::registry registry{};
            registry.set<entt::dispatcher>();
            concrete_system dummy_system{registry};
            SUBCASE("get system type rtti from a system")
            {
                CHECK_EQ(dummy_system.get_system_type_rtti(), logic_update);
            }
            SUBCASE("mark/unmark a system")
            {
                dummy_system.mark();
                CHECK(dummy_system.is_marked());
                dummy_system.unmark();
                CHECK_FALSE(dummy_system.is_marked());
            }

            SUBCASE("enable/disable a system")
            {
                dummy_system.enable();
                CHECK(dummy_system.is_enabled());
                dummy_system.disable();
                CHECK_FALSE(dummy_system.is_enabled());
            }

            SUBCASE("dummy update")
            {
                dummy_system.update();
            }

            SUBCASE("im a plugin / im not a plugin system")
            {
                CHECK_FALSE(dummy_system.is_a_plugin());
                dummy_system.im_a_plugin();
                CHECK(dummy_system.is_a_plugin());
            }

            SUBCASE("set_user_data")
            {
                auto dummy_value = 42;
                dummy_system.set_user_data(&dummy_value);
                auto data = dummy_system.get_user_data();
                CHECK_EQ(*static_cast<int*>(data), 42);
            }

            SUBCASE("check class name")
            {
                CHECK_EQ("concrete_system", dummy_system.get_name());
            }
        }

        TEST_CASE("system tests")
        {
            entt::registry registry;
            registry.set<entt::dispatcher>();
            logic_concrete_system dummy_system{registry};
            pre_concrete_system   pre_dummy_system{registry};
            post_concrete_system  post_dummy_system{registry};

            SUBCASE("mark/unmark a system")
            {
                dummy_system.mark();
                CHECK(dummy_system.is_marked());
                dummy_system.unmark();
                CHECK_FALSE(dummy_system.is_marked());
            }

            SUBCASE("enable/disable a system")
            {
                dummy_system.enable();
                CHECK(dummy_system.is_enabled());
                dummy_system.disable();
                CHECK_FALSE(dummy_system.is_enabled());
            }

            SUBCASE("dummy update")
            {
                dummy_system.update();
            }

            SUBCASE("im a plugin / im not a plugin system")
            {
                CHECK_FALSE(dummy_system.is_a_plugin());
                dummy_system.im_a_plugin();
                CHECK(dummy_system.is_a_plugin());
            }

            SUBCASE("set_user_data")
            {
                auto dummy_value = 42;
                dummy_system.set_user_data(&dummy_value);
                auto data = dummy_system.get_user_data();
                CHECK_EQ(*static_cast<int*>(data), 42);
            }

            SUBCASE("get system type compile time or runtime")
            {
                CHECK_EQ(dummy_system.get_system_type(), logic_update);
                CHECK_EQ(dummy_system.get_system_type_rtti(), logic_update);
                CHECK_EQ(logic_concrete_system::get_system_type(), logic_update);

                CHECK_EQ(pre_dummy_system.get_system_type(), pre_update);
                CHECK_EQ(pre_dummy_system.get_system_type_rtti(), pre_update);
                CHECK_EQ(pre_concrete_system::get_system_type(), pre_update);


                CHECK_EQ(post_dummy_system.get_system_type(), post_update);
                CHECK_EQ(post_dummy_system.get_system_type_rtti(), post_update);
                CHECK_EQ(post_concrete_system::get_system_type(), post_update);
            }

            SUBCASE("update system")
            {
                dummy_system.update();
                pre_dummy_system.update();
                post_dummy_system.update();
            }

            SUBCASE("system name")
            {
                CHECK_EQ(dummy_system.get_name(), "antara::gaming::ecs::tests::logic_concrete_system");
            }
        }
    }

    TEST_CASE("virtual input")
    {
        entt::registry registry;
        registry.set<entt::dispatcher>();
        ecs::virtual_input_system system{registry};
        system.update();
    }

    TEST_CASE("lambda_system")
    {
        entt::registry registry;
        registry.set<entt::dispatcher>();
        ecs::lambda_logic_system system{registry, ecs::ftor{.on_post_update =
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
                                                                }}};
        system.update();
    }
} // namespace antara::gaming::ecs::tests

REFL_AUTO(type(antara::gaming::ecs::tests::logic_concrete_system))
REFL_AUTO(type(antara::gaming::ecs::tests::post_concrete_system))
REFL_AUTO(type(antara::gaming::ecs::tests::pre_concrete_system))