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

//! Deps
#include <antara/gaming/world/world.app.hpp>
#include <folly/init/Init.h>

//! Project
#include "atomicdex/services/mm2/mm2.service.hpp"
#include "atomicdex/managers/qt.wallet.manager.hpp"

struct tests_context : public antara::gaming::world::app
{
    tests_context(char** argv)
    {
#ifdef BOOST_OS_LINUX
        int realargs = 1; // workaround to ignore doct
        folly::init(&realargs, &argv, false);
#endif

        //! Creates mm2 service.
        const auto& mm2 = system_manager_.create_system<atomic_dex::mm2_service>(system_manager_);
        
        //! Creates special wallet for the unit tests then logs to it.
        auto& wallet_manager = system_manager_.create_system<atomic_dex::qt_wallet_manager>(system_manager_);
        wallet_manager.create("atomicdex-desktop_tests", "asdkl lkdsa", "atomicdex-desktop_tests");
        wallet_manager.login("atomicdex-desktop_tests", "atomicdex-desktop_tests");
    
        //! Waits for mm2 to be initialized before running tests
        while (!mm2.is_mm2_running())
        {
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
    }

    antara::gaming::ecs::system_manager& system_manager() noexcept
    {
        return system_manager_;
    }
};

extern std::unique_ptr<tests_context> g_context;