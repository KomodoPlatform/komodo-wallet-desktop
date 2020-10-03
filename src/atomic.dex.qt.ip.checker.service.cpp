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

//! PCH
#include "atomic.dex.pch.hpp"

//! Project headers
#include "atomic.dex.qt.ip.checker.service.hpp"


//! Constructor
namespace atomic_dex
{
    ip_service_checker::ip_service_checker(entt::registry& registry, QObject* parent) : QObject(parent), system(registry) {}
} // namespace atomic_dex

//! Override
namespace atomic_dex
{
    void
    ip_service_checker::update() noexcept
    {
    }

    bool
    ip_service_checker::is_my_ip_authorized() const noexcept
    {
        return m_external_ip_authorized.load();
    }
} // namespace atomic_dex