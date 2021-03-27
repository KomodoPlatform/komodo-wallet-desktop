#pragma once

#include <optional>
#include <string>

//! Deps
#include <nlohmann/json_fwd.hpp>

namespace mm2::api
{
    struct recover_funds_of_swap_request
    {
        std::string swap_uuid;
    };

    void to_json(nlohmann::json& j, const recover_funds_of_swap_request& cfg);

    struct recover_funds_of_swap_answer_success
    {
        std::string action;
        std::string coin;
        std::string tx_hash;
        std::string tx_hex;
    };

    void from_json(const nlohmann::json& j, recover_funds_of_swap_answer_success& answer);

    struct recover_funds_of_swap_answer
    {
        std::optional<std::string>                          error;
        std::optional<recover_funds_of_swap_answer_success> result;
        int                                                 rpc_result_code;
        std::string                                         raw_result;
    };

    void from_json(const nlohmann::json& j, recover_funds_of_swap_answer& answer);
} // namespace mm2::api

namespace atomic_dex
{
    using t_recover_funds_of_swap_request = ::mm2::api::recover_funds_of_swap_request;
    using t_recover_funds_of_swap_answer  = ::mm2::api::recover_funds_of_swap_answer;
} // namespace atomic_dex