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

#include "atomic.dex.mm2.api.hpp"


namespace {
    nlohmann::json template_request(std::string method_name) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        return {{"method",   method_name},
                {"userpass", "atomix_dex_mm2_passphrase"}};
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
        auto resp = RestClient::post(endpoint, "application/json", json_data.dump());
        return rpc_process_answer<electrum_answer>(resp);
    }
}