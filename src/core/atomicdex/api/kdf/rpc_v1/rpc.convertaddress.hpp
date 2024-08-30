#pragma once

#include <optional>
#include <string>

//! Deps
#include <nlohmann/json.hpp>

namespace atomic_dex::kdf
{
    struct convert_address_request
    {
        std::string    coin;
        std::string    from; ///< input address
        nlohmann::json to_address_format;
    };

    void to_json(nlohmann::json& j, const convert_address_request& req);

    struct convert_address_answer_success
    {
        std::string address;
    };

    void from_json(const nlohmann::json& j, convert_address_answer_success& answer);

    struct convert_address_answer
    {
        std::optional<convert_address_answer_success> result;
        std::optional<std::string>                    error;
        std::string                                   raw_result;      ///< internal
        int                                           rpc_result_code; ///< internal
    };

    void from_json(const nlohmann::json& j, convert_address_answer& answer);
} // namespace atomic_dex::kdf

namespace atomic_dex
{
    using t_convert_address_request        = kdf::convert_address_request;
    using t_convert_address_answer         = kdf::convert_address_answer;
    using t_convert_address_answer_success = kdf::convert_address_answer_success;
} // namespace atomic_dex