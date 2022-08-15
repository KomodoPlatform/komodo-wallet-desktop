#include <nlohmann/json.hpp>

#include "enable_slp_rpc.hpp"

namespace atomic_dex::mm2
{
    void from_json(const nlohmann::json& j, enable_slp_rpc_result& in)
    {
        j.at("token_id").get_to(in.token_id);
        j.at("platform_coin").get_to(in.platform_coin);
        j.at("required_confirmations").get_to(in.required_confirmations);
        j.at("token_id").get_to(in.token_id);
        j.at("balances").get_to<std::unordered_map<std::string, balance_info>>(in.balances);
    }
}