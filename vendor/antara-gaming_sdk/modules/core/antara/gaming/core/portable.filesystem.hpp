#pragma once

#ifdef __APPLE__
#    include <Availability.h>
#endif

//! Global Helpers
#if defined(PREFER_BOOST_FILESYSTEM)
#    include <boost/filesystem.hpp>
namespace fs = boost::filesystem;
#else
#    if __has_include(<filesystem>)
#        include <filesystem>
namespace fs = std::filesystem;
#    elif __has_include(<boost/filesystem.hpp>)
#        include <boost/filesystem.hpp>
namespace fs = boost::filesystem;
#    endif
#endif