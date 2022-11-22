/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
 *                                                                            *
 * See the AUTHORS, DEVELOPER-AGREEMENT and LICENSE files at                  *
 * the top-level directory of this distribution for the individual copyright  *
 * holder information and the developer policies on copyright and licensing.  *
 *                                                                            *
 * Unless otherwise agreed in a custom licensing agreement, no part of the    *
 * Komodo Platform software, including this file may be copied, modified,     *
 * propagated or distributed except according to the terms contained in the   *
 * LICENSE file                                                               *
 *                                                                            *
 * Removal or modification of this copyright notice is prohibited.            *
 *                                                                            *
 ******************************************************************************/

#pragma once

//! STD
#include <optional>
#include <string>

//! Deps
#include <nlohmann/json_fwd.hpp>

//! Project Header
#include <atomicdex/api/mm2/trading.order.contents.hpp>

namespace atomic_dex::mm2
{
    struct buy_request
    {
        std::string                base;
        std::string                rel;
        std::string                price;
        std::string                volume;
        bool                       is_created_order;
        std::string                price_denom;
        std::string                price_numer;
        std::string                volume_denom;
        std::string                volume_numer;
        bool                       is_exact_selected_order_volume;
        bool                       selected_order_use_input_volume{false};
        std::optional<bool>        base_nota{std::nullopt};
        std::optional<std::size_t> base_confs{std::nullopt};
        std::optional<std::string> min_volume{std::nullopt};
    };

    void to_json(nlohmann::json& j, const buy_request& request);

    struct buy_answer_success
    {
        trading_order_contents contents;
    };

    void from_json(const nlohmann::json& j, buy_answer_success& contents);

    struct buy_answer
    {
        std::optional<std::string>        error;
        std::optional<buy_answer_success> result;
        int                               rpc_result_code;
        std::string                       raw_result;
    };

    void from_json(const nlohmann::json& j, buy_answer& answer);
} // namespace atomic_dex::mm2

namespace atomic_dex
{
    using t_buy_request        = mm2::buy_request;
    using t_buy_answer         = mm2::buy_answer;
    using t_buy_answer_success = mm2::buy_answer_success;
} // namespace atomic_dex