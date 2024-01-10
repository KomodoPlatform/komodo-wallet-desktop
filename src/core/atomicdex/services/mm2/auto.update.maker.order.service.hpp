/******************************************************************************
 * Copyright © 2013-2024 The Komodo Platform Developers.                      *
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

//! Deps
#include <antara/gaming/ecs/system.manager.hpp>
#include <boost/thread/synchronized_value.hpp>
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/data/dex/qt.orders.data.hpp"
#include "atomicdex/utilities/safe.float.hpp"

//! Namespace declaration
namespace atomic_dex
{
    //! Class declaration
    class auto_update_maker_order_service final : public ag::ecs::pre_update_system<auto_update_maker_order_service>
    {
        //! Private typedefs
        using t_update_time_point = std::chrono::high_resolution_clock::time_point;

        //! Private member fields
        ag::ecs::system_manager& m_system_manager;
        t_update_time_point      m_update_clock;

        //! Private member functions
        void        process_update_orders();
        void        internal_update();
        void        update_order(const t_order_swaps_data& data);
        std::string get_new_price_from_order(const t_order_swaps_data& data, const t_float_50& spread);

      public:
        //! Constructor
        explicit auto_update_maker_order_service(entt::registry& registry, ag::ecs::system_manager& system_manager);

        //! Destructor
        ~auto_update_maker_order_service() final = default;

        //! Public override
        void update() final;

        void force_update();
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::auto_update_maker_order_service))
