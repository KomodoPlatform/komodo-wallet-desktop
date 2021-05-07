#pragma once

//! Project headers
#include "atomicdex/utilities/cpprestsdk.utilities.hpp"

namespace atomic_dex::checksum::api
{
    // Returns the checksum of the latest
    [[nodiscard]] pplx::task<std::string>
    get_latest_checksum();
}