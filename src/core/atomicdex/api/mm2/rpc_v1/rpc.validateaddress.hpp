#pragma once

#include <optional>
#include <string>

//! Deps
#include <nlohmann/json_fwd.hpp>

namespace atomic_dex::mm2
{
    struct validate_address_request
    {
        std::string coin;
        std::string address;
    };

    void to_json(nlohmann::json& j, const validate_address_request& req);

    struct validate_address_answer_success
    {
        bool                       is_valid;
        std::optional<std::string> reason;
    };

    void from_json(const nlohmann::json& j, validate_address_answer_success& answer);

    struct validate_address_answer
    {
        std::optional<validate_address_answer_success> result;
        std::optional<std::string>                     error;
        std::string                                    raw_result;      ///< internal
        int                                            rpc_result_code; ///< internal
    };

    void from_json(const nlohmann::json& j, validate_address_answer& answer);
} // namespace atomic_dex::mm2

namespace atomic_dex
{
    using t_validate_address_request        = mm2::validate_address_request;
    using t_validate_address_answer         = mm2::validate_address_answer;
    using t_validate_address_answer_success = mm2::validate_address_answer_success;
} // namespace atomic_dex