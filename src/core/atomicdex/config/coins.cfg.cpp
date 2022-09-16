/******************************************************************************
 * Copyright © 2013-2022 The Komodo Platform Developers.                      *
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

//! Deps
#include <nlohmann/json.hpp>
#include <sstream>

//! Project Headers
#include "atomicdex/config/coins.cfg.hpp"

namespace atomic_dex
{
    void
    from_json(const nlohmann::json& j, coin_config& cfg)
    {
        j.at("coin").get_to(cfg.ticker);
        j.at("name").get_to(cfg.name);
        j.at("type").get_to(cfg.type);
        j.at("active").get_to(cfg.active);
        j.at("currently_enabled").get_to(cfg.currently_enabled);
        j.at("explorer_url").get_to(cfg.explorer_url);

        cfg.gui_ticker           = j.contains("gui_coin") ? j.at("gui_coin").get<std::string>() : cfg.ticker;
        cfg.minimal_claim_amount = cfg.is_claimable ? j.at("minimal_claim_amount").get<std::string>() : "0";
        cfg.coinpaprika_id       = j.contains("coinpaprika_id") ? j.at("coinpaprika_id").get<std::string>() : "test-coin";
        cfg.coingecko_id         = j.contains("coingecko_id") ? j.at("coingecko_id").get<std::string>() : "test-coin";
        cfg.nomics_id            = j.contains("nomics_id") ? j.at("nomics_id").get<std::string>() : "test-coin";
        cfg.is_claimable         = j.count("is_claimable") > 0;
        cfg.is_custom_coin       = j.contains("is_custom_coin") ? j.at("is_custom_coin").get<bool>() : false;
        cfg.is_testnet           = j.contains("is_testnet") ? j.at("is_testnet").get<bool>() : false;
        cfg.wallet_only          = j.contains("wallet_only") ? j.at("wallet_only").get<bool>() : false;

        if (j.contains("utxo_merge"))
        {
            cfg.utxo_merge = j.at("utxo_merge");
        }

        if (j.contains("mm2_backup"))
        {
            cfg.custom_backup = j.at("mm2_backup");
        }

        if (j.contains("activation_status"))
        {
            cfg.activation_status = j.at("activation_status").get<nlohmann::json>();
        }

        if (j.contains("electrum"))
        {
            cfg.electrum_urls = j.at("electrum").get<std::vector<electrum_server>>();
        }

        if (j.contains("nodes"))
        {
            cfg.urls = j.at("nodes").get<std::vector<std::string>>();
        }

        // Used for ZHTLC coins
        if (j.contains("light_wallet_d_servers"))
        {
            cfg.z_urls = j.at("light_wallet_d_servers").get<std::vector<std::string>>();
        }

        // Used for SLP coins
        if (j.contains("bchd_urls"))
        {
            cfg.bchd_urls = j.at("bchd_urls").get<std::vector<std::string>>();
            cfg.allow_slp_unsafe_conf = j.at("allow_slp_unsafe_conf").get<bool>();
        }

        if (j.contains("is_segwit_on"))
        {
            cfg.segwit = true;
            j.at("is_segwit_on").get_to(cfg.is_segwit_on);
            SPDLOG_INFO("coin: {} support segwit with current_segwit mode: {}", cfg.ticker, cfg.is_segwit_on);
        }

        if (j.contains("alias_ticker"))
        {
            cfg.alias_ticker = j.at("alias_ticker").get<std::string>();
        }

        if (j.contains("explorer_tx_url"))
        {
            j.at("explorer_tx_url").get_to(cfg.tx_uri);
        }

        if (j.contains("explorer_address_url"))
        {
            j.at("explorer_address_url").get_to(cfg.address_url);
        }

        // Set Coin Type
        if (cfg.type == "QRC-20")
        {
            cfg.coin_type = CoinType::QRC20;
        }
        else if (cfg.type == "ERC-20")
        {
            cfg.coin_type = CoinType::ERC20;
        }
        else if (cfg.type == "UTXO")
        {
            cfg.coin_type = CoinType::UTXO;
        }
        else if (cfg.type == "Smart Chain")
        {
            cfg.coin_type = CoinType::SmartChain;
        }
        else if (cfg.type == "BEP-20")
        {
            cfg.coin_type = CoinType::BEP20;
        }
        else if (cfg.type == "SLP")
        {
            cfg.coin_type = CoinType::SLP;
        }
        else if (cfg.type == "Matic")
        {
            cfg.coin_type = CoinType::Matic;
        }
        else if (cfg.type == "Optimism")
        {
            cfg.coin_type = CoinType::Optimism;
        }
        else if (cfg.type == "Arbitrum")
        {
            cfg.coin_type = CoinType::Arbitrum;
        }
        else if (cfg.type == "AVX-20")
        {
            cfg.coin_type = CoinType::AVX20;
        }
        else if (cfg.type == "FTM-20")
        {
            cfg.coin_type = CoinType::FTM20;
        }
        else if (cfg.type == "HRC-20")
        {
            cfg.coin_type = CoinType::HRC20;
        }
        else if (cfg.type == "Ubiq")
        {
            cfg.coin_type = CoinType::Ubiq;
        }
        else if (cfg.type == "KRC-20")
        {
            cfg.coin_type = CoinType::KRC20;
        }
        else if (cfg.type == "Moonriver")
        {
            cfg.coin_type = CoinType::Moonriver;
        }
        else if (cfg.type == "Moonbeam")
        {
            cfg.coin_type = CoinType::Moonbeam;
        }
        else if (cfg.type == "HecoChain")
        {
            cfg.coin_type = CoinType::HecoChain;
        }
        else if (cfg.type == "SmartBCH")
        {
            cfg.coin_type = CoinType::SmartBCH;
        }
        else if (cfg.type == "Ethereum Classic")
        {
            cfg.coin_type = CoinType::EthereumClassic;
        }
        else if (cfg.type == "RSK Smart Bitcoin")
        {
            cfg.coin_type = CoinType::RSK;
        }
        else if (cfg.type == "ZHTLC")
        {
            cfg.coin_type = CoinType::ZHTLC;
        }

        switch (cfg.coin_type)
        {
        case CoinType::QRC20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "tQTUM" : "QTUM";
            break;
        case CoinType::ERC20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "ETHR" : "ETH";
            cfg.is_erc_family          = true;
            break;
        case CoinType::BEP20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "BNBT" : "BNB";
            cfg.is_erc_family          = true;
            break;
        case CoinType::Matic:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "MATICTEST" : "MATIC";
            cfg.is_erc_family          = true;
            break;
        case CoinType::Optimism:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "ETHK-OPT20" : "ETH-OPT20";
            cfg.is_erc_family          = true;
            break;
        case CoinType::Arbitrum:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "ETHR-ARB20" : "ETH-ARB20";
            cfg.is_erc_family          = true;
            break;
        case CoinType::AVX20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "AVAXT" : "AVAX";
            cfg.is_erc_family          = true;
            break;
        case CoinType::FTM20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "FTMT" : "FTM";
            cfg.is_erc_family          = true;
            break;
        case CoinType::HRC20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "ONET" : "ONE";
            cfg.is_erc_family          = true;
            break;
        case CoinType::Ubiq:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "UBQT" : "UBQ";
            cfg.is_erc_family          = true;
            break;
        case CoinType::KRC20:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "KCST" : "KCS";
            cfg.is_erc_family          = true;
            break;
        case CoinType::Moonriver:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "MOVRT" : "MOVR";
            cfg.is_erc_family          = true;
            break;
        case CoinType::Moonbeam:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "GLMRT" : "GLMR";
            cfg.is_erc_family          = true;
            break;
        case CoinType::HecoChain:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "HTT" : "HT";
            cfg.is_erc_family          = true;
            break;
        case CoinType::SmartBCH:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "SBCHT" : "SBCH";
            cfg.is_erc_family          = true;
            break;
        case CoinType::EthereumClassic:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "ETCT" : "ETC";
            cfg.is_erc_family          = true;
            break;
        case CoinType::RSK:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "RBTCT" : "RBTC";
            cfg.is_erc_family          = true;
            break;
        case CoinType::SLP:
            cfg.has_parent_fees_ticker = true;
            cfg.fees_ticker            = cfg.is_testnet.value() ? "tBCH" : "BCH";
            break;
        case CoinType::ZHTLC:
            cfg.has_parent_fees_ticker = false;
            cfg.is_zhtlc_family        = true;
            cfg.fees_ticker            = cfg.ticker;
            break;
        default:
            cfg.has_parent_fees_ticker = false;
            cfg.fees_ticker            = cfg.ticker;
            break;
        }
    }

    void
    print_coins(std::vector<coin_config> coins)
    {
        std::stringstream ss;
        ss << "[";
        for (auto&& coin: coins) {
            ss << coin.ticker << " ";
        }
        ss << "]";
        SPDLOG_INFO("{}", ss.str());
    }

} // namespace atomic_dex
