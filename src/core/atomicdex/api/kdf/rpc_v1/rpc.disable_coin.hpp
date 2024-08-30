#pragma once

#include <optional>
#include <string>

//! JSON FWD
#include <nlohmann/json_fwd.hpp>

namespace atomic_dex::kdf
{
    struct disable_coin_request
    {
        std::string coin;
    };

    void to_json(nlohmann::json& j, const disable_coin_request& req);

    struct disable_coin_answer_success
    {
        std::string coin;
    };

    void from_json(const nlohmann::json& j, disable_coin_answer_success& resp);

    struct disable_coin_answer
    {
        std::optional<std::string>                 error;
        std::optional<disable_coin_answer_success> result;
        int                                        rpc_result_code;
        std::string                                raw_result;
    };

    void from_json(const nlohmann::json& j, disable_coin_answer& resp);
} // namespace atomic_dex::kdf

namespace atomic_dex
{
    using t_disable_coin_request = kdf::disable_coin_request;
    using t_disable_coin_answer = kdf::disable_coin_answer;
}
