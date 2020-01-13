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

#include <QObject>

//! PCH Headers
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"

namespace ag = antara::gaming;

namespace atomic_dex
{
    struct application : public QObject, public ag::world::app
    {
        Q_OBJECT
      public:
        explicit application(QObject* pParent = nullptr) noexcept;

        mm2&                  get_mm2() noexcept;
        coinpaprika_provider& get_paprika() noexcept;
        entt::dispatcher&     get_dispatcher() noexcept;

        void launch();

        Q_INVOKABLE QString get_mnemonic();
        Q_INVOKABLE bool first_run();

      private:
        void tick();
    };
} // namespace atomic_dex
