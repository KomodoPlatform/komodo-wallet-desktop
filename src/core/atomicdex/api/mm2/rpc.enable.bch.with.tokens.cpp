/******************************************************************************
 * Copyright © 2013-2022 The Komodo Platform Developers.                      *
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

//! Dependencies
#include <nlohmann/json.hpp>

//! Project Headers
#include "rpc.enable.bch.with.tokens.hpp"

namespace mm2::api
{
    void
    to_json(nlohmann::json& j, const slp_token_request& cfg)
    {
        j["ticker"] = cfg.ticker;
        if (cfg.required_confirmations.has_value())
        {
            j["required_confirmations"] = cfg.required_confirmations.value();
        }
    }

    void
    to_json(nlohmann::json& j, const enable_rpc_data& cfg)
    {
        j["servers"] = cfg.servers;
    }

    void
    to_json(nlohmann::json& j, const enable_mode& cfg)
    {
        j["rpc"] = cfg.rpc;
        j["rpc_data"] = cfg.rpc_data;
    }

    void
    to_json(nlohmann::json& j, const enable_bch_with_tokens_request& cfg)
    {
        nlohmann::json obj = nlohmann::json::object();
        obj["ticker"] = cfg.ticker;
        obj["bchd_urls"] = cfg.bchd_urls;
        obj["tx_history"] = cfg.tx_history;
        obj["allow_slp_unsafe_conf"] = cfg.allow_slp_unsafe_conf.value_or(false);
        obj["mode"] = cfg.mode;
        obj["slp_tokens_requests"] = cfg.slp_token_requests;
        if (cfg.required_confirmations.has_value()) {
            obj["required_confirmations"] = cfg.required_confirmations.value();
        }
        if (cfg.requires_notarization.has_value()) {
            obj["requires_notarization"] = cfg.requires_notarization.value();
        }
        if (cfg.address_format.has_value()) {
            obj["address_format"] = cfg.address_format.value();
        }
        if (cfg.utxo_merge_params.has_value()) {
            obj["utxo_merge_params"] = cfg.utxo_merge_params.value();
        }
        if (j.contains("mmrpc") && j.at("mmrpc").get<std::string>() == "2.0")
        {
            j["params"] = obj;
        }
    }

    void
    from_json(const nlohmann::json& j, derivation_infos& answer)
    {
        answer.type = j.at("type").get<std::string>();
    }

    void
    from_json(const nlohmann::json& j, bch_address_infos& answer)
    {
        answer.derivation_method = j.at("derivation_method").get<derivation_infos>();
        answer.pubkey = j.at("pubkey").get<std::string>();
        answer.balances = j.at("balances").get<balance_infos>();
    }

    void
    from_json(const nlohmann::json& j, slp_address_infos& answer)
    {
        answer.derivation_method = j.at("derivation_method").get<derivation_infos>();
        answer.pubkey = j.at("pubkey").get<std::string>();
        answer.balances = j.at("balances").get<std::unordered_map<std::string, balance_infos>>();
    }

    void
    from_json(const nlohmann::json& j, enable_bch_with_tokens_answer_success& answer)
    {
        answer.current_block = j.at("current_block").get<std::size_t>();
        answer.bch_addresses_infos = j.at("bch_addresses_infos").get<bch_addresses_infos_registry>();
        answer.slp_addresses_infos = j.at("slp_addresses_infos").get<slp_addresses_infos_registry>();
    }

    void
    from_json(const nlohmann::json& j, enable_bch_with_tokens_answer& answer)
    {
        if (j.count("error") >= 1)
        {
            answer.error = j;
        }
        else
        {
            if (j.contains("result") && j.contains("mmrpc") && j.at("mmrpc").get<std::string>() == "2.0")
            {
                answer.result = j.at("result").get<enable_bch_with_tokens_answer_success>();
            }
        }
    }
} // namespace mm2::api