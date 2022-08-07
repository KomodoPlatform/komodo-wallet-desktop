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

#pragma once

#include "atomicdex/config/electrum.cfg.hpp"
#include "format.address.hpp"
#include "generic.error.hpp"
#include "utxo.merge.params.hpp"
#include "balance.infos.hpp"

namespace mm2::api
{
    struct slp_token_request
    {
        std::string                ticker;
        std::optional<std::size_t> required_confirmations;
    };

    void to_json(nlohmann::json& j, const slp_token_request& cfg);

    struct enable_rpc_data
    {
        std::vector<atomic_dex::electrum_server> servers;
    };

    void to_json(nlohmann::json& j, const enable_rpc_data& cfg);

    struct enable_mode
    {
        // Native or Electrum
        std::string rpc{"Electrum"};

        enable_rpc_data rpc_data;
    };

    void to_json(nlohmann::json& j, const enable_mode& cfg);

    struct enable_bch_with_tokens_request
    {
        // string, mandatory. Ticker of the platform BCH protocol coin.
        std::string ticker;

        // bool, optional. If "true", allows bchd_urls to be empty.
        // Please mark that it is highly unsafe to do so as it may lead to invalid SLP transactions generation and following tokens burn.
        // Defaults to "false".
        std::optional<bool> allow_slp_unsafe_conf{std::nullopt};

        // an array of strings, mandatory. URLs of BCHD gRPC API servers that are used for SLP tokens transactions validation.
        // It's recommended to add as many servers as possible.
        // The URLs list can be found at https://bchd.fountainhead.cash/
        std::vector<std::string> bchd_urls;

        // Utxo RPC mode, mandatory. Value for native: { "rpc":"Native" }
        enable_mode mode;

        // bool, optional. Whether to enable tx history - if "true", spawns a background loop to store the local cache of address(es) transactions.
        // Defaults to "false".
        bool tx_history{true};

        // Array of SLP activation requests, mandatory. SLP activation requests contain mandatory ticker and optional required_confirmations fields.
        // If required_confirmations is not set for a token, then MM2 will use the confirmations setting from its coins config or platform coin.
        std::vector<slp_token_request> slp_token_requests;

        // Number (unsigned integer), optional. The value from the coins file will be used if not set.
        std::optional<std::size_t> required_confirmations;

        // bool, optional. Has no effect on BCH. Defaults to "false".
        std::optional<bool> requires_notarization;

        // address format, optional. Overwrites the address format from coins file, if set.
        // Value to use legacy/standard address format: { "format":"standard" }
        std::optional<format_address> address_format;

        // utxo merge params, optional.
        // If set spawns a background loop that checks the number of UTXOs every check_every seconds,
        // and merges max_merge_at_once to one if the total exceeds merge_at.
        // Useful for active traders as every swap leads to a new UTXO to occur on the address.
        std::optional<utxo_merge_params> utxo_merge_params;
    };

    void to_json(nlohmann::json& j, const enable_bch_with_tokens_request& cfg);

    struct derivation_infos
    {
        std::string type;
    };

    void from_json(const nlohmann::json& j, derivation_infos& answer);

    struct bch_address_infos
    {
        derivation_infos derivation_method;
        std::string      pubkey;
        balance_infos    balances;
    };

    void from_json(const nlohmann::json& j, bch_address_infos& answer);

    using bch_addresses_infos_registry = std::unordered_map<std::string, bch_address_infos>;

    struct slp_address_infos
    {
        derivation_infos                               derivation_method;
        std::string                                    pubkey;
        std::unordered_map<std::string, balance_infos> balances;
    };

    void from_json(const nlohmann::json& j, slp_address_infos& answer);

    using slp_addresses_infos_registry = std::unordered_map<std::string, slp_address_infos>;

    struct enable_bch_with_tokens_answer_success
    {
        std::size_t                  current_block;
        bch_addresses_infos_registry bch_addresses_infos;
        slp_addresses_infos_registry slp_addresses_infos;
    };

    void from_json(const nlohmann::json& j, enable_bch_with_tokens_answer_success& answer);

    struct enable_bch_with_tokens_answer
    {
        std::optional<enable_bch_with_tokens_answer_success> result;
        std::optional<generic_answer_error>                  error;
        std::string                                          raw_result;      ///< internal
        int                                                  rpc_result_code; ///< internal
    };

    void from_json(const nlohmann::json& j, enable_bch_with_tokens_answer& answer);
} // namespace mm2::api

namespace atomic_dex
{
    using t_enable_bch_with_tokens_request        = ::mm2::api::enable_bch_with_tokens_request;
    using t_enable_bch_with_tokens_answer         = ::mm2::api::enable_bch_with_tokens_answer;
    using t_enable_bch_with_tokens_answer_success = ::mm2::api::enable_bch_with_tokens_answer_success;
} // namespace atomic_dex