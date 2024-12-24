#include <nlohmann/json.hpp>

#include "atomicdex/api/kdf/rpc_v2/rpc2.enable_erc20.hpp"

namespace atomic_dex::kdf
{
    void to_json(nlohmann::json& j, const enable_erc20_rpc_request& request)
    {
        j["ticker"] = request.ticker;
        if (request.activation_params.required_confirmations)
        {
            j["activation_params"]["required_confirmations"] = *request.activation_params.required_confirmations;
        }
        else
        {
            j["activation_params"] = nlohmann::json::object();
        }
    }

    void from_json(const nlohmann::json& j, enable_erc20_rpc_result& in)
    {
        j.at("platform_coin").get_to(in.platform_coin);
        j.at("required_confirmations").get_to(in.required_confirmations);
        j.at("balances").get_to<std::unordered_map<std::string, balance_infos>>(in.balances);
    }
}