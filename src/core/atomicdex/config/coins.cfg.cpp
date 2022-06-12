/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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

//! Project Headers
#include "atomicdex/config/coins.cfg.hpp"

namespace atomic_dex
{
    void
    from_json(const nlohmann::json& j, coin_config& cfg)
    {
        j.at("coin").get_to(cfg.ticker);
        cfg.gui_ticker = j.contains("gui_coin") ? j.at("gui_coin").get<std::string>() : cfg.ticker;
        j.at("name").get_to(cfg.name);
        j.at("type").get_to(cfg.type);
        if (j.contains("mm2_backup"))
        {
            cfg.custom_backup = j.at("mm2_backup");
        }
        if (j.contains("electrum"))
        {
            cfg.electrum_urls = j.at("electrum").get<std::vector<electrum_server>>();
        }
        if (j.contains("nodes"))
        {
            cfg.urls = j.at("nodes").get<std::vector<std::string>>();
        }
        cfg.is_claimable         = j.count("is_claimable") > 0;
        cfg.minimal_claim_amount = cfg.is_claimable ? j.at("minimal_claim_amount").get<std::string>() : "0";
        j.at("active").get_to(cfg.active);
        j.at("currently_enabled").get_to(cfg.currently_enabled);

        if (j.contains("coinpaprika_id"))
        {
            j.at("coinpaprika_id").get_to(cfg.coinpaprika_id);
        }
        else
        {
            cfg.coinpaprika_id = "test-coin";
        }

        if (j.contains("nomics_id"))
        {
            j.at("nomics_id").get_to(cfg.nomics_id);
        }
        else
        {
            cfg.nomics_id = "test-coin";
        }

        if (j.contains("coingecko_id"))
        {
            j.at("coingecko_id").get_to(cfg.coingecko_id);
        }
        else
        {
            cfg.coingecko_id = "test-coin";
        }

        if (j.contains("is_custom_coin"))
        {
            cfg.is_custom_coin = true;
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

        j.at("explorer_url").get_to(cfg.explorer_url);
        if (j.contains("explorer_tx_url"))
        {
            j.at("explorer_tx_url").get_to(cfg.tx_uri);
        }
        if (j.contains("explorer_address_url"))
        {
            j.at("explorer_address_url").get_to(cfg.address_url);
        }
        if (j.contains("is_testnet"))
        {
            cfg.is_testnet = j.at("is_testnet").get<bool>();
        }
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
        if (j.contains("wallet_only"))
        {
            cfg.wallet_only = j.at("wallet_only").get<bool>();
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
            cfg.fees_ticker            = "BCH";
            break;
        default:
            cfg.has_parent_fees_ticker = false;
            cfg.fees_ticker            = cfg.ticker;
            break;
        }
    }
} // namespace atomic_dex
