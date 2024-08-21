//
// Created by Sztergbaum Roman on 27/03/2021.
//

//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/kdf/rpc_v1/rpc.recover_funds_of_swap.hpp"

namespace atomic_dex::kdf
{
    void
    to_json(nlohmann::json& j, const recover_funds_of_swap_request& cfg)
    {
        j["params"]         = nlohmann::json::object();
        j["params"]["uuid"] = cfg.swap_uuid;
    }

    void
    from_json(const nlohmann::json& j, recover_funds_of_swap_answer_success& answer)
    {
        j.at("action").get_to(answer.action);
        j.at("coin").get_to(answer.coin);
        j.at("tx_hash").get_to(answer.tx_hash);
        j.at("tx_hex").get_to(answer.tx_hex);
    }

    void
    from_json(const nlohmann::json& j, recover_funds_of_swap_answer& answer)
    {
        if (j.contains("error"))
        {
            answer.error = j.at("error").get<std::string>();
        }
        else
        {
            answer.result = j.at("result").get<recover_funds_of_swap_answer_success>();
        }
    }
}