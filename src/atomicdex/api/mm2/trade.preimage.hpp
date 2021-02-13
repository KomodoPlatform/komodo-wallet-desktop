#pragma once

//! STD
#include <optional>
#include <string>

//! Deps
#include <entt/core/attribute.h>
#include <nlohmann/json_fwd.hpp>

//! Project Headers
#include "atomicdex/api/mm2/fraction.hpp"

namespace mm2::api
{
    struct trade_preimage_request
    {
        std::string         base_coin;
        std::string         rel_coin;
        std::string         swap_method;
        std::string         volume;
        std::optional<bool> max;
    };

    ENTT_API void to_json(nlohmann::json& j, const trade_preimage_request& request);

    struct coin_fee
    {
        std::string coin;
        std::string amount;
        fraction    amount_fraction;
    };

    struct trade_preimage_answer_success
    {
        coin_fee base_coin_fee;
        coin_fee rel_coin_fee;
    };

    struct trade_preimage_answer
    {
        std::optional<trade_preimage_answer_success> result;
        std::optional<std::string>                   error;
        int                                          rpc_result_code;
        std::string                                  raw_result;
    };
} // namespace mm2::api

namespace atomic_dex
{
    using t_trade_preimage_request = ::mm2::api::trade_preimage_request;
}