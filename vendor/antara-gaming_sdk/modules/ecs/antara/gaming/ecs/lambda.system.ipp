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

namespace antara::gaming::ecs
{
    template <typename SystemType>
    lambda_system<SystemType>::lambda_system(entt::registry& registry, ftor lambda_contents, std::string lambda_name)  :
        TSystem::system(registry), lambda_contents_(std::move(lambda_contents)), lambda_name_(std::move(lambda_name))
    {
        if (lambda_contents_.on_create != nullptr)
        {
            lambda_contents_.on_create();
        }
    }

    template <typename SystemType>
    lambda_system<SystemType>::~lambda_system() 
    {
        if (lambda_contents_.on_destruct != nullptr)
        {
            lambda_contents_.on_destruct();
        }
    }

    template <typename SystemType>
    void
    lambda_system<SystemType>::update() 
    {
        if (lambda_contents_.on_update != nullptr)
        {
            lambda_contents_.on_update();
        }
    }

    template <typename SystemType>
    void
    lambda_system<SystemType>::post_update() 
    {
        if (lambda_contents_.on_post_update != nullptr)
        {
            lambda_contents_.on_post_update();
        }
    }
} // namespace antara::gaming::ecs