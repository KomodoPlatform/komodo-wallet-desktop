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

#include <stdexcept>

#include <nlohmann/json.hpp>
#include <sstream>

#include "coins.cfg.hpp"

namespace
{
    CoinType
    get_coin_type_from_str(const std::string& coin_type)
    {
        if (coin_type == "QRC-20")
        {
            return CoinType::QRC20;
        }
        if (coin_type == "ERC-20")
        {
            return CoinType::ERC20;
        }
        if (coin_type == "EWT")
        {
            return CoinType::EWT;
        }
        if (coin_type == "UTXO")
        {
            return CoinType::UTXO;
        }
        if (coin_type == "Smart Chain")
        {
            return CoinType::SmartChain;
        }
        if (coin_type == "BEP-20")
        {
            return CoinType::BEP20;
        }
        if (coin_type == "SLP")
        {
            return CoinType::SLP;
        }
        if (coin_type == "PLG-20")
        {
            return CoinType::PLG20;
        }
        if (coin_type == "Matic")
        {
            return CoinType::PLG20;
        }
        if (coin_type == "Optimism")
        {
            return CoinType::Optimism;
        }
        if (coin_type == "Arbitrum")
        {
            return CoinType::Arbitrum;
        }
        if (coin_type == "AVX-20")
        {
            return CoinType::AVX20;
        }
        if (coin_type == "FTM-20")
        {
            return CoinType::FTM20;
        }
        if (coin_type == "HRC-20")
        {
            return CoinType::HRC20;
        }
        if (coin_type == "Ubiq")
        {
            return CoinType::Ubiq;
        }
        if (coin_type == "KRC-20")
        {
            return CoinType::KRC20;
        }
        if (coin_type == "Moonriver")
        {
            return CoinType::Moonriver;
        }
        if (coin_type == "Moonbeam")
        {
            return CoinType::Moonbeam;
        }
        if (coin_type == "HecoChain")
        {
            return CoinType::HecoChain;
        }
        if (coin_type == "SmartBCH")
        {
            return CoinType::SmartBCH;
        }
        if (coin_type == "Ethereum Classic")
        {
            return CoinType::EthereumClassic;
        }
        if (coin_type == "RSK Smart Bitcoin")
        {
            return CoinType::RSK;
        }
        if (coin_type == "TENDERMINT")
        {
            return CoinType::TENDERMINT;
        }
        if (coin_type == "TENDERMINTTOKEN")
        {
            return CoinType::TENDERMINTTOKEN;
        }
        if (coin_type == "ZHTLC")
        {
            return CoinType::ZHTLC;
        }
        SPDLOG_INFO("Invalid coin type: {}", coin_type);
        return CoinType::Invalid;
        // throw std::invalid_argument{"Undefined given coin type."};
    }
} // namespace

namespace atomic_dex
{
    bool
    is_wallet_only(std::string ticker)
    {
        return std::any_of(g_wallet_only_coins.begin(), g_wallet_only_coins.end(), [ticker](std::string x) { return ticker == x; });
    }
    bool
    is_default_coin(std::string ticker)
    {
        return std::any_of(g_default_coins.begin(), g_default_coins.end(), [ticker](std::string x) { return ticker == x; });
    }
    bool
    is_faucet_coin(std::string ticker)
    {
        return std::any_of(g_faucet_coins.begin(), g_faucet_coins.end(), [ticker](std::string x) { return ticker == x; });
    }
    bool
    is_vote_coin(std::string ticker)
    {
        return std::any_of(g_vote_coins.begin(), g_vote_coins.end(), [ticker](std::string x) { return ticker == x; });
    }

    void
    from_json(const nlohmann::json& j, coin_config_t& cfg)
    {
        j.at("coin").get_to(cfg.ticker);
        j.at("name").get_to(cfg.name);
        j.at("type").get_to(cfg.type);
        cfg.coin_type = get_coin_type_from_str(cfg.type);
        j.at("active").get_to(cfg.active);
        j.at("explorer_url").get_to(cfg.explorer_url);
        cfg.has_memos            = false;
        cfg.gui_ticker           = j.contains("gui_coin") ? j.at("gui_coin").get<std::string>() : cfg.ticker;
        cfg.parent_coin          = j.contains("parent_coin") ? j.at("parent_coin").get<std::string>() : cfg.ticker;
        cfg.minimal_claim_amount = cfg.is_claimable ? j.at("minimal_claim_amount").get<std::string>() : "0";
        cfg.coinpaprika_id       = j.contains("coinpaprika_id") ? j.at("coinpaprika_id").get<std::string>() : "test-coin";
        cfg.coingecko_id         = j.contains("coingecko_id") ? j.at("coingecko_id").get<std::string>() : "test-coin";
        cfg.livecoinwatch_id     = j.contains("livecoinwatch_id") ? j.at("livecoinwatch_id").get<std::string>() : "test-coin";
        cfg.is_claimable         = j.count("is_claimable") > 0;
        cfg.is_custom_coin       = j.contains("is_custom_coin") ? j.at("is_custom_coin").get<bool>() : false;
        cfg.is_testnet           = j.contains("is_testnet") ? j.at("is_testnet").get<bool>() : false;
        cfg.wallet_only          = is_wallet_only(cfg.ticker) ? is_wallet_only(cfg.ticker) : j.contains("wallet_only") ? j.at("wallet_only").get<bool>() : false;
        cfg.default_coin         = is_default_coin(cfg.ticker);
        cfg.is_faucet_coin       = is_faucet_coin(cfg.ticker);
        cfg.is_vote_coin         = is_vote_coin(cfg.ticker);
        cfg.checkpoint_height    = 0;
        cfg.checkpoint_blocktime = 0;
        using namespace std::chrono;

        if (j.contains("other_types"))
        {
            std::vector<std::string> other_types;

            j.at("other_types").get_to(other_types);
            cfg.other_types = std::set<CoinType>();
            for (const auto& other_type: other_types) { cfg.other_types->emplace(get_coin_type_from_str(other_type)); }
        }
        if (j.contains("merge_utxos"))
        {
            cfg.merge_utxos = j.at("merge_utxos");
        }
        if (j.contains("activation_status"))
        {
            cfg.activation_status = j.at("activation_status").get<nlohmann::json>();
        }
        if (j.contains("electrum"))
        {
            cfg.electrum_urls = j.at("electrum").get<std::vector<electrum_server>>();
        }
        // Used for SLP coins
        if (j.contains("bchd_urls"))
        {
            cfg.bchd_urls = j.at("bchd_urls").get<std::vector<std::string>>();
        }
        if (j.contains("nodes"))
        {
            // Todo: this is bad, we are using 2 times the required memory. Something can be improved here.
            cfg.urls            = j.at("nodes").get<std::vector<node>>();
            cfg.eth_family_urls = std::vector<std::string>();
            cfg.eth_family_urls.value().reserve(cfg.urls.value().size());
            for (const auto& url: cfg.urls.value()) { cfg.eth_family_urls->push_back(url.url); }
        }
        if (j.contains("rpc_urls"))
        {
            cfg.rpc_urls = j.at("rpc_urls").get<std::vector<node>>();
        }
        if (j.contains("allow_slp_unsafe_conf"))
        {
            cfg.allow_slp_unsafe_conf = j.at("allow_slp_unsafe_conf").get<bool>();
        }
        // Used for ZHTLC coins
        if (j.contains("light_wallet_d_servers"))
        {
            cfg.z_urls = j.at("light_wallet_d_servers").get<std::vector<std::string>>();
        }
        if (j.contains("checkpoint_blocktime"))
        {
            cfg.checkpoint_blocktime = j.at("checkpoint_blocktime").get<int>();
        }
        if (j.contains("checkpoint_height"))
        {
            cfg.checkpoint_height = j.at("checkpoint_height").get<int>();
        }
        if (j.contains("alias_ticker"))
        {
            cfg.alias_ticker = j.at("alias_ticker").get<std::string>();
        }
        // Explorer url suffixes
        if (j.contains("explorer_tx_url"))
        {
            j.at("explorer_tx_url").get_to(cfg.tx_uri);
        }
        if (j.contains("explorer_block_url"))
        {
            j.at("explorer_block_url").get_to(cfg.block_uri);
        }
        if (j.contains("explorer_address_url"))
        {
            j.at("explorer_address_url").get_to(cfg.address_uri);
        }
        // Swap contract addresses
        if (j.contains("swap_contract_address"))
        {
            cfg.swap_contract_address = j["swap_contract_address"];
        }
        if (j.contains("fallback_swap_contract"))
        {
            cfg.fallback_swap_contract = j["fallback_swap_contract"];
        }

        // Gas station urls
        if (j.contains("gas_station_url"))
        {
            cfg.gas_station_url = j.at("gas_station_url").get<std::string>();
        }
        if (j.contains("matic_gas_station_url"))
        {
            cfg.matic_gas_station_url = j.at("matic_gas_station_url").get<std::string>();
        }
        if (j.contains("testnet_matic_gas_station_url"))
        {
            cfg.testnet_matic_gas_station_url = j.at("testnet_matic_gas_station_url").get<std::string>();
        }
        if (j.contains("matic_gas_station_decimals"))
        {
            cfg.matic_gas_station_decimals = j.at("matic_gas_station_decimals").get<std::size_t>();
        }


        switch (cfg.coin_type)
        {
        case CoinType::QRC20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "tQTUM" : "QTUM";
            break;
        case CoinType::ERC20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "ETHR" : "ETH";
            cfg.is_erc_family          = true;
            break;
        case CoinType::BEP20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "BNBT" : "BNB";
            cfg.is_erc_family          = true;
            break;
        case CoinType::PLG20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "MATICTEST" : "MATIC";
            cfg.is_erc_family          = true;
            break;
        case CoinType::Optimism:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = "ETH-OPT20";
            cfg.is_erc_family          = true;
            break;
        case CoinType::Arbitrum:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = "ETH-ARB20";
            cfg.is_erc_family          = true;
            break;
        case CoinType::EWT:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = "EWT";
            cfg.is_erc_family          = true;
            break;
        case CoinType::AVX20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "AVAXT" : "AVAX";
            cfg.is_erc_family          = true;
            break;
        case CoinType::FTM20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "FTMT" : "FTM";
            cfg.is_erc_family          = true;
            break;
        case CoinType::HRC20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "ONET" : "ONE";
            cfg.is_erc_family          = true;
            break;
        case CoinType::Ubiq:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "UBQT" : "UBQ";
            cfg.is_erc_family          = true;
            break;
        case CoinType::KRC20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "KCST" : "KCS";
            cfg.is_erc_family          = true;
            break;
        case CoinType::Moonriver:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "MOVRT" : "MOVR";
            cfg.is_erc_family          = true;
            break;
        case CoinType::Moonbeam:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "GLMRT" : "GLMR";
            cfg.is_erc_family          = true;
            break;
        case CoinType::HecoChain:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "HTT" : "HT";
            cfg.is_erc_family          = true;
            break;
        case CoinType::SmartBCH:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "SBCHT" : "SBCH";
            cfg.is_erc_family          = true;
            break;
        case CoinType::EthereumClassic:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "ETCT" : "ETC";
            cfg.is_erc_family          = true;
            break;
        case CoinType::RSK:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "RBTCT" : "RBTC";
            cfg.is_erc_family          = true;
            break;
        case CoinType::SLP:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value_or(false) ? "tBCH" : "BCH";
            break;
        case CoinType::TENDERMINT:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.parent_coin;
            cfg.has_memos              = true;
            break;
        case CoinType::TENDERMINTTOKEN:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.parent_coin;
            cfg.has_memos              = true;
            break;
        case CoinType::ZHTLC:
            cfg.has_parent_fees_ticker = false;
            cfg.is_zhtlc_family        = true;
            cfg.fees_ticker            = cfg.ticker;
            cfg.has_memos              = true;
            break;
        case CoinType::Invalid:
            cfg.has_parent_fees_ticker = false;
            cfg.fees_ticker            = cfg.ticker;
            break;
        default:
            cfg.has_parent_fees_ticker = false;
            cfg.fees_ticker            = cfg.ticker;
            break;
        }
    }

    void
    print_coins(std::vector<coin_config_t> coins)
    {
        std::stringstream ss;
        ss << "[";
        for (auto&& coin: coins) { ss << coin.ticker << " "; }
        ss << "]";
        SPDLOG_INFO("{}", ss.str());
    }
} // namespace atomic_dex
