#pragma once

namespace antara::app
{
    enum class http_code
    {
        ok                = 200,
        bad_request       = 400,
        too_many_requests = 429
    };
}