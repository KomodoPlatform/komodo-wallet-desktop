#pragma once

#include <optional>
#include <string>

//! Deps
#include <nlohmann/json_fwd.hpp>

namespace atomic_dex::mm2
{
    struct fee_regular_coin
    {
        std::string amount;
    };

    void from_json(const nlohmann::json& j, fee_regular_coin& cfg);

    struct fee_erc_coin
    {
        std::string coin;
        std::size_t gas;
        std::string gas_price;
        std::string total_fee;
    };

    void from_json(const nlohmann::json& j, fee_erc_coin& cfg);

    struct fee_qrc_coin
    {
        std::string coin;
        std::string miner_fee;
        std::size_t gas_limit;
        std::size_t gas_price;
        std::string total_gas_fee;
    };

    void from_json(const nlohmann::json& j, fee_qrc_coin& cfg);

    struct fees_data
    {
        std::optional<fee_regular_coin> normal_fees;        ///< btc, kmd based coins
        std::optional<fee_erc_coin>     erc_fees;           ///< eth based coins
        std::optional<fee_qrc_coin>     qrc_fees;           // Qtum based coin
    };

    void from_json(const nlohmann::json& j, fees_data& cfg);

    struct transaction_data
    {
        std::size_t                timestamp;
        std::vector<std::string>   from;
        std::vector<std::string>   to;
        fees_data                  fee_details;
        std::size_t                block_height;
        std::string                coin;
        std::string                spent_by_me;
        std::string                received_by_me;
        std::string                my_balance_change;
        std::string                total_amount{"0"};
        std::string                tx_hash;
        std::string                tx_hex;
        std::string                timestamp_as_date; ///< human readeable timestamp
        std::optional<std::string> transaction_fee;
        std::optional<std::string> internal_id;
        std::optional<std::size_t> confirmations;
    };

    void from_json(const nlohmann::json& j, transaction_data& cfg);
}