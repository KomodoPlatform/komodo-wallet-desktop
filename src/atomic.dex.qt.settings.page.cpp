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

#include "atomic.dex.qt.settings.page.hpp"

//! Constructo destructor
namespace atomic_dex
{
    settings_page::settings_page(entt::registry& registry, QObject* parent) noexcept : QObject(parent), system(registry) {}
} // namespace atomic_dex

//! Override
namespace atomic_dex
{
    void
    settings_page::update() noexcept
    {
    }
} // namespace atomic_dex