//
// Created by Sztergbaum Roman on 12/03/2021.
//

#include "atomicdex/utilities/safe.float.hpp"

t_float_50
safe_float(const std::string& from) noexcept
{
    try
    {
        t_float_50 out(from);
        return out;
    }
    catch (const std::exception& error)
    {
        SPDLOG_ERROR("exception caught when creating a floating point number: {}", error.what());
        return t_float_50(0);
    }
}
