//
// Created by Sztergbaum Roman on 12/03/2021.
//

#if defined(linux) || defined(__APPLE__)
#    define BOOST_STACKTRACE_USE_ADDR2LINE
#    if defined(__APPLE__)
#        define _GNU_SOURCE
#    endif
#    include <boost/stacktrace.hpp>
#endif

#include <boost/algorithm/string/replace.hpp>

#include "atomicdex/utilities/safe.float.hpp"

t_float_50
safe_float(const std::string& from) 
{
    try
    {
        t_float_50 out(boost::algorithm::replace_all_copy(from, ",", "."));
        return out;
    }
    catch (const std::exception& error)
    {
        SPDLOG_ERROR("exception caught when creating a floating point number: {}", error.what());
//#if defined(linux) || defined(__APPLE__)
//        SPDLOG_ERROR("stacktrace: {}", boost::stacktrace::to_string(boost::stacktrace::stacktrace()));
//#endif
        return t_float_50(0);
    }
}
