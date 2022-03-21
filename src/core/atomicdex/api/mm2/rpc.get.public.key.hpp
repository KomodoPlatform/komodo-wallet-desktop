/******************************************************************************
 * Copyright © 2013-2022 The Komodo Platform Developers.                      *
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

// Std Headers
#include <string>

// Deps Headers
#include <nlohmann/json_fwd.hpp>

namespace atomic_dex::mm2
{
    struct get_public_key
    {
        static constexpr auto endpoint = "get_public_key";
        static constexpr bool is_v2     = true;
        struct expected_request_type
        {

        } request;
        struct expected_answer_type
        {
            std::string public_key;
        } answer;
    };
    using get_public_key_request = get_public_key::expected_request_type;
    using get_public_key_answer = get_public_key::expected_answer_type;

    inline void to_json([[maybe_unused]] nlohmann::json& j, const get_public_key_request&) { }
    void from_json(const nlohmann::json& json, get_public_key_answer& in);
}