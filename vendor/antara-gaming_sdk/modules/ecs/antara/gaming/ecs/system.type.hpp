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

//! Dependencies Headers
#include <st/type.hpp>

namespace antara::gaming::ecs
{
    /**
     * @brief Enumeration that represents all possible system types in sdk gaming.
     */
    enum system_type
    {
        pre_update,   ///< Represents a pre_update system
        logic_update, ///< Represents a logic system
        post_update,  ///< Represents a post_update system
        size          ///< Represents the size of the enum
    };

    /// @brief strong_type relative to system_type::pre_update
    using st_system_pre_update = st::type<system_type, struct system_pre_update_tag>;

    /// @brief strong_type relative to system_type::logic_update
    using st_system_logic_update = st::type<system_type, struct system_logic_update_tag>;

    /// @brief strong_type relative to system_type::post_update
    using st_system_post_update = st::type<system_type, struct system_post_update_tag>;
} // namespace antara::gaming::ecs