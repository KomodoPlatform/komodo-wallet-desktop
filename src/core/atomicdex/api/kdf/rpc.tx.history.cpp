//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "rpc.tx.history.hpp"

namespace atomic_dex::kdf
{
    void to_json(nlohmann::json& j, const tx_history_request& cfg)
    {
        nlohmann::json obj = nlohmann::json::object();
        
        obj["coin"]  = cfg.coin;
        obj["limit"] = cfg.limit;
        if (cfg.paging_options.has_value() && j.contains("mmrpc") && j.at("mmrpc").get<std::string>() == "2.0")
        {
            obj["paging_options"] = cfg.paging_options.value();
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

    void from_json(const nlohmann::json& j, sync_status_additional_error& answer)
    {
        j.at("code").get_to(answer.code);
        j.at("message").get_to(answer.message);
    }


    void from_json(const nlohmann::json& j, sync_status_eth_erc_20_coins& answer)
    {
        j.at("blocks_left").get_to(answer.blocks_left);
    }

    void
    from_json(const nlohmann::json& j, sync_status_regular_coins& answer)
    {
        j.at("transactions_left").get_to(answer.transactions_left);
    }

    void
    from_json(const nlohmann::json& j, sync_status_additional_infos& answer)
    {
        if (j.count("error") == 1)
        {
            answer.error = j.get<sync_status_additional_error>();
        }
        else if (j.count("blocks_left") == 1)
        {
            answer.erc_infos = j.get<sync_status_eth_erc_20_coins>();
        }
        else if (j.count("transactions_left") == 1)
        {
            answer.regular_infos = j.get<sync_status_regular_coins>();
        }
    }

    void
    from_json(const nlohmann::json& j, t_sync_status& answer)
    {
        j.at("state").get_to(answer.state);
        if (j.count("additional_info") == 1)
        {
            answer.additional_info = j.at("additional_info").get<sync_status_additional_infos>();
        }
    }

    void
    from_json(const nlohmann::json& j, tx_history_answer_success& answer)
    {
        if (j.contains("from_id"))
        {
            if (not j.at("from_id").is_null())
                j.at("from_id").get_to(answer.from_id);
        }
        if (j.contains("current_block"))
        {
            j.at("current_block").get_to(answer.current_block);
        }
        j.at("limit").get_to(answer.limit);
        j.at("skipped").get_to(answer.skipped);
        if (j.contains("sync_status"))
        {
            j.at("sync_status").get_to(answer.sync_status);
        }
        j.at("total").get_to(answer.total);
        j.at("transactions").get_to(answer.transactions);
    }

    void
    from_json(const nlohmann::json& j, tx_history_answer& answer)
    {
        if (j.contains("error"))
        {
            answer.error = j.at("error").get<std::string>();
        }
        else
        {
            answer.result = j.at("result").get<tx_history_answer_success>();
        }
    }
} // namespace atomic_dex::kdf