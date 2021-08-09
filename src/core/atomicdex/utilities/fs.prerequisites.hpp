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

#pragma once

//! Global Helpers
#if defined(PREFER_BOOST_FILESYSTEM)
#    include <boost/filesystem.hpp>
namespace fs        = boost::filesystem;
using fs_error_code = boost::system::error_code;
#    define ANTARA_BOOST_FILESYTEM
#else
#    if __has_include(<filesystem>)
#        include <filesystem>
namespace fs        = std::filesystem;
using fs_error_code = std::error_code;
#        define ANTARA_STD_FILESYTEM
#    elif __has_include(<boost/filesystem.hpp>)
#        include <boost/filesystem.hpp>
namespace fs        = boost::filesystem;
using fs_error_code = boost::system::error_code;
#        define ANTARA_BOOST_FILESYTEM
#    endif
#endif

constexpr auto
get_override_options()
{
#if defined(ANTARA_STD_FILESYTEM)
    return fs::copy_options::overwrite_existing;
#elif defined(ANTARA_BOOST_FILESYTEM)
    return fs::copy_options::overwrite_existing;
#endif
}