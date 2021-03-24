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
#include <functional> ///< std::function
#include <string>     ///< std::string
#include <utility>    ///< std::move

//! Dependencies Headers
#include <entt/entity/registry.hpp> ///< entt::registry

//! SDK Headers
#include "antara/gaming/core/safe.refl.hpp"  ///< REFL_AUTO
#include "antara/gaming/ecs/system.hpp"      ///< ecs::system
#include "antara/gaming/ecs/system.type.hpp" ///< ecs::st_system_logic[pre, post]_update


namespace antara::gaming::ecs
{
    struct ftor
    {
        //! Fields
        std::function<void()> on_create{nullptr};
        std::function<void()> on_update{nullptr};
        std::function<void()> on_destruct{nullptr};
        std::function<void()> on_post_update{nullptr};
    };

    template <typename SystemType>
    class lambda_system final : public ecs::system<lambda_system<SystemType>, SystemType>
    {
        //! Private typedefs
        using TSystem = ecs::system<lambda_system<SystemType>, SystemType>;

        //! Private fields
        ftor        lambda_contents_;
        std::string lambda_name_{""};

      public:
        //! Constructor
        lambda_system(entt::registry& registry, ftor lambda_contents, std::string lambda_name = "") ;

        //! Destructor
        ~lambda_system() ;

        //! Public member functions
        void update()  final;

        void post_update()  final;
    };


} // namespace antara::gaming::ecs

//! Implementation
#include "antara/gaming/ecs/lambda.system.ipp"

namespace antara::gaming::ecs
{
    using lambda_post_system  = lambda_system<ecs::st_system_post_update>;
    using lambda_pre_system   = lambda_system<ecs::st_system_pre_update>;
    using lambda_logic_system = lambda_system<ecs::st_system_logic_update>;
} // namespace antara::gaming::ecs

REFL_AUTO(template((typename SystemType), (antara::gaming::ecs::lambda_system<SystemType>)))
