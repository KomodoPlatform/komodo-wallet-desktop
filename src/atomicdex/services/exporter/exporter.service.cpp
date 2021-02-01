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

#include "atomicdex/services/exporter/exporter.service.hpp"

//! Constructor
namespace atomic_dex
{
    exporter_service::exporter_service(entt::registry& registry, QObject* parent) : QObject(parent), system(registry)
    {
        //! Event driven system
        this->disable();
    }
} // namespace atomic_dex

//! Public override
namespace atomic_dex
{
    void
    exporter_service::update() noexcept
    {
    }
} // namespace atomic_dex