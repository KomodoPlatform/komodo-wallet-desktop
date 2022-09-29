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
#include "atomicdex/api/mm2/rpc.enable.hpp"

//! Implementation RPC [enable]
namespace atomic_dex::mm2
{
    //! Serialization
    void
    to_json(nlohmann::json& j, const enable_request& cfg)
    {
        j["coin"] = cfg.coin_name;

        switch (cfg.coin_type)
        {
        case CoinType::ERC20:
        {
            j["gas_station_url"]        = cfg.gas_station_url;
            j["urls"]                   = cfg.urls;
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.erc_testnet_swap_contract_address : cfg.erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.erc_testnet_fallback_swap_contract_address : cfg.erc_fallback_swap_contract_address;
            break;
        }
        case CoinType::Matic:
        {
            j["gas_station_url"]        = cfg.is_testnet ? cfg.testnet_matic_gas_station_url : cfg.matic_gas_station_url;
            j["gas_station_decimals"]   = cfg.matic_gas_station_decimals;
            j["urls"]                   = cfg.urls;
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.matic_erc_testnet_swap_contract_address : cfg.matic_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.matic_erc_testnet_fallback_swap_contract_address : cfg.matic_erc_fallback_swap_contract_address;
            break;
        }
        case CoinType::Optimism:
        {
            j["urls"]                  = cfg.urls;
            j["swap_contract_address"] = cfg.optimism_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.optimism_erc_fallback_swap_contract_address;
            break;
        }
        case CoinType::Arbitrum:
        {
            j["urls"]                  = cfg.urls;
            j["swap_contract_address"] = cfg.arbitrum_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.arbitrum_erc_fallback_swap_contract_address;
            break;
        }
        case CoinType::BEP20:
        {
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.bnb_testnet_swap_contract_address : cfg.bnb_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.bnb_testnet_fallback_swap_contract_address : cfg.bnb_fallback_swap_contract_address;
            j["urls"]                   = cfg.urls;
            break;
        }
        case CoinType::AVX20:
        {
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.avax_erc_testnet_swap_contract_address : cfg.avax_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.avax_erc_testnet_fallback_swap_contract_address : cfg.avax_erc_fallback_swap_contract_address;
            j["urls"]                   = cfg.urls;
            break;
        }
        case CoinType::FTM20:
        {
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.ftm_erc_testnet_swap_contract_address : cfg.ftm_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.ftm_erc_testnet_fallback_swap_contract_address : cfg.ftm_erc_fallback_swap_contract_address;
            j["urls"]                   = cfg.urls;
            break;
        }
        case CoinType::HRC20:
        {
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.one_erc_testnet_swap_contract_address : cfg.one_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.one_erc_testnet_fallback_swap_contract_address : cfg.one_erc_fallback_swap_contract_address;
            j["urls"]                   = cfg.urls;
            break;
        }
        case CoinType::Ubiq:
        {
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.ubiq_erc_testnet_swap_contract_address : cfg.ubiq_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.ubiq_erc_testnet_fallback_swap_contract_address : cfg.ubiq_erc_fallback_swap_contract_address;
            j["urls"]                   = cfg.urls;
            break;
        }
        case CoinType::KRC20:
        {
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.krc_erc_testnet_swap_contract_address : cfg.krc_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.krc_erc_testnet_fallback_swap_contract_address : cfg.krc_erc_fallback_swap_contract_address;
            j["urls"]                   = cfg.urls;
            break;
        }
        case CoinType::Moonriver:
        {
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.movr_erc_testnet_swap_contract_address : cfg.movr_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.movr_erc_testnet_fallback_swap_contract_address : cfg.movr_erc_fallback_swap_contract_address;
            j["urls"]                   = cfg.urls;
            break;
        }
        case CoinType::Moonbeam:
        {
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.glmr_erc_testnet_swap_contract_address : cfg.glmr_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.glmr_erc_testnet_fallback_swap_contract_address : cfg.glmr_erc_fallback_swap_contract_address;
            j["urls"]                   = cfg.urls;
            break;
        }
        case CoinType::HecoChain:
        {
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.hco_erc_testnet_swap_contract_address : cfg.hco_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.hco_erc_testnet_fallback_swap_contract_address : cfg.hco_erc_fallback_swap_contract_address;
            j["urls"]                   = cfg.urls;
            break;
        }
        case CoinType::SmartBCH:
        {
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.sbch_erc_testnet_swap_contract_address : cfg.sbch_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.sbch_erc_testnet_fallback_swap_contract_address : cfg.sbch_erc_fallback_swap_contract_address;
            j["urls"]                   = cfg.urls;
            break;
        }
        case CoinType::EthereumClassic:
        {
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.etc_erc_testnet_swap_contract_address : cfg.etc_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.etc_erc_testnet_fallback_swap_contract_address : cfg.etc_erc_fallback_swap_contract_address;
            j["urls"]                   = cfg.urls;
            break;
        }
        case CoinType::RSK:
        {
            j["swap_contract_address"]  = cfg.is_testnet ? cfg.rsk_erc_testnet_swap_contract_address : cfg.rsk_erc_swap_contract_address;
            j["fallback_swap_contract"] = cfg.is_testnet ? cfg.rsk_erc_testnet_fallback_swap_contract_address : cfg.rsk_erc_fallback_swap_contract_address;
            j["urls"]                   = cfg.urls;
            break;
        }
        default:
            break;
        }

        j["tx_history"] = cfg.with_tx_history;
    }

    //! Deserialization
    void
    from_json(const nlohmann::json& j, enable_answer& cfg)
    {
        j.at("address").get_to(cfg.address);
        j.at("balance").get_to(cfg.balance);
        j.at("result").get_to(cfg.result);
        // SPDLOG_INFO("balance for {} is {}", cfg.address, cfg.balance);
    }
} // namespace atomic_dex::mm2
