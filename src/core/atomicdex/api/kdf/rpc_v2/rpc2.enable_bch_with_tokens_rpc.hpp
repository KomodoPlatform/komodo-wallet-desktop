/******************************************************************************
 * Copyright © 2013-2024 The Komodo Platform Developers.                      *
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

#include <vector>

#include "atomicdex/config/electrum.cfg.hpp"
#include "atomicdex/api/kdf/address_format.hpp"
#include "atomicdex/api/kdf/balance_infos.hpp"
#include "atomicdex/api/kdf/rpc.hpp"
#include "atomicdex/api/kdf/utxo_merge_params.hpp"

namespace atomic_dex::kdf
{
    struct enable_bch_with_tokens_rpc
    {
        static constexpr auto endpoint = "enable_bch_with_tokens";
        static constexpr bool is_v2     = true;

        struct expected_request_type
        {
            struct mode_t
            {
                struct data { std::vector<electrum_server> servers; };

                std::string rpc{"Electrum"};
                data        rpc_data;
            };
            struct slp_token_request_t
            {
                std::string         ticker;
                std::optional<int>  required_confirmations;
            };

            std::string                         ticker;
            std::optional<bool>                 allow_slp_unsafe_conf{false};
            std::vector<std::string>            bchd_urls;
            mode_t                              mode;
            bool                                tx_history{true};
            std::vector<slp_token_request_t>    slp_tokens_requests;
            std::optional<int>                  required_confirmations;
            std::optional<bool>                 requires_notarization;
            std::optional<address_format_t>     address_format;
            std::optional<utxo_merge_params_t>  utxo_merge_params;
        };
        
        struct expected_result_type
        {
            struct derivation_method_t { std::string type; };
            struct bch_address_infos_t
            {
                derivation_method_t derivation_method;
                std::string         pubkey;
                balance_infos        balances;
            };
            struct slp_address_infos_t
            {
                derivation_method_t                             derivation_method;
                std::string                                     pubkey;
                std::unordered_map<std::string, balance_infos>   balances;
            };

            std::size_t current_block;
            std::unordered_map<std::string, bch_address_infos_t> bch_addresses_infos;
            std::unordered_map<std::string, slp_address_infos_t> slp_addresses_infos;
        };

        using expected_error_type = rpc_basic_error_type;

        expected_request_type                   request;
        std::optional<expected_result_type>     result;
        std::optional<expected_error_type>      error;
        std::string                             raw_result;
    };

    using enable_bch_with_tokens_request_rpc    = enable_bch_with_tokens_rpc::expected_request_type;
    using enable_bch_with_tokens_result_rpc     = enable_bch_with_tokens_rpc::expected_result_type;
    using enable_bch_with_tokens_error_rpc      = enable_bch_with_tokens_rpc::expected_error_type;

    void to_json(nlohmann::json& j, const enable_bch_with_tokens_request_rpc& in);
    void to_json(nlohmann::json& j, const enable_bch_with_tokens_request_rpc::mode_t& in);
    void to_json(nlohmann::json& j, const enable_bch_with_tokens_request_rpc::mode_t::data& in);
    void to_json(nlohmann::json& j, const address_format_t& in);
    void to_json(nlohmann::json& j, const enable_bch_with_tokens_request_rpc::slp_token_request_t& in);
    void from_json(const nlohmann::json& json, enable_bch_with_tokens_result_rpc& out);
    void from_json(const nlohmann::json& json, enable_bch_with_tokens_result_rpc::derivation_method_t& out);
    void from_json(const nlohmann::json& json, enable_bch_with_tokens_result_rpc::bch_address_infos_t& out);
    void from_json(const nlohmann::json& json, enable_bch_with_tokens_result_rpc::slp_address_infos_t& out);
}