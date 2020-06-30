/******************************************************************************
 * Copyright © 2013-2019 The Komodo Platform Developers.                      *
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

#include "atomic.dex.pch.hpp"

//! Project header
#include "atomic.dex.mm2.hpp"

namespace atomic_dex
{
    namespace ag = antara::gaming;

    class cex_prices_provider final : public ag::ecs::pre_update_system<cex_prices_provider>
    {
        //! Private fields
        mm2& m_mm2_instance;

      public:
        //! Constructor
        cex_prices_provider(entt::registry& registry, mm2& mm2_instance);

        // Override
        void update() noexcept override;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::cex_prices_provider))