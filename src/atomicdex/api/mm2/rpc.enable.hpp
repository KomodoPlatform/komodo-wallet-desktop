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

//! Deps
#include <nlohmann/json_fwd.hpp>

//! Project Headers
#include "atomicdex/constants/qt.coins.enums.hpp"

namespace mm2::api
{
    //! Only for erc 20
    struct enable_request
    {
        std::string              coin_name;
        std::vector<std::string> urls;
        CoinType                 coin_type;
        const std::string        erc_swap_contract_address{"0x8500AFc0bc5214728082163326C2FF0C73f4a871"};
        std::string              gas_station_url{"https://ethgasstation.info/json/ethgasAPI.json"};
        std::string              type; ///< QRC-20 ?
        bool                     with_tx_history{true};
    };

    void to_json(nlohmann::json& j, const enable_request& cfg);

    struct enable_answer
    {
        std::string address;
        std::string balance;
        std::string result;
        std::string raw_result;
        int         rpc_result_code;
    };

    void from_json(const nlohmann::json& j, const enable_answer& cfg);
} // namespace mm2::api

namespace atomic_dex
{
    using t_enable_request = ::mm2::api::enable_request;
    using t_enable_answer  = ::mm2::api::enable_answer;
} // namespace atomic_dex