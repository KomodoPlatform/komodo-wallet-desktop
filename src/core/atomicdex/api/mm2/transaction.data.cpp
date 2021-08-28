//
// Created by Sztergbaum Roman on 08/06/2021.
//

//! Deps
#include <nlohmann/json.hpp>

//! Our Headers
#include "atomicdex/api/mm2/transaction.data.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

namespace mm2::api
{
    void
    from_json(const nlohmann::json& j, fee_regular_coin& cfg)
    {
        j.at("amount").get_to(cfg.amount);
    }

    void
    from_json(const nlohmann::json& j, fee_erc_coin& cfg)
    {
        j.at("coin").get_to(cfg.coin);
        j.at("gas").get_to(cfg.gas);
        j.at("gas_price").get_to(cfg.gas_price);
        j.at("total_fee").get_to(cfg.total_fee);
    }

    void
    from_json(const nlohmann::json& j, fee_qrc_coin& cfg)
    {
        j.at("coin").get_to(cfg.coin);
        j.at("gas_limit").get_to(cfg.gas_limit);
        j.at("gas_price").get_to(cfg.gas_price);
        j.at("miner_fee").get_to(cfg.miner_fee);
        j.at("total_gas_fee").get_to(cfg.total_gas_fee);
    }

    void
    from_json(const nlohmann::json& j, fees_data& cfg)
    {
        if (j.count("amount") == 1)
        {
            cfg.normal_fees = fee_regular_coin{};
            from_json(j, cfg.normal_fees.value());
        }
        else if (auto coin = j.at("coin").get<std::string>(); coin == "ETH" || coin == "BNB" || coin == "BNBT" || coin == "ETHR")
        {
            cfg.erc_fees = fee_erc_coin{};
            from_json(j, cfg.erc_fees.value());
        }
        else if (j.at("coin").get<std::string>() == "QTUM" || j.at("coin").get<std::string>() == "tQTUM")
        {
            cfg.qrc_fees = fee_qrc_coin{};
            from_json(j, cfg.qrc_fees.value());
        }
    }

    void
    from_json(const nlohmann::json& j, transaction_data& cfg)
    {
        j.at("block_height").get_to(cfg.block_height);
        j.at("coin").get_to(cfg.coin);
        if (j.contains("confirmations"))
        {
            cfg.confirmations = j.at("confirmations").get<std::size_t>();
        }
        j.at("fee_details").get_to(cfg.fee_details);
        j.at("from").get_to(cfg.from);
        if (cfg.from.empty() && cfg.coin == "FIRO")
        {
            cfg.from.emplace_back("Lelantusjsplit (Hidden)");
        }
        j.at("internal_id").get_to(cfg.internal_id);
        j.at("my_balance_change").get_to(cfg.my_balance_change);
        j.at("received_by_me").get_to(cfg.received_by_me);
        j.at("spent_by_me").get_to(cfg.spent_by_me);
        j.at("timestamp").get_to(cfg.timestamp);
        j.at("to").get_to(cfg.to);
        j.at("total_amount").get_to(cfg.total_amount);
        j.at("tx_hash").get_to(cfg.tx_hash);
        j.at("tx_hex").get_to(cfg.tx_hex);

        std::string s         = atomic_dex::utils::to_human_date<std::chrono::seconds>(cfg.timestamp, "%e %b %Y, %H:%M");
        cfg.timestamp_as_date = std::move(s);
    }
} // namespace mm2::api