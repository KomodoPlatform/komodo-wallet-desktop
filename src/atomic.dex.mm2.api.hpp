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
#include <restclient-cpp/restclient.h>
#include <loguru.hpp>
#include <nlohmann/json.hpp>
#include "atomic.dex.coins.config.hpp"

namespace mm2::api {
    static constexpr const char* endpoint = "http://127.0.0.1:7783";

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


    electrum_answer rpc_electrum(electrum_request&& request);

    template<typename RpcReturnType>
    static RpcReturnType rpc_process_answer(const RestClient::Response &resp) noexcept;
}