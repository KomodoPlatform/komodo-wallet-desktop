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

#define DOCTEST_CONFIG_IMPLEMENT
#include <doctest/doctest.h>

#include "atomic.dex.tests.hpp"

std::unique_ptr<tests_context> g_context{nullptr};

int main(int argc, char** argv)
{
    doctest::Context context;

    context.applyCommandLine(argc, argv);

    g_context = std::make_unique<tests_context>(argv);
    
    int res = context.run();
    
    if (context.shouldExit()) // important - query flags (and --exit) rely on the user doing this
    {
        return res; // propagate the result of the tests
    }

    return res; // the result from doctest is propagated here as well
}