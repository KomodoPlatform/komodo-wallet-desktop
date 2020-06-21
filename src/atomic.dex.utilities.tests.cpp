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

#include <doctest/doctest.h>
#include "atomic.dex.utilities.hpp"

TEST_CASE("AtomicDex Pro get_atomic_dex_data_folder")
{
    CHECK_FALSE(get_atomic_dex_data_folder().string().empty());
}

TEST_CASE("AtomicDex Pro get_atomic_dex_logs_folder()")
{
    CHECK_FALSE(get_atomic_dex_logs_folder().string().empty());
}