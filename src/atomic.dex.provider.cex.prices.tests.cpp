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

#include "atomic.dex.provider.cex.prices.hpp"
#include <doctest/doctest.h>

TEST_CASE("atomic dex cex prices provider constructor")
{
    entt::registry registry;
    registry.set<entt::dispatcher>();
    atomic_dex::mm2 mm2(registry);
    atomic_dex::cex_prices_provider provider(registry, mm2);
}