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
#include <meta/sequence/flatten.hpp> ///< doom::meta::flatten
#include <meta/sequence/list.hpp>    ///< doom::meta::list

//! SDK Headers
#include "antara/gaming/geometry/all.geometry.components.hpp"   ///< geometry::components_list
#include "antara/gaming/graphics/all.graphics.components.hpp"   ///< graphics::components_list
#include "antara/gaming/transform/all.transform.components.hpp" ///< transform::components_list

namespace antara::gaming::ecs::component
{
    using list_component_list = doom::meta::list<math::vector_type_list, transform::components_list, geometry::components_list, graphics::components_list>;
    using components_list     = doom::meta::flatten<list_component_list>;
} // namespace antara::gaming::ecs::component