//
// Created by Sztergbaum Roman on 08/06/2021.
//

//! Deps
#include <nlohmann/json.hpp>

//! Our Headers
#include "atomicdex/utilities/global.utilities.hpp"
#include "rpc2.withdraw.hpp"

namespace atomic_dex::kdf
{
    void
    to_json(nlohmann::json& j, const withdraw_fees& cfg)
    {
        j["type"] = cfg.type;
        if (cfg.type == "EthGas" || cfg.type == "otherGas")
        {
            j["gas"]       = cfg.gas_limit.value_or(55000);
            j["gas_price"] = cfg.gas_price.value();
        }
        else if (cfg.type == "Qrc20Gas")
        {
            j["gas_limit"] = cfg.gas_limit.value_or(40);
            j["gas_price"] = std::stoi(cfg.gas_price.value());
        }
        else if (cfg.type == "CosmosGas")
        {
            j["type"] = "CosmosGas";
            j["gas_limit"]       = cfg.gas_limit.value_or(55000);
            j["gas_price"]       = cfg.cosmos_gas_price.value_or(0.03);
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

        obj["params"]["coin"]   = cfg.coin;
        obj["params"]["amount"] = cfg.amount;
        obj["params"]["to"]     = cfg.to;
        obj["params"]["max"]    = cfg.max;
        if (cfg.ibc_source_channel.has_value())
        {
            if (cfg.ibc_source_channel.value() != "")
            {
                obj["params"]["ibc_source_channel"] = cfg.ibc_source_channel.value();
            }
        }
        if (cfg.memo.has_value())
        {
            obj["params"]["memo"] = cfg.memo.value();
        }
        if (cfg.fees.has_value())
        {
            obj["params"]["fee"] = cfg.fees.value();
        }
        j.update(obj);
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
            answer.result = j.at("result").get<transaction_data>();
        }
    }
} // namespace atomic_dex::kdf