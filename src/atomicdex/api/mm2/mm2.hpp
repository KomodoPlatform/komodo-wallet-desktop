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
#include <unordered_set>

//! Deps
#include <antara/gaming/ecs/system.manager.hpp>
#include <meta/detection/detection.hpp>
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/config/coins.cfg.hpp"
#include "atomicdex/constants/mm2.constants.hpp"
#include "atomicdex/constants/qt.coins.enums.hpp"
#include "atomicdex/data/dex/qt.orders.data.hpp"
#include "atomicdex/utilities/cpprestsdk.utilities.hpp"

namespace mm2::api
{
    inline constexpr const char*                           g_endpoint                 = "http://127.0.0.1:7783";
    inline constexpr const char*                           g_etherscan_proxy_endpoint = "https://komodo.live:3334";
    inline std::unique_ptr<web::http::client::http_client> g_etherscan_proxy_http_client{
        std::make_unique<web::http::client::http_client>(FROM_STD_STR(g_etherscan_proxy_endpoint))};
    inline std::unique_ptr<web::http::client::http_client> g_qtum_proxy_http_client{
        std::make_unique<web::http::client::http_client>(FROM_STD_STR(::atomic_dex::g_qtum_infos_endpoint))};

    pplx::task<web::http::http_response>
                   async_rpc_batch_standalone(nlohmann::json batch_array, std::shared_ptr<t_http_client> mm2_client, pplx::cancellation_token token);
    nlohmann::json basic_batch_answer(const web::http::http_response& resp);

    std::string rpc_version();

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

    disable_coin_answer rpc_disable_coin(disable_coin_request&& request, std::shared_ptr<t_http_client> mm2_client);

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

    recover_funds_of_swap_answer rpc_recover_funds(recover_funds_of_swap_request&& request, std::shared_ptr<t_http_client> mm2_client);


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

    struct fee_qrc_coin
    {
        std::string coin;
        std::string miner_fee;
        std::size_t gas_limit;
        std::size_t gas_price;
        std::string total_gas_fee;
    };

    void from_json(const nlohmann::json& j, fee_qrc_coin& cfg);

    struct fees_data
    {
        std::optional<fee_regular_coin> normal_fees; ///< btc, kmd based coins
        std::optional<fee_erc_coin>     erc_fees;    ///< eth based coins
        std::optional<fee_qrc_coin>     qrc_fees;    // Qtum based coin
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

    struct withdraw_fees
    {
        std::string                type;      ///< UtxoFixed, UtxoPerKbyte, EthGas, Qrc20Gas
        std::optional<std::string> amount;    ///< Utxo only
        std::optional<std::string> gas_price; ///< price EthGas or Qrc20Gas
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

    struct send_raw_transaction_request
    {
        std::string tx_hex;
        std::string coin;
    };

    void to_json(nlohmann::json& j, const send_raw_transaction_request& cfg);

    struct send_raw_transaction_answer
    {
        std::string tx_hash;
        std::string raw_result;      ///< internal
        int         rpc_result_code; ///< internal
    };

    void from_json(const nlohmann::json& j, send_raw_transaction_answer& answer);

    send_raw_transaction_answer rpc_send_raw_transaction(send_raw_transaction_request&& request, std::shared_ptr<t_http_client> mm2_client);

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
        std::string max_volume_fraction_numer;
        std::string max_volume_fraction_denom;
        std::string maxvolume;
        std::string pubkey;
        std::size_t age;
        std::size_t zcredits;
        std::string total;
        std::string uuid;
        std::string depth_percent;
        bool        is_mine;
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
        std::string                 asks_total_volume;
        std::string                 bids_total_volume;

        //! Internal
        std::string raw_result;
        int         rpc_result_code;
    };

    void from_json(const nlohmann::json& j, orderbook_answer& answer);

    struct setprice_request
    {
        std::string                base;
        std::string                rel;
        std::string                price;
        std::string                volume;
        bool                       max{false};
        bool                       cancel_previous{false};
        std::optional<bool>        base_nota;
        std::optional<std::size_t> base_confs;
        std::optional<bool>        rel_nota;
        std::optional<std::size_t> rel_confs;
    };

    void to_json(nlohmann::json& j, const setprice_request& request);

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

    struct my_orders_answer
    {
        std::vector<order_swaps_data>   orders;
        std::unordered_set<std::string> orders_id;
        int                             rpc_result_code;
        std::string                     raw_result;
    };

    void from_json(const nlohmann::json& j, my_orders_answer& answer);

    struct my_recent_swaps_request
    {
        std::size_t                limit{50ull};
        std::optional<std::size_t> page_number{1};
        std::optional<std::string> from_uuid;

        //! Filtering
        std::optional<std::string> my_coin;        ///< base_coin
        std::optional<std::string> other_coin;     ///< rel_coin
        std::optional<std::size_t> from_timestamp; ///< start date
        std::optional<std::size_t> to_timestamp;   ///< end date
    };

    void to_json(nlohmann::json& j, const my_recent_swaps_request& request);

    void from_json(const nlohmann::json& j, order_swaps_data& contents);

    struct my_recent_swaps_answer_success
    {
        std::vector<order_swaps_data>   swaps;
        std::unordered_set<std::string> swaps_id;
        std::size_t                     limit;
        std::size_t                     skipped;
        std::size_t                     total;
        std::size_t                     page_number;
        std::size_t                     total_pages;
        std::string                     raw_result;
        nlohmann::json                  average_events_time;
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

    struct active_swaps_request
    {
        std::optional<bool> statuses;
    };

    void to_json(nlohmann::json& j, const active_swaps_request& request);

    struct active_swaps_answer
    {
        std::unordered_set<std::string> uuids;
        std::vector<order_swaps_data>   swaps;
        int                             rpc_result_code;
        std::string                     raw_result;
    };

    void from_json(const nlohmann::json& j, active_swaps_answer& answer);

    struct show_priv_key_request
    {
        std::string coin;
    };

    void to_json(nlohmann::json& j, const show_priv_key_request& request);

    struct show_priv_key_answer
    {
        std::string coin;
        std::string priv_key;
        std::string raw_result;
        int         rpc_result_code;
    };

    void from_json(const nlohmann::json& j, show_priv_key_answer& answer);

    struct kmd_rewards_info_answer
    {
        nlohmann::json result;
        int            rpc_result_code;
    };

    // kmd_rewards_info_answer rpc_kmd_rewards_info(std::shared_ptr<t_http_client> mm2_client);
    kmd_rewards_info_answer process_kmd_rewards_answer(nlohmann::json result);

    template <typename T>
    using have_error_field = decltype(std::declval<T&>().error.has_value());

    template <typename RpcReturnType>
    RpcReturnType rpc_process_answer(const web::http::http_response& resp, const std::string& rpc_command) noexcept;

    template <typename RpcReturnType>
    RpcReturnType rpc_process_answer_batch(nlohmann::json& json_answer, const std::string& rpc_command) noexcept;

    pplx::task<web::http::http_response> async_process_rpc_get(t_http_client_ptr& client, const std::string rpc_command, const std::string& url);

    nlohmann::json template_request(std::string method_name) noexcept;

    template <typename TRequest, typename TAnswer>
    static TAnswer process_rpc(TRequest&& request, std::string rpc_command, std::shared_ptr<t_http_client> http_mm2_client);

    void               set_rpc_password(std::string rpc_password) noexcept;
    const std::string& get_rpc_password() noexcept;
    void               set_system_manager(ag::ecs::system_manager& system_manager);
} // namespace mm2::api

namespace atomic_dex
{
    using t_my_orders_answer        = ::mm2::api::my_orders_answer;
    using t_setprice_request        = ::mm2::api::setprice_request;
    using t_withdraw_request        = ::mm2::api::withdraw_request;
    using t_withdraw_fees           = ::mm2::api::withdraw_fees;
    using t_withdraw_answer         = ::mm2::api::withdraw_answer;
    using t_broadcast_request       = ::mm2::api::send_raw_transaction_request;
    using t_orderbook_request       = ::mm2::api::orderbook_request;
    using t_orderbook_answer        = ::mm2::api::orderbook_answer;
    using t_disable_coin_request    = ::mm2::api::disable_coin_request;
    using t_tx_history_request      = ::mm2::api::tx_history_request;
    using t_my_recent_swaps_answer  = ::mm2::api::my_recent_swaps_answer;
    using t_my_recent_swaps_request = ::mm2::api::my_recent_swaps_request;
    using t_active_swaps_request    = ::mm2::api::active_swaps_request;
    using t_active_swaps_answer     = ::mm2::api::active_swaps_answer;
    using t_get_trade_fee_request   = ::mm2::api::trade_fee_request;
    using t_get_trade_fee_answer    = ::mm2::api::trade_fee_answer;
} // namespace atomic_dex
