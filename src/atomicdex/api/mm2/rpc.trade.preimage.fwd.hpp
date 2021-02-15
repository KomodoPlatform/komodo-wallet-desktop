#pragma once

namespace mm2::api
{
    struct trade_preimage_request;
    struct trade_preimage_answer;
} // namespace mm2::api

namespace atomic_dex
{
    using t_trade_preimage_answer = ::mm2::api::trade_preimage_answer;
}