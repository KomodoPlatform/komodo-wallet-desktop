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
        bool                     is_testnet{false};
        const std::string        erc_swap_contract_address{"0x24ABE4c71FC658C91313b6552cd40cD808b3Ea80"};
        const std::string        erc_testnet_swap_contract_address{"0x6b5A52217006B965BB190864D62dc3d270F7AaFD"};
        const std::string        bnb_testnet_swap_contract_address{"0xcCD17C913aD7b772755Ad4F0BDFF7B34C6339150"};
        const std::string        bnb_swap_contract_address{"0xeDc5b89Fe1f0382F9E4316069971D90a0951DB31"};
        const std::string        erc_fallback_swap_contract_address{"0x8500AFc0bc5214728082163326C2FF0C73f4a871"};
        const std::string        erc_testnet_fallback_swap_contract_address{"0x7Bc1bBDD6A0a722fC9bffC49c921B685ECB84b94"};
        const std::string        bnb_fallback_swap_contract_address{bnb_swap_contract_address};
        const std::string        bnb_testnet_fallback_swap_contract_address{bnb_testnet_swap_contract_address};
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
