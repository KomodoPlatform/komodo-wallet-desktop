//
// Created by Sztergbaum Roman on 08/06/2021.
//

//! Deps
#include <nlohmann/json.hpp>

//! Our Headers
#include "rpc.withdraw.hpp"

namespace mm2::api
{
    void
    to_json(nlohmann::json& j, const withdraw_fees& cfg)
    {
        j["type"] = cfg.type;
        if (cfg.type == "EthGas")
        {
            j["gas"]       = cfg.gas_limit.value_or(55000);
            j["gas_price"] = cfg.gas_price.value();
        }
        else if (cfg.type == "Qrc20Gas")
        {
            j["gas_limit"] = cfg.gas_limit.value_or(40);
            j["gas_price"] = std::stoi(cfg.gas_price.value());
        }
        else if (cfg.type == "otherGas")
        {
            j["type"] = "EthGas";
            j["gas"]       = cfg.gas_limit.value_or(55000);
            j["gas_price"] = std::stoi(cfg.gas_price.value());
        }
        else
        {
            j["amount"] = cfg.amount.value();
        }
    }

    void
    to_json(nlohmann::json& j, const withdraw_request& cfg)
    {
        nlohmann::json obj = nlohmann::json::object();

        obj["coin"]   = cfg.coin;
        obj["amount"] = cfg.amount;
        obj["to"]     = cfg.to;
        obj["max"]    = cfg.max;
        if (cfg.fees.has_value())
        {
            obj["fee"] = cfg.fees.value();
        }
        if (j.contains("mmrpc") && j.at("mmrpc").get<std::string>() == "2.0")
        {
            j["params"] = obj;
        }
        else
        {
            j.update(obj);
        }
    }

    void
    from_json(const nlohmann::json& j, withdraw_answer& answer)
    {
        if (j.count("error") >= 1)
        {
            answer.error = j;
        }
        else
        {
            if (j.contains("result") && j.contains("mmrpc") && j.at("mmrpc").get<std::string>() == "2.0")
            {
                answer.result = j.at("result").get<transaction_data>();
            }
            else
            {
                answer.result = j.get<transaction_data>();
            }
        }
    }
} // namespace mm2::api