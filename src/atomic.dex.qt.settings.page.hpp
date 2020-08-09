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

//! QT
#include <QObject>

//! PCH
#include "atomic.dex.pch.hpp"

namespace atomic_dex
{
    class settings_page final : public QObject, public ag::ecs::pre_update_system<settings_page>
    {
        //! Q_Object definition
        Q_OBJECT

      public:
        explicit settings_page(entt::registry& registry, QObject* parent = nullptr) noexcept;
        ~settings_page() noexcept final = default;

        //! Public override
        void update() noexcept final;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::settings_page))