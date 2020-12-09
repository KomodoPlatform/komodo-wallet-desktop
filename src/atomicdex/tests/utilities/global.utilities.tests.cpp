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

#include "atomicdex/pch.hpp"

#include <doctest/doctest.h>

#include "atomicdex/utilities/global.utilities.hpp"

using namespace atomic_dex::utils;

TEST_CASE("atomic_dex::utils::get_atomic_dex_data_folder()")
{
    auto result = get_atomic_dex_data_folder();
    CHECK_FALSE(result.string().empty());
}

TEST_CASE("atomic_dex::utils::get_atomic_dex_logs_folder()")
{
    auto result = get_atomic_dex_logs_folder();
    CHECK_FALSE(result.string().empty());
    CHECK(fs::exists(result));
}

TEST_CASE("atomic_dex::utils::get_atomic_dex_current_log_file()")
{
    auto result = get_atomic_dex_current_log_file();
    CHECK_FALSE(result.string().empty());
    CHECK_FALSE(fs::exists(result));
}

TEST_CASE("atomic_dex::utils::adjust_precision()")
{
    CHECK_EQ(adjust_precision("1.0"), "1");
    CHECK_EQ(adjust_precision("1.899999999"), "1.9");
    CHECK_EQ(adjust_precision("1.000000001"), "1");
}

TEST_CASE("atomic_dex::utils::create_if_doesnt_exist()")
{
    fs::path tmp_path = fs::temp_directory_path() / "fake_dir";
    CHECK_FALSE(fs::exists(tmp_path));
    CHECK(create_if_doesnt_exist(tmp_path));
    CHECK(fs::exists(tmp_path));
}

TEST_CASE("atomic_dex::utils::determine_balance_factor()")
{
    CHECK_EQ(doctest::Approx(1.0), determine_balance_factor(false));
    CHECK_NE(doctest::Approx(1.0), determine_balance_factor(true));
}
