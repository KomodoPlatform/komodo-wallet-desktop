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

#include <date/date.h>
#include "atomic.dex.mm2.api.hpp"

namespace {
    nlohmann::json template_request(std::string method_name) noexcept {
        LOG_SCOPE_FUNCTION(INFO);
        return {
                {"method",   method_name},
                {"userpass", "atomix_dex_mm2_passphrase"}
        };
    }
}

namespace mm2::api {
    void from_json(const nlohmann::json &j, electrum_answer &cfg) {
        LOG_SCOPE_FUNCTION(INFO);
        j.at("address").get_to(cfg.address);
        j.at("balance").get_to(cfg.balance);
        j.at("result").get_to(cfg.result);
    }

    void to_json(nlohmann::json &j, const electrum_request &cfg) {
        LOG_SCOPE_FUNCTION(INFO);
        j["coin"] = cfg.coin_name;
        j["servers"] = cfg.servers;
        j["tx_history"] = cfg.with_tx_history;
    }

    void to_json(nlohmann::json &j, const balance_request &cfg) {
        LOG_SCOPE_FUNCTION(INFO);
        j["coin"] = cfg.coin;
    }

    void from_json(const nlohmann::json &j, balance_answer &cfg) {
        LOG_SCOPE_FUNCTION(INFO);
        j.at("address").get_to(cfg.address);
        j.at("balance").get_to(cfg.balance);
        j.at("coin").get_to(cfg.coin);
        j.at("locked_by_swaps").get_to(cfg.locked_by_swaps);
    }

    void from_json(const nlohmann::json &j, fee_regular_coin &cfg) {
        LOG_SCOPE_FUNCTION(INFO);
        j.at("amount").get_to(cfg.amount);
    }

    void from_json(const nlohmann::json &j, fee_erc_coin &cfg) {
        LOG_SCOPE_FUNCTION(INFO);
        j.at("coin").get_to(cfg.coin);
        j.at("gas").get_to(cfg.gas);
        j.at("gas_price").get_to(cfg.gas_price);
        j.at("total_fee").get_to(cfg.total_fee);
    }

    void from_json(const nlohmann::json &j, fees_data &cfg) {
        LOG_SCOPE_FUNCTION(INFO);
        if (j.count("amount") == 1) {
            cfg.normal_fees = fee_regular_coin{};
            from_json(j, cfg.normal_fees.value());
        } else if (j.count("gas") == 1) {
            cfg.erc_fees = fee_erc_coin{};
            from_json(j, cfg.erc_fees.value());
        }
    }

    void to_json(nlohmann::json &j, const tx_history_request &cfg) {
        LOG_SCOPE_FUNCTION(INFO);
        j["coin"] = cfg.coin;
        j["limit"] = cfg.limit;
    }

    void from_json(const nlohmann::json &j, transaction_data &cfg) {
        LOG_SCOPE_FUNCTION(INFO);
        j.at("block_height").get_to(cfg.block_height);
        j.at("coin").get_to(cfg.coin);
        if (j.count("confirmations") == 1) {
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
        auto sys_time = std::chrono::system_clock::from_time_t(cfg.timestamp);
        const auto date = year_month_day(floor<days>(sys_time));
        std::stringstream ss;
        ss << date;
        cfg.timestamp_as_date = ss.str();
    }

    void from_json(const nlohmann::json &j, sync_status_additional_error &answer) {
        LOG_SCOPE_FUNCTION(INFO);
        j.at("code").get_to(answer.code);
        j.at("message").get_to(answer.message);
    }


    void from_json(const nlohmann::json &j, sync_status_eth_erc_20_coins &answer) {
        LOG_SCOPE_FUNCTION(INFO);
        j.at("blocks_left").get_to(answer.blocks_left);
    }

    void from_json(const nlohmann::json &j, sync_status_regular_coins &answer) {
        LOG_SCOPE_FUNCTION(INFO);
        j.at("transactions_left").get_to(answer.transactions_left);
    }

    void from_json(const nlohmann::json &j, sync_status_additional_infos &answer) {
        LOG_SCOPE_FUNCTION(INFO);
        if (j.count("error") == 1) {
            answer.error = j.get<sync_status_additional_error>();
        } else if (j.count("blocks_left") == 1) {
            answer.erc_infos = j.get<sync_status_eth_erc_20_coins>();
        } else if (j.count("transactions_left") == 1) {
            answer.regular_infos = j.get<sync_status_regular_coins>();
        }
    }

    void from_json(const nlohmann::json &j, t_sync_status &answer) {
        LOG_SCOPE_FUNCTION(INFO);
        j.at("state").get_to(answer.state);
        if (j.count("additional_info") == 1) {
            answer.additional_info = j.at("additional_info").get<sync_status_additional_infos>();
        }
    }

    void from_json(const nlohmann::json &j, tx_history_answer_success &answer) {
        LOG_SCOPE_FUNCTION(INFO);
        if (not j.at("from_id").is_null())
            j.at("from_id").get_to(answer.from_id);
        j.at("current_block").get_to(answer.current_block);
        j.at("limit").get_to(answer.limit);
        j.at("skipped").get_to(answer.skipped);
        j.at("sync_status").get_to(answer.sync_status);
        j.at("total").get_to(answer.total);
        j.at("transactions").get_to(answer.transactions);
    }

    void from_json(const nlohmann::json &j, tx_history_answer &answer) {
        LOG_SCOPE_FUNCTION(INFO);
        if (j.count("error") == 1) {
            answer.error = j.at("error").get<std::string>();
        } else {
            answer.result = j.at("result").get<tx_history_answer_success>();
        }
    }

    void to_json(nlohmann::json &j, const withdraw_request &cfg) {
        LOG_SCOPE_FUNCTION(INFO);
        j["coin"] = cfg.coin;
        j["amount"] = cfg.amount;
        j["to"] = cfg.to;
        j["max"] = cfg.max;
    }

    void from_json(const nlohmann::json &j, withdraw_answer &answer) {
        LOG_SCOPE_FUNCTION(INFO);
        if (j.count("error") == 1) {
            answer.error = j.at("error").get<std::string>();
        } else {
            answer.result = j.at("result").get<transaction_data>();
        }
    }

    void to_json(nlohmann::json &j, const send_raw_transaction_request &cfg) {
        j["coin"] = cfg.coin;
        j["hex"] = cfg.tx_hex;
    }

    void from_json(const nlohmann::json &j, send_raw_transaction_answer &answer) {
        j.at("tx_hash").get_to(answer.tx_hash);
    }

    void to_json(nlohmann::json &j, const orderbook_request &request) {
        j["base"] = request.base;
        j["rel"] = request.rel;
    }


    void from_json(const nlohmann::json &j, order_contents &contents) {
        j.at("coin").get_to(contents.coin);
        j.at("address").get_to(contents.address);
        j.at("price").get_to(contents.price);
        j.at("maxvolume").get_to(contents.maxvolume);
        j.at("pubkey").get_to(contents.pubkey);
        j.at("age").get_to(contents.age);
        j.at("zcredits").get_to(contents.zcredits);
    }

    void from_json(const nlohmann::json &j, orderbook_answer answer) {
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
        using namespace date;
        auto sys_time = std::chrono::system_clock::from_time_t(answer.timestamp);
        const auto date = year_month_day(floor<days>(sys_time));
        std::stringstream ss;
        ss << date;
        answer.human_timestamp = ss.str();
    }

    void to_json(nlohmann::json &j, buy_request &request) {
        j["base"] = request.base;
        j["price"] = request.price;
        j["rel"] = request.rel;
        j["volume"] = request.volume;
    }

    void from_json(const nlohmann::json &j, trading_order_contents &contents) {
        j.at("base").get_to(contents.base);
        j.at("base_amount").get_to(contents.base_amount);
        j.at("base_amount_rat").get_to(contents.base_amount_rat);
        j.at("rel").get_to(contents.rel);
        j.at("rel_amount").get_to(contents.rel_amount);
        j.at("rel_amount_rat").get_to(contents.rel_amount_rat);
        j.at("method").get_to(contents.method);
        j.at("action").get_to(contents.action);
        j.at("uuid").get_to(contents.uuid);
        j.at("sender_pubkey").get_to(contents.sender_pubkey);
        j.at("dest_pub_key").get_to(contents.dest_pub_key);
    }

    void from_json(const nlohmann::json &j, buy_answer_success &contents) {
        j.get_to(contents.contents);
    }

    void from_json(const nlohmann::json &j, buy_answer &answer) {
        LOG_SCOPE_FUNCTION(INFO);
        if (j.count("error") == 1) {
            answer.error = j.at("error").get<std::string>();
        } else {
            answer.result = j.at("result").get<buy_answer_success>();
        }
    }

    void to_json(nlohmann::json &j, const sell_request &request) {
        j["base"] = request.base;
        j["price"] = request.price;
        j["rel"] = request.rel;
        j["volume"] = request.volume;
    }

    void from_json(const nlohmann::json &j, sell_answer_success &contents) {
        j.get_to(contents.contents);
    }

    void from_json(const nlohmann::json &j, sell_answer &answer) {
        LOG_SCOPE_FUNCTION(INFO);
        if (j.count("error") == 1) {
            answer.error = j.at("error").get<std::string>();
        } else {
            answer.result = j.at("result").get<sell_answer_success>();
        }
    }

    template<typename RpcReturnType>
    RpcReturnType rpc_process_answer(const RestClient::Response &resp) noexcept {
        LOG_SCOPE_FUNCTION(INFO);
        RpcReturnType answer;
        DVLOG_F(loguru::Verbosity_INFO, "resp: {}", resp.body);
        if (resp.code != 200) {
            DVLOG_F(loguru::Verbosity_WARNING, "rpc answer code is not 200");
            answer.rpc_result_code = resp.code;
            answer.raw_result = resp.body;
            return answer;
        }

        try {
            auto json_answer = nlohmann::json::parse(resp.body);
            from_json(json_answer, answer);
            answer.rpc_result_code = resp.code;
            answer.raw_result = resp.body;
        }
        catch (const std::exception &error) {
            VLOG_F(loguru::Verbosity_ERROR, "{}", error.what());
            answer.rpc_result_code = -1;
            answer.raw_result = error.what();
        }
        return answer;
    }

    electrum_answer rpc_electrum(electrum_request &&request) {
        LOG_SCOPE_FUNCTION(INFO);
        auto json_data = template_request("electrum");
        to_json(json_data, request);
        DVLOG_F(loguru::Verbosity_INFO, "request: %s", json_data.dump().c_str());
        const auto resp = RestClient::post(endpoint, "application/json", json_data.dump());
        return rpc_process_answer<electrum_answer>(resp);
    }

    balance_answer rpc_balance(balance_request &&request) {
        LOG_SCOPE_FUNCTION(INFO);
        auto json_data = template_request("my_balance");
        to_json(json_data, request);
        DVLOG_F(loguru::Verbosity_INFO, "request: {}", json_data.dump());
        const auto resp = RestClient::post(endpoint, "application/json", json_data.dump());
        return rpc_process_answer<balance_answer>(resp);
    }

    tx_history_answer rpc_my_tx_history(tx_history_request &&request) {
        LOG_SCOPE_FUNCTION(INFO);
        auto json_data = template_request("my_tx_history");
        to_json(json_data, request);
        DVLOG_F(loguru::Verbosity_INFO, "request: %s", json_data.dump().c_str());
        const auto resp = RestClient::post(endpoint, "application/json", json_data.dump());
        return rpc_process_answer<tx_history_answer>(resp);
    }

    withdraw_answer rpc_withdraw(withdraw_request &&request) {
        LOG_SCOPE_FUNCTION(INFO);
        auto json_data = template_request("withdraw");
        to_json(json_data, request);
        DVLOG_F(loguru::Verbosity_INFO, "request: %s", json_data.dump().c_str());
        const auto resp = RestClient::post(endpoint, "application/json", json_data.dump());
        return rpc_process_answer<withdraw_answer>(resp);
    }

    send_raw_transaction_answer rpc_send_raw_transaction(send_raw_transaction_request &&request) {
        LOG_SCOPE_FUNCTION(INFO);
        auto json_data = template_request("send_raw_transaction");
        to_json(json_data, request);
        DVLOG_F(loguru::Verbosity_INFO, "request: %s", json_data.dump().c_str());
        const auto resp = RestClient::post(endpoint, "application/json", json_data.dump());
        return rpc_process_answer<send_raw_transaction_answer>(resp);
    }

    orderbook_answer rpc_orderbook(orderbook_request &&request) {
        LOG_SCOPE_FUNCTION(INFO);
        auto json_data = template_request("orderbook");
        to_json(json_data, request);
        DVLOG_F(loguru::Verbosity_INFO, "request: %s", json_data.dump().c_str());
        const auto resp = RestClient::post(endpoint, "application/json", json_data.dump());
        return rpc_process_answer<orderbook_answer>(resp);
    }

    buy_answer rpc_buy(buy_request &&request) {
        LOG_SCOPE_FUNCTION(INFO);
        auto json_data = template_request("buy");
        to_json(json_data, request);
        DVLOG_F(loguru::Verbosity_INFO, "request: %s", json_data.dump().c_str());
        const auto resp = RestClient::post(endpoint, "application/json", json_data.dump());
        return rpc_process_answer<buy_answer>(resp);
    }

    sell_answer rpc_sell(sell_request &&request) {
        LOG_SCOPE_FUNCTION(INFO);
        auto json_data = template_request("sell");
        to_json(json_data, request);
        DVLOG_F(loguru::Verbosity_INFO, "request: %s", json_data.dump().c_str());
        const auto resp = RestClient::post(endpoint, "application/json", json_data.dump());
        return rpc_process_answer<sell_answer>(resp);
    }
}
