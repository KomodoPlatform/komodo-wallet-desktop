#pragma once

//! STD
#include <optional>
#include <string>

//! Deps
#include <nlohmann/json_fwd.hpp>

namespace mm2::api
{
    struct max_taker_vol_request
    {
        std::string                coin;
        std::optional<std::string> trade_with;
    };

    void to_json(nlohmann::json& j, const max_taker_vol_request& cfg);

    struct max_taker_vol_answer_success
    {
        std::string denom;
        std::string numer;
        std::string decimal;
    };

    void from_json(const nlohmann::json& j, max_taker_vol_answer_success& cfg);

    struct max_taker_vol_answer
    {
        std::optional<max_taker_vol_answer_success> result;
        std::optional<std::string>                  error;
        int                                         rpc_result_code;
        std::string                                 raw_result;
    };

    void from_json(const nlohmann::json& j, max_taker_vol_answer& answer);
} // namespace mm2::api

namespace atomic_dex
{
    using t_max_taker_vol_request        = ::mm2::api::max_taker_vol_request;
    using t_max_taker_vol_answer         = ::mm2::api::max_taker_vol_answer;
    using t_max_taker_vol_answer_success = ::mm2::api::max_taker_vol_answer_success;
} // namespace atomic_dex