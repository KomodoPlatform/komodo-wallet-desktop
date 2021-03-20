#pragma once

//! Project Headers
#include "atomicdex/api/oasis/hashed.time.lock.contract.hpp"
#include "atomicdex/utilities/cpprestsdk.utilities.hpp"

namespace atomic_dex::oasis::api
{
    pplx::task<web::http::http_response> create_htlc(hashed_timed_lock_contract&& htlc_request, bool is_testing = false);
}
