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
        std::string raw_result;
    };

    struct tx_history_request {
        std::string coin;
        std::size_t limit;
    };

    struct transaction_data {
        std::size_t timestamp;
        std::vector<std::string> from;
        std::vector<std::string> to;
        std::size_t confirmations;
        std::string coin;
        std::size_t block_height;
        std::string internal_id;
        std::string spent_by_me;
        std::string received_by_me;
        std::string my_balance_change;
        std::string total_amount;
        std::string tx_hash;
        std::string tx_hex;
    };

    struct sync_status_additional_error {
        std::string message;
        int code;
    };

    void from_json(const nlohmann::json &j, sync_status_additional_error &answer);

    struct sync_status_eth_erc_20_coins {
        std::size_t blocks_left;
    };

    void from_json(const nlohmann::json &j, sync_status_eth_erc_20_coins& answer);

    struct sync_status_regular_coins {
        std::size_t transactions_left;
    };

    struct sync_status_additional_infos {
        std::optional<sync_status_additional_error> error; ///< in case of error
        std::optional<sync_status_eth_erc_20_coins> erc_infos; ///< eth/erc20 related coins
        std::optional<sync_status_regular_coins> regular_infos; ///< kmd/btc/utxo related coins
    };

    struct t_sync_status {
        std::string state; ///< NotEnabled, NotStarted, InProgress, Error, Finished
        sync_status_additional_infos additional_infos;
    };

    struct tx_history_answer_success {
        std::string from_id;
        std::size_t skipped;
        std::size_t limit;
        std::size_t current_block;
        std::size_t total;
        std::vector<transaction_data> transactions;
        t_sync_status sync_status;
        std::string raw_result; ///< internal
        int rpc_result_code; ///< internal
    };

    struct tx_history_answer {
        std::optional<std::string> error;
        std::optional<tx_history_answer_success> result;
    };

    template<typename RpcReturnType>
    static RpcReturnType rpc_process_answer(const RestClient::Response &resp) noexcept;
}