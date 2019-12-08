/******************************************************************************
 * Copyright © 2013-2019 The Komodo Platform Developers.                      *
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

#include <string>
#include <vector>
#include <optional>
#include <restclient-cpp/restclient.h>
#include <loguru.hpp>
#include <nlohmann/json.hpp>
#include "atomic.dex.coins.config.hpp"

namespace mm2::api {
    static constexpr const char *endpoint = "http://127.0.0.1:7783";

    struct electrum_request {
        std::string coin_name;
        std::vector<atomic_dex::electrum_server> servers;
        bool with_tx_history{true};
    };

    struct electrum_answer {
        std::string address;
        std::string balance;
        std::string result;
        int rpc_result_code;
        std::string raw_result;
    };

    void to_json(nlohmann::json &j, const electrum_request &cfg);

    void from_json(const nlohmann::json &j, electrum_answer &answer);

    electrum_answer rpc_electrum(electrum_request &&request);

    struct balance_request {
        std::string coin;
    };

    struct balance_answer {
        std::string address;
        std::string balance;
        std::string coin;
        std::string locked_by_swaps;
        int rpc_result_code;
        std::string raw_result;
    };

    void to_json(nlohmann::json &j, const balance_request &cfg);

    void from_json(const nlohmann::json &j, balance_answer &cfg);

    balance_answer rpc_balance(balance_request &&request);

    struct withdraw_fee {
        std::optional<std::string> amount; ///< btc, kmd based coins
        std::optional<std::string> total_fee; ///< eth based coins
    };

    struct withdraw_request {
        std::string coin;
        std::string to; ///< coins will be withdraw to this address
        std::string amount; ///< ignored if max is true
        bool max{false};
    };

    struct withdraw_answer {
        std::vector<std::string> from;
        std::vector<std::string> to;
        withdraw_fee fee_details;
        std::string tx_hash;
        std::string tx_hex;
        std::string my_balance_change;
        std::string received_by_me;
        std::string spent_by_me;
        std::string total_amount;
        int rpc_result_code;
        std::string result;
    };

    template<typename RpcReturnType>
    static RpcReturnType rpc_process_answer(const RestClient::Response &resp) noexcept;
}