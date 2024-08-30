#include <nlohmann/json.hpp>

#include "atomicdex/api/kdf/rpc_v2/rpc2.enable_eth_with_tokens.hpp"

namespace atomic_dex::kdf
{
    void to_json(nlohmann::json& j, const enable_eth_with_tokens_request_rpc& in)
    {
        j["ticker"] = in.ticker;
        j["nodes"] = in.nodes;
        j["tx_history"] = in.tx_history;
        j["get_balances"] = in.get_balances;
        j["erc20_tokens_requests"]  = in.erc20_tokens_requests;
        if (in.required_confirmations.has_value())
            j["required_confirmations"] = in.required_confirmations.value();
        if (in.requires_notarization.has_value())
            j["requires_notarization"] = in.requires_notarization.value();
        j["swap_contract_address"] = in.swap_contract_address;
        j["fallback_swap_contract"] = in.fallback_swap_contract;

        SPDLOG_DEBUG("enable_eth_with_tokens: {}", j.dump(4));
    }

    void to_json(nlohmann::json& j, const enable_eth_with_tokens_request_rpc::erc20_token_request_t& in)
    {
        j["ticker"] = in.ticker;
        if (in.required_confirmations)
            j["required_confirmations"] = in.required_confirmations.value();
    }

    void from_json(const nlohmann::json& json, enable_eth_with_tokens_result_rpc& out)
    {
        out.current_block = json["current_block"];
        out.eth_addresses_infos = json["eth_addresses_infos"].get<typeof(out.eth_addresses_infos)>();
        out.erc20_addresses_infos = json["erc20_addresses_infos"].get<typeof(out.erc20_addresses_infos)>();
    }
    
    void from_json(const nlohmann::json& json, enable_eth_with_tokens_result_rpc::derivation_method_t& out)
    {
        out.type = json["type"];
    }
    
    void from_json(const nlohmann::json& json, enable_eth_with_tokens_result_rpc::eth_address_infos_t& out)
    {
        out.derivation_method = json["derivation_method"];
        out.pubkey = json["pubkey"];
        out.balances = json["balances"];
    }
    
    void from_json(const nlohmann::json& json, enable_eth_with_tokens_result_rpc::erc20_address_infos_t& out)
    {
        out.derivation_method = json["derivation_method"];
        out.pubkey = json["pubkey"];
        out.balances = json["balances"].get<typeof(out.balances)>();
    }
}