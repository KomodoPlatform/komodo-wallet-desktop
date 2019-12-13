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

#ifdef ENABLE_CODE_RELOAD_WINDOWS
#define NOMINMAX
#include <Windows.h>
#include "API/LPP_API.h"
#endif
#include "atomic.dex.app.hpp"

int main(int argc, char *argv[])
{
#ifdef ENABLE_CODE_RELOAD_WINDOWS
    HMODULE livePP = lpp::lppLoadAndRegister(L"LivePP", "Quickstart");

    // enable Live++
    lpp::lppEnableAllCallingModulesSync(livePP);

    // enable Live++'s exception handler/error recovery
    lpp::lppInstallExceptionHandler(livePP);
#endif
    (void)argc;
    (void)argv;
    loguru::set_thread_name("main thread");
    atomic_dex::application app;
    return app.run();
}