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

//! PCH Headers
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.coins.config.hpp"

namespace mm2::api
{
    inline constexpr const char* g_endpoint = "http://127.0.0.1:7783";

    std::string rpc_version();
    //! Only for erc 20
    struct enable_request
    {
        std::string              coin_name;
        std::vector<std::string> urls;
        std::string              swap_contract_address{"0x8500AFc0bc5214728082163326C2FF0C73f4a871"};
        std::string              gas_station_url{"https://ethgasstation.info/json/ethgasAPI.json"};
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

    enable_answer rpc_enable(enable_request&& request);

    struct electrum_request
    {
        std::string                              coin_name;
        std::vector<atomic_dex::electrum_server> servers;
        bool                                     with_tx_history{true};
    };

    struct electrum_answer
    {
        std::string address;
        std::string balance;
        std::string result;
        int         rpc_result_code;
        std::string raw_result;
    };

    void to_json(nlohmann::json& j, const electrum_request& cfg);

    void from_json(const nlohmann::json& j, electrum_answer& answer);

    electrum_answer rpc_electrum(electrum_request&& request);

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

    disable_coin_answer rpc_disable_coin(disable_coin_request&& request);

    struct recover_funds_of_swap_request
    {
        std::string swap_uuid;
    };

    void to_json(nlohmann::json& j, const recover_funds_of_swap_request& cfg);

    struct recover_funds_of_swap_answer_success
    {
        std::string action;
        std::string coin;
        std::string tx_hash;
        std::string tx_hex;
    };

    void from_json(const nlohmann::json& j, recover_funds_of_swap_answer_success& answer);

    struct recover_funds_of_swap_answer
    {
        std::optional<std::string>                          error;
        std::optional<recover_funds_of_swap_answer_success> result;
        int                                                 rpc_result_code;
        std::string                                         raw_result;
    };

    void from_json(const nlohmann::json& j, recover_funds_of_swap_answer& answer);

    recover_funds_of_swap_answer rpc_recover_funds(recover_funds_of_swap_request&& request);


    struct balance_request
    {
        std::string coin;
    };

    struct balance_answer
    {
        std::string address;
        std::string balance;
        std::string coin;
        int         rpc_result_code;
        std::string raw_result;
    };

    void to_json(nlohmann::json& j, const balance_request& cfg);

    void from_json(const nlohmann::json& j, balance_answer& cfg);

    balance_answer rpc_balance(balance_request&& request);

    struct trade_fee_request
    {
        std::string coin;
    };

    void to_json(nlohmann::json& j, const trade_fee_request& cfg);

    struct trade_fee_answer
    {
        std::string amount;
        std::string coin;
        std::string raw_result;      ///< internal
        int         rpc_result_code; ///< internal
    };

    void from_json(const nlohmann::json& j, trade_fee_answer& cfg);

    trade_fee_answer rpc_get_trade_fee(trade_fee_request&& req);

    struct fee_regular_coin
    {
        std::string amount;
    };

    void from_json(const nlohmann::json& j, fee_regular_coin& cfg);

    struct fee_erc_coin
    {
        std::string coin;
        std::size_t gas;
        std::string gas_price;
        std::string total_fee;
    };

    void from_json(const nlohmann::json& j, fee_erc_coin& cfg);

    struct fees_data
    {
        std::optional<fee_regular_coin> normal_fees; ///< btc, kmd based coins
        std::optional<fee_erc_coin>     erc_fees;    ///< eth based coins
    };

    void from_json(const nlohmann::json& j, fees_data& cfg);


    struct tx_history_request
    {
        std::string coin;
        std::size_t limit;
    };

    void to_json(nlohmann::json& j, const tx_history_request& cfg);

    struct transaction_data
    {
        std::size_t                timestamp;
        std::vector<std::string>   from;
        std::vector<std::string>   to;
        fees_data                  fee_details;
        std::optional<std::size_t> confirmations;
        std::string                coin;
        std::size_t                block_height;
        std::string                internal_id;
        std::string                spent_by_me;
        std::string                received_by_me;
        std::string                my_balance_change;
        std::string                total_amount;
        std::string                tx_hash;
        std::string                tx_hex;
        std::string                timestamp_as_date; ///< human readeable timestamp
    };

    void from_json(const nlohmann::json& j, transaction_data& cfg);

    struct sync_status_additional_error
    {
        std::string message;
        int         code;
    };

    void from_json(const nlohmann::json& j, sync_status_additional_error& answer);

    struct sync_status_eth_erc_20_coins
    {
        std::size_t blocks_left;
    };

    void from_json(const nlohmann::json& j, sync_status_eth_erc_20_coins& answer);

    struct sync_status_regular_coins
    {
        std::size_t transactions_left;
    };

    void from_json(const nlohmann::json& j, sync_status_regular_coins& answer);

    struct sync_status_additional_infos
    {
        std::optional<sync_status_additional_error> error;         ///< in case of error
        std::optional<sync_status_eth_erc_20_coins> erc_infos;     ///< eth/erc20 related coins
        std::optional<sync_status_regular_coins>    regular_infos; ///< kmd/btc/utxo related coins
    };

    void from_json(const nlohmann::json& j, sync_status_additional_infos& answer);

    struct t_sync_status
    {
        std::string                                 state; ///< NotEnabled, NotStarted, InProgress, Error, Finished
        std::optional<sync_status_additional_infos> additional_info;
    };

    void from_json(const nlohmann::json& j, t_sync_status& answer);

    struct tx_history_answer_success
    {
        std::string                   from_id;
        std::size_t                   skipped;
        std::size_t                   limit;
        std::size_t                   current_block;
        std::size_t                   total;
        std::vector<transaction_data> transactions;
        t_sync_status                 sync_status;
    };

    void from_json(const nlohmann::json& j, tx_history_answer_success& answer);

    struct tx_history_answer
    {
        std::optional<std::string>               error;
        std::optional<tx_history_answer_success> result;
        std::string                              raw_result;      ///< internal
        int                                      rpc_result_code; ///< internal
    };

    void from_json(const nlohmann::json& j, tx_history_answer& answer);

    tx_history_answer rpc_my_tx_history(tx_history_request&& request);

    struct withdraw_fees
    {
        std::string                type;      ///< UtxoFixed, UtxoPerKbyte, EthGas
        std::optional<std::string> amount;    ///< for utxo only
        std::optional<std::string> gas_price; ///< price EthGas
        std::optional<int>         gas_limit; ///< sets the gas limit for transaction
    };

    void to_json(nlohmann::json& j, const withdraw_fees& cfg);

    struct withdraw_request
    {
        std::string                  coin;
        std::string                  to;                 ///< coins will be withdraw to this address
        std::string                  amount;             ///< ignored if max is true
        std::optional<withdraw_fees> fees{std::nullopt}; ///< ignored if std::nullopt
        bool                         max{false};
    };

    void to_json(nlohmann::json& j, const withdraw_request& cfg);

    struct withdraw_answer
    {
        std::optional<transaction_data> result;
        std::optional<std::string>      error;
        std::string                     raw_result;      ///< internal
        int                             rpc_result_code; ///< internal
    };

    void from_json(const nlohmann::json& j, withdraw_answer& answer);

    withdraw_answer rpc_withdraw(withdraw_request&& request);

    struct send_raw_transaction_request
    {
        std::string coin;
        std::string tx_hex;
    };

    void to_json(nlohmann::json& j, const send_raw_transaction_request& cfg);

    struct send_raw_transaction_answer
    {
        std::string tx_hash;
        std::string raw_result;      ///< internal
        int         rpc_result_code; ///< internal
    };

    void from_json(const nlohmann::json& j, send_raw_transaction_answer& answer);

    send_raw_transaction_answer rpc_send_raw_transaction(send_raw_transaction_request&& request);

    struct orderbook_request
    {
        std::string base;
        std::string rel;
    };

    void to_json(nlohmann::json& j, const orderbook_request& request);

    struct order_contents
    {
        std::string coin;
        std::string address;
        std::string price;
        std::string price_fraction_numer;
        std::string price_fraction_denom;
        std::string maxvolume;
        std::string pubkey;
        std::size_t age;
        std::size_t zcredits;
    };

    void from_json(const nlohmann::json& j, order_contents& contents);

    struct orderbook_answer
    {
        std::size_t                 askdepth;
        std::size_t                 biddepth;
        std::vector<order_contents> asks;
        std::vector<order_contents> bids;
        std::string                 base;
        std::string                 rel;
        std::size_t                 numasks;
        std::size_t                 numbids;
        std::size_t                 timestamp;
        std::size_t                 netid;
        std::string                 human_timestamp; //! Moment of the orderbook request human readeable

        //! Internal
        std::string raw_result;
        int         rpc_result_code;
    };

    void from_json(const nlohmann::json& j, orderbook_answer& answer);

    orderbook_answer rpc_orderbook(orderbook_request&& request);

    struct trading_order_contents
    {
        std::string action;
        std::string base;
        std::string base_amount;
        std::string dest_pub_key;
        std::string method;
        std::string rel;
        std::string rel_amount;
        std::string sender_pubkey;
        std::string uuid;
    };

    void from_json(const nlohmann::json& j, trading_order_contents& contents);

    struct buy_request
    {
        std::string base;
        std::string rel;
        std::string price;
        std::string volume;
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

    buy_answer rpc_buy(buy_request&& request);

    struct setprice_request
    {
        std::string base;
        std::string rel;
        std::string price;
        std::string volume;
        bool        max{false};
        bool        cancel_previous{false};
    };

    void to_json(nlohmann::json& j, const setprice_request& request);

    struct sell_request
    {
        std::string base;
        std::string rel;
        std::string price;
        std::string volume;
        bool        is_created_order;
        std::string price_denom;
        std::string price_numer;
    };

    void to_json(nlohmann::json& j, const sell_request& request);

    struct sell_answer_success
    {
        trading_order_contents contents;
    };

    void from_json(const nlohmann::json& j, sell_answer_success& contents);

    struct sell_answer
    {
        std::optional<std::string>         error;
        std::optional<sell_answer_success> result;
        int                                rpc_result_code;
        std::string                        raw_result;
    };

    void from_json(const nlohmann::json& j, sell_answer& answer);

    sell_answer rpc_sell(sell_request&& request);

    struct cancel_order_request
    {
        std::string uuid;
    };

    void to_json(nlohmann::json& j, const cancel_order_request& request);

    struct cancel_order_answer
    {
        std::optional<std::string> result;
        std::optional<std::string> error;
        int                        rpc_result_code;
        std::string                raw_result;
    };

    void from_json(const nlohmann::json& j, cancel_order_answer& answer);

    cancel_order_answer rpc_cancel_order(cancel_order_request&& request);

    struct cancel_data
    {
        //! If by == Pair
        std::optional<std::pair<std::string, std::string>> pair;

        //! If by == Coin
        std::optional<std::string> ticker;
    };

    void to_json(nlohmann::json& j, const cancel_data& cfg);

    struct cancel_type
    {
        std::string                type{"All"};
        std::optional<cancel_data> data{std::nullopt};
    };

    void to_json(nlohmann::json& j, const cancel_type& cfg);

    struct cancel_all_orders_request
    {
        cancel_type cancel_by;
    };

    void to_json(nlohmann::json& j, const cancel_all_orders_request& cfg);

    struct cancel_all_orders_answer
    {
        std::vector<std::string> cancelled;
        std::vector<std::string> currently_matching;
        int                      rpc_result_code;
        std::string              raw_result;
    };

    void from_json(const nlohmann::json& j, cancel_all_orders_answer& answer);

    cancel_all_orders_answer rpc_cancel_all_orders(cancel_all_orders_request&& request);

    struct my_order_contents
    {
        //! New
        std::string order_id;
        std::string price;
        std::string base;
        std::string rel;
        bool        cancellable;
        std::size_t timestamp;
        std::string human_timestamp;
        std::string order_type;
        std::string base_amount;
        std::string rel_amount;
    };

    struct my_orders_answer
    {
        std::map<std::size_t, my_order_contents> maker_orders;
        std::map<std::size_t, my_order_contents> taker_orders;
        int                                      rpc_result_code;
        std::string                              raw_result;
    };

    void from_json(const nlohmann::json& j, my_orders_answer& answer);

    my_orders_answer rpc_my_orders() noexcept;

    struct my_recent_swaps_request
    {
        std::size_t                limit{50ull};
        std::optional<std::string> from_uuid;
    };

    void to_json(nlohmann::json& j, const my_recent_swaps_request& request);

    struct finished_event
    {
        std::size_t timestamp;
        std::string human_date;
    };

    struct started_data
    {
        std::size_t lock_duration;
    };

    void from_json(const nlohmann::json& j, started_data& contents);

    struct started_event
    {
        std::size_t  timestamp;
        std::string  human_date;
        started_data data;
    };

    struct error_data
    {
        std::string error_message;
    };

    void from_json(const nlohmann::json& j, error_data& contents);

    struct start_failed_event
    {
        std::size_t timestamp;
        std::string human_date;
        error_data  data;
    };

    struct negotiate_failed_event
    {
        std::size_t timestamp;
        std::string human_date;
        error_data  data;
    };

    struct swap_contents
    {
        // using t_event_registry = std::unordered_map<std::string, std::variant<finished_event, started_event, start_failed_event, negotiate_failed_event>>;
        std::vector<std::string> error_events;
        std::vector<std::string> success_events;
        nlohmann::json           events;
        nlohmann::json           my_info;
        std::string              uuid;
        std::string              taker_coin;
        std::string              maker_coin;
        std::string              taker_amount;
        std::string              maker_amount;
        std::string              type;
        std::string              total_time_in_seconds;
        bool                     funds_recoverable;
    };

    void from_json(const nlohmann::json& j, swap_contents& contents);

    struct my_recent_swaps_answer_success
    {
        std::vector<swap_contents> swaps;
        std::size_t                limit;
        std::size_t                skipped;
        std::size_t                total;
        std::string                raw_result;
    };

    void from_json(const nlohmann::json& j, my_recent_swaps_answer_success& results);

    struct my_recent_swaps_answer
    {
        std::optional<my_recent_swaps_answer_success> result;
        std::optional<std::string>                    error;
        int                                           rpc_result_code;
        std::string                                   raw_result;
    };

    void from_json(const nlohmann::json& j, my_recent_swaps_answer& answer);

    my_recent_swaps_answer rpc_my_recent_swaps(my_recent_swaps_request&& request);

    nlohmann::json rpc_batch_electrum(std::vector<electrum_request> requests);
    nlohmann::json rpc_batch_enable(std::vector<enable_request> requests);

    template <typename RpcReturnType>
    static RpcReturnType rpc_process_answer(const RestClient::Response& resp, const std::string& rpc_command) noexcept;

    nlohmann::json template_request(std::string method_name) noexcept;

    template <typename TRequest, typename TAnswer>
    TAnswer static process_rpc(TRequest&& request, std::string rpc_command);

    void               set_rpc_password(std::string rpc_password) noexcept;
    const std::string& get_rpc_password() noexcept;
} // namespace mm2::api

namespace atomic_dex
{
    using t_balance_request         = ::mm2::api::balance_request;
    using t_balance_answer          = ::mm2::api::balance_answer;
    using t_buy_answer              = ::mm2::api::buy_answer;
    using t_buy_request             = ::mm2::api::buy_request;
    using t_my_orders_answer        = ::mm2::api::my_orders_answer;
    using t_sell_answer             = ::mm2::api::sell_answer;
    using t_sell_request            = ::mm2::api::sell_request;
    using t_withdraw_request        = ::mm2::api::withdraw_request;
    using t_withdraw_fees           = ::mm2::api::withdraw_fees;
    using t_withdraw_answer         = ::mm2::api::withdraw_answer;
    using t_broadcast_request       = ::mm2::api::send_raw_transaction_request;
    using t_broadcast_answer        = ::mm2::api::send_raw_transaction_answer;
    using t_orderbook_request       = ::mm2::api::orderbook_request;
    using t_orderbook_answer        = ::mm2::api::orderbook_answer;
    using t_electrum_request        = ::mm2::api::electrum_request;
    using t_enable_request          = ::mm2::api::enable_request;
    using t_disable_coin_request    = ::mm2::api::disable_coin_request;
    using t_tx_history_request      = ::mm2::api::tx_history_request;
    using t_my_recent_swaps_answer  = ::mm2::api::my_recent_swaps_answer_success;
    using t_my_recent_swaps_request = ::mm2::api::my_recent_swaps_request;
    using t_my_order_contents       = ::mm2::api::my_order_contents;
    using t_get_trade_fee_request   = ::mm2::api::trade_fee_request;
    using t_get_trade_fee_answer    = ::mm2::api::trade_fee_answer;
} // namespace atomic_dex
