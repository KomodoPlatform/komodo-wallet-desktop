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

#include <stdexcept>

#include <nlohmann/json.hpp>

#include "coins.cfg.hpp"

namespace
{
    CoinType get_coin_type_from_str(const std::string& coin_type)
    {
        if (coin_type == "QRC-20")
        {
            return CoinType::QRC20;
        }
        if (coin_type == "ERC-20")
        {
            return CoinType::ERC20;
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
        if (coin_type == "Matic")
        {
            return CoinType::Matic;
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
        throw std::invalid_argument{"Undefined given coin type."};
    }
}

namespace atomic_dex
{
    void
    from_json(const nlohmann::json& j, coin_config& cfg)
    {
        j.at("coin").get_to(cfg.ticker);
        cfg.gui_ticker = j.contains("gui_coin") ? j.at("gui_coin").get<std::string>() : cfg.ticker;
        j.at("name").get_to(cfg.name);
        j.at("type").get_to(cfg.type);
        if (j.contains("other_types"))
        {
            std::vector<std::string> other_types;
            
            j.at("other_types").get_to(other_types);
            cfg.other_types = std::set<CoinType>();
            for (const auto& other_type : other_types)
            {
                cfg.other_types->emplace(get_coin_type_from_str(other_type));
            }
        }
        if (j.contains("mm2_backup"))
        {
            cfg.custom_backup = j.at("mm2_backup");
        }
        if (j.contains("electrum"))
        {
            cfg.electrum_urls = j.at("electrum").get<std::vector<electrum_server>>();
        }
        if (j.contains("bchd_urls"))
        {
            cfg.bchd_urls = j.at("bchd_urls").get<std::vector<std::string>>();
        }
        if (j.contains("allow_slp_unsafe_conf"))
        {
            cfg.allow_slp_unsafe_conf = j.at("allow_slp_unsafe_conf").get<bool>();
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
        cfg.coin_type = get_coin_type_from_str(cfg.type);
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
            cfg.fees_ticker            = cfg.is_testnet.value() ? "tBCH" : "BCH";
            break;
        default:
            cfg.has_parent_fees_ticker = false;
            cfg.fees_ticker            = cfg.ticker;
            break;
        }
    }
} // namespace atomic_dex
