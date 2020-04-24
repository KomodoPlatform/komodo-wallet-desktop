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

//! PCH Headers
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.mm2.api.hpp"

namespace
{
    namespace bm = boost::multiprecision;
} // namespace

namespace mm2::api
{
    void
    to_json(nlohmann::json& j, const enable_request& cfg)
    {
        j["coin"]                  = cfg.coin_name;
        j["gas_station_url"]       = cfg.gas_station_url;
        j["swap_contract_address"] = cfg.swap_contract_address;
        j["urls"]                  = cfg.urls;
        j["tx_history"]            = cfg.with_tx_history;
    }

    void
    from_json(const nlohmann::json& j, enable_answer& cfg)
    {
        j.at("address").get_to(cfg.address);
        j.at("balance").get_to(cfg.balance);
        j.at("result").get_to(cfg.result);
    }

    void
    from_json(const nlohmann::json& j, electrum_answer& cfg)
    {
        j.at("address").get_to(cfg.address);
        j.at("balance").get_to(cfg.balance);
        j.at("result").get_to(cfg.result);
    }

    void
    to_json(nlohmann::json& j, const electrum_request& cfg)
    {
        j["coin"]       = cfg.coin_name;
        j["servers"]    = cfg.servers;
        j["tx_history"] = cfg.with_tx_history;
    }

    void
    to_json(nlohmann::json& j, const disable_coin_request& req)
    {
        j["coin"] = req.coin;
    }

    void
    from_json(const nlohmann::json& j, disable_coin_answer_success& resp)
    {
        j.at("coin").get_to(resp.coin);
    }

    void
    from_json(const nlohmann::json& j, disable_coin_answer& resp)
    {
        if (j.count("error") == 1)
        {
            resp.error = j.get<std::string>();
        }
        else if (j.count("result") == 1)
        {
            resp.result = j.at("result").get<disable_coin_answer_success>();
        }
    }

    void
    to_json(nlohmann::json& j, const balance_request& cfg)
    {
        j["coin"] = cfg.coin;
    }

    void
    from_json(const nlohmann::json& j, balance_answer& cfg)
    {
        j.at("address").get_to(cfg.address);
        j.at("balance").get_to(cfg.balance);
        cfg.balance = adjust_precision(cfg.balance);
        j.at("coin").get_to(cfg.coin);
        j.at("locked_by_swaps").get_to(cfg.locked_by_swaps);
    }

    void
    from_json(const nlohmann::json& j, fee_regular_coin& cfg)
    {
        j.at("amount").get_to(cfg.amount);
    }

    void
    from_json(const nlohmann::json& j, fee_erc_coin& cfg)
    {
        j.at("coin").get_to(cfg.coin);
        j.at("gas").get_to(cfg.gas);
        j.at("gas_price").get_to(cfg.gas_price);
        j.at("total_fee").get_to(cfg.total_fee);
    }

    void
    from_json(const nlohmann::json& j, fees_data& cfg)
    {
        if (j.count("amount") == 1)
        {
            cfg.normal_fees = fee_regular_coin{};
            from_json(j, cfg.normal_fees.value());
        }
        else if (j.count("gas") == 1)
        {
            cfg.erc_fees = fee_erc_coin{};
            from_json(j, cfg.erc_fees.value());
        }
    }

    void
    to_json(nlohmann::json& j, const tx_history_request& cfg)
    {
        j["coin"]  = cfg.coin;
        j["limit"] = cfg.limit;
    }

    void
    from_json(const nlohmann::json& j, transaction_data& cfg)
    {
        j.at("block_height").get_to(cfg.block_height);
        j.at("coin").get_to(cfg.coin);
        if (j.count("confirmations") == 1)
        {
            cfg.confirmations = j.at("confirmations").get<std::size_t>();
        }
        j.at("fee_details").get_to(cfg.fee_details);
        j.at("from").get_to(cfg.from);
        j.at("internal_id").get_to(cfg.internal_id);
        j.at("my_balance_change").get_to(cfg.my_balance_change);
        j.at("received_by_me").get_to(cfg.received_by_me);
        j.at("spent_by_me").get_to(cfg.spent_by_me);
        j.at("timestamp").get_to(cfg.timestamp);
        j.at("to").get_to(cfg.to);
        j.at("total_amount").get_to(cfg.total_amount);
        j.at("tx_hash").get_to(cfg.tx_hash);
        j.at("tx_hex").get_to(cfg.tx_hex);

        using namespace date;
        using namespace std::chrono;
        date::sys_seconds tp{seconds{cfg.timestamp}};
        std::string       s   = date::format("%e %b %Y, %I:%M", tp);
        cfg.timestamp_as_date = std::move(s);
    }

    void
    from_json(const nlohmann::json& j, sync_status_additional_error& answer)
    {
        j.at("code").get_to(answer.code);
        j.at("message").get_to(answer.message);
    }


    void
    from_json(const nlohmann::json& j, sync_status_eth_erc_20_coins& answer)
    {
        j.at("blocks_left").get_to(answer.blocks_left);
    }

    void
    from_json(const nlohmann::json& j, sync_status_regular_coins& answer)
    {
        j.at("transactions_left").get_to(answer.transactions_left);
    }

    void
    from_json(const nlohmann::json& j, sync_status_additional_infos& answer)
    {
        if (j.count("error") == 1)
        {
            answer.error = j.get<sync_status_additional_error>();
        }
        else if (j.count("blocks_left") == 1)
        {
            answer.erc_infos = j.get<sync_status_eth_erc_20_coins>();
        }
        else if (j.count("transactions_left") == 1)
        {
            answer.regular_infos = j.get<sync_status_regular_coins>();
        }
    }

    void
    from_json(const nlohmann::json& j, t_sync_status& answer)
    {
        j.at("state").get_to(answer.state);
        if (j.count("additional_info") == 1)
        {
            answer.additional_info = j.at("additional_info").get<sync_status_additional_infos>();
        }
    }

    void
    from_json(const nlohmann::json& j, tx_history_answer_success& answer)
    {
        if (not j.at("from_id").is_null())
            j.at("from_id").get_to(answer.from_id);
        j.at("current_block").get_to(answer.current_block);
        j.at("limit").get_to(answer.limit);
        j.at("skipped").get_to(answer.skipped);
        j.at("sync_status").get_to(answer.sync_status);
        j.at("total").get_to(answer.total);
        j.at("transactions").get_to(answer.transactions);
    }

    void
    from_json(const nlohmann::json& j, tx_history_answer& answer)
    {
        if (j.count("error") == 1)
        {
            answer.error = j.at("error").get<std::string>();
        }
        else
        {
            answer.result = j.at("result").get<tx_history_answer_success>();
        }
    }

    void
    to_json(nlohmann::json& j, const withdraw_fees& cfg)
    {
        j["type"] = cfg.type;
        if (cfg.type == "EthGas")
        {
            j["gas"]       = cfg.gas_limit.value_or(55000);
            j["gas_price"] = cfg.gas_price.value();
        }
        else
        {
            j["amount"] = cfg.amount.value();
        }
    }

    void
    to_json(nlohmann::json& j, const withdraw_request& cfg)
    {
        j["coin"]   = cfg.coin;
        j["amount"] = cfg.amount;
        j["to"]     = cfg.to;
        j["max"]    = cfg.max;
        if (cfg.fees.has_value())
        {
            j["fee"] = cfg.fees.value();
        }
    }

    void
    from_json(const nlohmann::json& j, withdraw_answer& answer)
    {
        if (j.count("error") >= 1)
        {
            answer.error = j.at("error").get<std::string>();
        }
        else
        {
            answer.result = j.get<transaction_data>();
        }
    }

    void
    to_json(nlohmann::json& j, const send_raw_transaction_request& cfg)
    {
        j["coin"]   = cfg.coin;
        j["tx_hex"] = cfg.tx_hex;
    }

    void
    from_json(const nlohmann::json& j, send_raw_transaction_answer& answer)
    {
        j.at("tx_hash").get_to(answer.tx_hash);
    }

    void
    to_json(nlohmann::json& j, const orderbook_request& request)
    {
        j["base"] = request.base;
        j["rel"]  = request.rel;
    }

    void
    to_json(nlohmann::json& j, const trade_fee_request& cfg)
    {
        j["coin"] = cfg.coin;
    }

    void
    from_json(const nlohmann::json& j, order_contents& contents)
    {
        j.at("coin").get_to(contents.coin);
        j.at("address").get_to(contents.address);
        j.at("price").get_to(contents.price);
        j.at("maxvolume").get_to(contents.maxvolume);
        j.at("pubkey").get_to(contents.pubkey);
        j.at("age").get_to(contents.age);
        j.at("zcredits").get_to(contents.zcredits);

        boost::trim_right_if(contents.price, boost::is_any_of("0"));
        contents.price     = adjust_precision(contents.price);
        contents.maxvolume = adjust_precision(contents.maxvolume);
    }

    void
    from_json(const nlohmann::json& j, orderbook_answer& answer)
    {
        using namespace date;

        j.at("base").get_to(answer.base);
        j.at("rel").get_to(answer.rel);
        j.at("askdepth").get_to(answer.askdepth);
        j.at("biddepth").get_to(answer.biddepth);
        j.at("bids").get_to(answer.bids);
        j.at("asks").get_to(answer.asks);
        j.at("numasks").get_to(answer.numasks);
        j.at("numbids").get_to(answer.numbids);
        j.at("netid").get_to(answer.netid);
        j.at("timestamp").get_to(answer.timestamp);

        sys_time<std::chrono::milliseconds> tp{std::chrono::milliseconds{answer.timestamp}};
        answer.human_timestamp = date::format("%Y-%m-%d %I:%M:%S", tp);
    }

    void
    from_json(const nlohmann::json& j, trade_fee_answer& cfg)
    {
        j.at("result").at("amount").get_to(cfg.amount);
        j.at("result").at("coin").get_to(cfg.coin);
    }

    void
    to_json(nlohmann::json& j, buy_request& request)
    {
        j["base"]   = request.base;
        j["price"]  = request.price;
        j["rel"]    = request.rel;
        j["volume"] = request.volume;
    }

    void
    from_json(const nlohmann::json& j, trading_order_contents& contents)
    {
        j.at("base").get_to(contents.base);
        j.at("base_amount").get_to(contents.base_amount);
        j.at("rel").get_to(contents.rel);
        j.at("rel_amount").get_to(contents.rel_amount);
        j.at("method").get_to(contents.method);
        j.at("action").get_to(contents.action);
        j.at("uuid").get_to(contents.uuid);
        j.at("sender_pubkey").get_to(contents.sender_pubkey);
        j.at("dest_pub_key").get_to(contents.dest_pub_key);
    }

    void
    from_json(const nlohmann::json& j, buy_answer_success& contents)
    {
        j.get_to(contents.contents);
    }

    void
    from_json(const nlohmann::json& j, buy_answer& answer)
    {
        if (j.count("error") == 1)
        {
            answer.error = j.at("error").get<std::string>();
        }
        else
        {
            answer.result = j.at("result").get<buy_answer_success>();
        }
    }

    void
    to_json(nlohmann::json& j, const sell_request& request)
    {
        j["base"]   = request.base;
        j["price"]  = request.price;
        j["rel"]    = request.rel;
        j["volume"] = request.volume;
    }

    void
    from_json(const nlohmann::json& j, sell_answer_success& contents)
    {
        j.get_to(contents.contents);
    }

    void
    from_json(const nlohmann::json& j, sell_answer& answer)
    {
        if (j.count("error") == 1)
        {
            answer.error = j.at("error").get<std::string>();
        }
        else
        {
            answer.result = j.at("result").get<sell_answer_success>();
        }
    }

    void
    to_json(nlohmann::json& j, const cancel_order_request& request)
    {
        j["uuid"] = request.uuid;
    }

    void
    from_json(const nlohmann::json& j, cancel_order_answer& answer)
    {
        if (j.count("error") == 1)
        {
            answer.error = j.at("error").get<std::string>();
        }
        else
        {
            answer.result = j.at("result").get<std::string>();
        }
    }

    void
    to_json(nlohmann::json& j, const cancel_data& cfg)
    {
        if (cfg.pair.has_value())
        {
            auto [base, rel] = cfg.pair.value();
            j["base"]        = base;
            j["rel"]         = rel;
        }
        else if (cfg.ticker.has_value())
        {
            j["ticker"] = cfg.ticker.value();
        }
    }

    void
    to_json(nlohmann::json& j, const cancel_type& cfg)
    {
        j["type"] = cfg.type;
        if (cfg.type not_eq "All" and cfg.data.has_value())
        {
            j["data"] = cfg.data.value();
        }
    }

    void
    to_json(nlohmann::json& j, const cancel_all_orders_request& cfg)
    {
        j["cancel_by"] = cfg.cancel_by;
    }

    void
    from_json(const nlohmann::json& j, cancel_all_orders_answer& answer)
    {
        j.at("result").at("cancelled").get_to(answer.cancelled);
        j.at("result").at("currently_matching").get_to(answer.currently_matching);
    }

    void
    from_json(const nlohmann::json& j, my_orders_answer& answer)
    {
        static_cast<void>(answer);
        // clang-format off
        auto filler_functor = [](const std::string& key, const nlohmann::json& value, std::map<std::size_t, my_order_contents>& out, bool is_maker)
        {
          using namespace date;
          const auto        time_key = value.at("created_at").get<std::size_t>();
          sys_time<std::chrono::milliseconds> tp{std::chrono::milliseconds{time_key}};

          my_order_contents contents{
              .order_id         = key,
              .price            = is_maker ? adjust_precision(value.at("price").get<std::string>()) : "0",
              .base             = is_maker ? value.at("base").get<std::string>() : value.at("request").at("base").get<std::string>(),
              .rel              = is_maker ? value.at("rel").get<std::string>() : value.at("request").at("rel").get<std::string>(),
              .cancellable      = value.at("cancellable").get<bool>(),
              .timestamp        = time_key,
              .order_type       = is_maker ? "maker" : "taker",
              .base_amount      = is_maker ? value.at("max_base_vol").get<std::string>() : value.at("request").at("base_amount").get<std::string>(),
              .rel_amount       = is_maker ? (t_float_50(contents.price) * t_float_50(contents.base_amount)).convert_to<std::string>() : value.at("request").at("rel_amount").get<std::string>(),
              .human_timestamp  = date::format("%F    %T", tp)};
          out.try_emplace(time_key, std::move(contents));
        };
        // clang-format on

        for (auto&& [key, value]: j.at("result").at("maker_orders").items()) { filler_functor(key, value, answer.maker_orders, true); }
        for (auto&& [key, value]: j.at("result").at("taker_orders").items()) { filler_functor(key, value, answer.taker_orders, false); }
    }

    void
    to_json(nlohmann::json& j, const my_recent_swaps_request& request)
    {
        j["limit"] = request.limit;
        if (request.from_uuid.has_value())
        {
            j["from_uuid"] = request.from_uuid.value();
        }
    }

    void
    from_json(const nlohmann::json& j, started_data& contents)
    {
        j.at("lock_duration").get_to(contents.lock_duration);
    }

    void
    from_json(const nlohmann::json& j, error_data& contents)
    {
        j.at("error").get_to(contents.error_message);
    }

    void
    from_json(const nlohmann::json& j, swap_contents& contents)
    {
        using namespace date;
        using namespace std::chrono;

        j.at("error_events").get_to(contents.error_events);
        j.at("success_events").get_to(contents.success_events);
        j.at("uuid").get_to(contents.uuid);
        j.at("taker_coin").get_to(contents.taker_coin);
        j.at("maker_coin").get_to(contents.maker_coin);
        j.at("taker_amount").get_to(contents.taker_amount);
        j.at("maker_amount").get_to(contents.maker_amount);
        j.at("type").get_to(contents.type);
        j.at("recoverable").get_to(contents.funds_recoverable);

        contents.taker_amount            = adjust_precision(contents.taker_amount);
        contents.maker_amount            = adjust_precision(contents.maker_amount);
        contents.events                  = nlohmann::json::array();
        contents.my_info                 = j.at("my_info");
        contents.my_info["other_amount"] = adjust_precision(contents.my_info["other_amount"].get<std::string>());
        contents.my_info["my_amount"]    = adjust_precision(contents.my_info["my_amount"].get<std::string>());
        for (auto&& content: j.at("events"))
        {
            using sys_milliseconds           = sys_time<std::chrono::milliseconds>;
            const nlohmann::json& j_evt      = content.at("event");
            auto                  timestamp  = content.at("timestamp").get<std::size_t>();
            auto                  tp         = sys_milliseconds{std::chrono::milliseconds{timestamp}};
            std::string           human_date = date::format("%F    %T", tp);
            auto                  evt_type   = j_evt.at("type").get<std::string>();

            if (j_evt.count("data") == 0)
            {
                nlohmann::json jf_evt = {{"state", evt_type}, {"human_timestamp", human_date}, {"timestamp", timestamp}};
                contents.events.push_back(jf_evt);
            }
            else
            {
                nlohmann::json jf_evt = {{"state", evt_type}, {"human_timestamp", human_date}, {"data", j_evt.at("data")}, {"timestamp", timestamp}};
                contents.events.push_back(jf_evt);
            }
        }
    }

    void
    from_json(const nlohmann::json& j, my_recent_swaps_answer_success& results)
    {
        j.at("swaps").get_to(results.swaps);
        j.at("limit").get_to(results.limit);
        j.at("skipped").get_to(results.skipped);
        j.at("total").get_to(results.total);
    }

    void
    from_json(const nlohmann::json& j, my_recent_swaps_answer& answer)
    {
        if (j.find("result") != j.end())
        {
            answer.result = j.at("result").get<my_recent_swaps_answer_success>();
        }
        else if (j.find("error") != j.end())
        {
            answer.error = j.at("error").get<std::string>();
        }
    }

    template <typename T>
    using have_error_field = decltype(std::declval<T&>().error.has_value());

    template <typename RpcReturnType>
    RpcReturnType
    rpc_process_answer(const RestClient::Response& resp) noexcept
    {
        DVLOG_F(loguru::Verbosity_INFO, "resp: {}", resp.body);

        RpcReturnType answer;

        if (resp.code not_eq 200)
        {
            DVLOG_F(loguru::Verbosity_WARNING, "rpc answer code is not 200");
            if constexpr (doom::meta::is_detected_v<have_error_field, RpcReturnType>)
            {
                if constexpr (std::is_same_v<std::string, decltype(answer.error)>)
                {
                    answer.error = nlohmann::json::parse(resp.body).get<std::string>();
                }
            }
            answer.rpc_result_code = resp.code;
            answer.raw_result      = resp.body;
            return answer;
        }

        try
        {
            auto json_answer = nlohmann::json::parse(resp.body);
            from_json(json_answer, answer);
            answer.rpc_result_code = resp.code;
            answer.raw_result      = resp.body;
        }
        catch (const std::exception& error)
        {
            VLOG_F(loguru::Verbosity_ERROR, "{}", error.what());
            answer.rpc_result_code = -1;
            answer.raw_result      = error.what();
        }

        return answer;
    }


    my_recent_swaps_answer
    rpc_my_recent_swaps(my_recent_swaps_request&& request)
    {
        return process_rpc<my_recent_swaps_request, my_recent_swaps_answer>(std::forward<my_recent_swaps_request>(request), "my_recent_swaps");
    }

    enable_answer
    rpc_enable(enable_request&& request)
    {
        return process_rpc<enable_request, enable_answer>(std::forward<enable_request>(request), "enable");
    }

    electrum_answer
    rpc_electrum(electrum_request&& request)
    {
        return process_rpc<electrum_request, electrum_answer>(std::forward<electrum_request>(request), "electrum");
    }

    balance_answer
    rpc_balance(balance_request&& request)
    {
        return process_rpc<balance_request, balance_answer>(std::forward<balance_request>(request), "my_balance");
    }

    tx_history_answer
    rpc_my_tx_history(tx_history_request&& request)
    {
        return process_rpc<tx_history_request, tx_history_answer>(std::forward<tx_history_request>(request), "my_tx_history");
    }

    withdraw_answer
    rpc_withdraw(withdraw_request&& request)
    {
        return process_rpc<withdraw_request, withdraw_answer>(std::forward<withdraw_request>(request), "withdraw");
    }

    send_raw_transaction_answer
    rpc_send_raw_transaction(send_raw_transaction_request&& request)
    {
        using atomic_dex::t_broadcast_answer;
        using atomic_dex::t_broadcast_request;

        return process_rpc<t_broadcast_request, t_broadcast_answer>(std::forward<t_broadcast_request>(request), "send_raw_transaction");
    }

    trade_fee_answer
    rpc_get_trade_fee(trade_fee_request&& req)
    {
        return process_rpc<trade_fee_request, trade_fee_answer>(std::forward<trade_fee_request>(req), "get_trade_fee");
    }

    orderbook_answer
    rpc_orderbook(orderbook_request&& request)
    {
        return process_rpc<orderbook_request, orderbook_answer>(std::forward<orderbook_request>(request), "orderbook");
    }

    buy_answer
    rpc_buy(buy_request&& request)
    {
        return process_rpc<buy_request, buy_answer>(std::forward<buy_request>(request), "buy");
    }

    sell_answer
    rpc_sell(sell_request&& request)
    {
        return process_rpc<sell_request, sell_answer>(std::forward<sell_request>(request), "sell");
    }

    cancel_order_answer
    rpc_cancel_order(cancel_order_request&& request)
    {
        return process_rpc<cancel_order_request, cancel_order_answer>(std::forward<cancel_order_request>(request), "cancel_order");
    }

    cancel_all_orders_answer
    rpc_cancel_all_orders(cancel_all_orders_request&& request)
    {
        return process_rpc<cancel_all_orders_request, cancel_all_orders_answer>(std::forward<cancel_all_orders_request>(request), "cancel_all_orders");
    }

    disable_coin_answer
    rpc_disable_coin(disable_coin_request&& request)
    {
        return process_rpc<disable_coin_request, disable_coin_answer>(std::forward<disable_coin_request>(request), "disable_coin");
    }

    my_orders_answer
    rpc_my_orders() noexcept
    {
        nlohmann::json       json_data = template_request("my_orders");
        RestClient::Response resp;

        DVLOG_F(loguru::Verbosity_INFO, "request: {}", json_data.dump().c_str());

        resp = RestClient::post(g_endpoint, "application/json", json_data.dump());

        return rpc_process_answer<my_orders_answer>(resp);
    }

    template <typename TRequest, typename TAnswer>
    static TAnswer
    process_rpc(TRequest&& request, std::string rpc_command)
    {
        LOG_F(INFO, "Processing rpc call: {}", rpc_command);

        nlohmann::json       json_data = template_request(std::move(rpc_command));
        RestClient::Response resp;

        to_json(json_data, request);

        DVLOG_F(loguru::Verbosity_INFO, "request: {}", json_data.dump());

        resp = RestClient::post(g_endpoint, "application/json", json_data.dump());

        return rpc_process_answer<TAnswer>(resp);
    }

    nlohmann::json
    template_request(std::string method_name) noexcept
    {
        return {{"method", std::move(method_name)}, {"userpass", "atomic_dex_mm2_passphrase"}};
    }

    std::string
    rpc_version()
    {
        LOG_F(INFO, "Processing rpc call: version");
        nlohmann::json       json_data = template_request("version");
        RestClient::Response resp;
        DVLOG_F(loguru::Verbosity_INFO, "request: {}", json_data.dump());
        resp = RestClient::post(g_endpoint, "application/json", json_data.dump());
        if (resp.code == 200) {
            auto answer = nlohmann::json::parse(resp.body);
            return answer.at("result").get<std::string>();
        }
        return "error occured during rpc_version";
    }

} // namespace mm2::api
