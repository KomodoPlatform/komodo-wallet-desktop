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

//! Project Headers
#include "atomic.dex.app.hpp"
//#include "atomic.dex.gui.hpp"
//#include "atomic.dex.gui.v2.hpp"
#include "atomic.dex.mm2.hpp"
//#include "atomic.dex.provider.coinpaprika.hpp"

namespace atomic_dex
{
    void
    application::launch()
    {
        tick_next();
    }

    void
    application::tick_next()
    {
        // Trigger the tick() invokation when the event loop runs next time
        QMetaObject::invokeMethod(this, "tick", Qt::QueuedConnection);
    }

    void
    application::tick()
    {
        this->process_one_frame();
        tick_next();
    }

    application::application(QObject* pParent) noexcept : QObject(pParent)
    {
        //! MM2 system need to be created before the GUI and give the instance to the gui
        auto& mm2_system = system_manager_.create_system<mm2>();
        // auto& paprika_system = system_manager_.create_system<coinpaprika_provider>(mm2_system);
    }
} // namespace atomic_dex
