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

#include "atomicdex/pch.hpp"

#include <doctest/doctest.h>

#include "atomicdex/utilities/global.utilities.hpp"
#include "atomicdex/utilities/safe.float.hpp"
#include "atomicdex/utilities/security.utilities.hpp"

using namespace atomic_dex::utils;

#if !defined(WIN32) && !defined(_WIN32)
TEST_CASE("atomic_dex::utils::get_atomic_dex_data_folder()")
{
    auto result = get_atomic_dex_data_folder();
    CHECK_FALSE(result.string().empty());
}

TEST_CASE("atomic_dex::utils::get_atomic_dex_logs_folder()")
{
    auto result = get_atomic_dex_logs_folder();
    CHECK_FALSE(result.string().empty());
    CHECK(std::filesystem::exists(result));
}

TEST_CASE("atomic_dex::utils::get_atomic_dex_current_log_file()")
{
    auto result = get_atomic_dex_current_log_file();
    CHECK_FALSE(result.string().empty());
    CHECK_FALSE(std::filesystem::exists(result));
}

TEST_CASE("atomic_dex::utils::adjust_precision()")
{
    CHECK_EQ(adjust_precision("1.0"), "1");
    CHECK_EQ(adjust_precision("1.899999999"), "1.9");
    CHECK_EQ(adjust_precision("1.000000001"), "1");
}

TEST_CASE("atomic_dex::utils::create_if_doesnt_exist()")
{
    std::filesystem::path tmp_path = std::filesystem::temp_directory_path() / "fake_dir";
    CHECK_FALSE(std::filesystem::exists(tmp_path));
    CHECK(create_if_doesnt_exist(tmp_path));
    CHECK(std::filesystem::exists(tmp_path));
    std::filesystem::remove(tmp_path);
    CHECK_FALSE(std::filesystem::exists(tmp_path));
}

TEST_CASE("atomic_dex::utils::determine_balance_factor()")
{
    CHECK_EQ(doctest::Approx(1.0), determine_balance_factor(false));
    CHECK_NE(doctest::Approx(1.0), determine_balance_factor(true));
}

TEST_CASE("atomic_dex::::utils::to_human_date()")
{
    using namespace std::chrono;
    std::size_t timestamp  = 1607585590;
    std::string human_date = to_human_date<std::chrono::seconds>(timestamp, "%e %b %Y, %H:%M");
    CHECK(!human_date.empty());
    // CHECK_EQ("10 Dec 2020, 08:33", human_date);
}

TEST_CASE("atomic_dex::utils::get_atomic_dex_addressbook_folder()")
{
    auto result = get_atomic_dex_addressbook_folder();
    CHECK_FALSE(result.string().empty());
    CHECK(std::filesystem::exists(result));
}

TEST_CASE("atomic_dex::utils::get_runtime_coins_path()")
{
    auto result = get_runtime_coins_path();
    CHECK_FALSE(result.string().empty());
    CHECK(std::filesystem::exists(result));
}

TEST_CASE("atomic_dex::utils::get_current_configs_path()")
{
    auto result = get_current_configs_path();
    CHECK_FALSE(result.string().empty());
    CHECK(std::filesystem::exists(result));
}

TEST_CASE("atomic_dex::utils::retrieve_main_ticker()")
{
    CHECK_EQ(atomic_dex::utils::retrieve_main_ticker("BUSD"), "BUSD");
    CHECK_EQ(atomic_dex::utils::retrieve_main_ticker("BUSD-BEP2"), "BUSD");
    CHECK_EQ(atomic_dex::utils::retrieve_main_ticker("BUSD-ERC20"), "BUSD");
}

TEST_CASE("extract_large_float")
{
    CHECK_EQ("12504.71255285", atomic_dex::utils::extract_large_float("12504.712552852304076"));
    CHECK_EQ("1.1", atomic_dex::utils::extract_large_float("1.1"));
}

TEST_CASE("generate_random_password")
{
    for (int i = 0; i < 10; ++i) { CHECK_EQ(atomic_dex::is_valid_generated_rpc_password(atomic_dex::gen_random_password()), true); }
}

/*TEST_CASE("u8string")
{
    using namespace std::string_literals;
    std::wstring other_path = L"C:\\Users\\Антон\\AppData\\Roaming\\atomic_qt\\0.4.3\\configs\\coins.json"s;
    std::filesystem::path cur_path = other_path;
    CHECK_EQ(u8string(other_path), "C:\\Users\\Антон\\AppData\\Roaming\\atomic_qt\\0.4.3\\configs\\coins.json"s);
    CHECK_EQ(u8string(cur_path), "C:\\Users\\Антон\\AppData\\Roaming\\atomic_qt\\0.4.3\\configs\\coins.json"s);
    CHECK_EQ(to_utf8(cur_path.wstring().c_str()), "C:\\Users\\Антон\\AppData\\Roaming\\atomic_qt\\0.4.3\\configs\\coins.json"s);
}*/

#endif
