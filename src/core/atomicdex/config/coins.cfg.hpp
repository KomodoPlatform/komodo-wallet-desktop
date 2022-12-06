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

#pragma once

#include <optional>
#include <set>

#include <nlohmann/json.hpp>

#include "atomicdex/api/mm2/mm2.constants.hpp"
#include "atomicdex/api/mm2/utxo.merge.params.hpp"
#include "atomicdex/config/electrum.cfg.hpp"
#include "atomicdex/config/enable.cfg.hpp"
#include "atomicdex/constants/qt.coins.enums.hpp"
#include "atomicdex/constants/dex.constants.hpp"

namespace atomic_dex
{
    struct coin_config
    {
        static constexpr const char* erc_gas_stations   = "https://ethgasstation.info/json/ethgasAPI.json";
        static constexpr const char* matic_gas_stations = "https://gasstation-mainnet.matic.network/";
        using electrum_servers                          = std::vector<electrum_server>;
        using nodes                                     = std::vector<node>;
        using eth_family_url_list                       = std::vector<std::string>;
        using bchd_url_list                             = std::vector<std::string>;
        using light_wallet_d_servers                    = std::vector<std::string>; ///< For ZHTLC
        std::string                                 ticker;
        std::optional<std::string>                  alias_ticker{std::nullopt};
        std::string                                 gui_ticker; ///< Ticker displayed in the gui
        std::string                                 name;       ///< nice name
        std::optional<bool>                         utxo_merge{false};
        std::optional<bool>                         allow_slp_unsafe_conf;
        std::optional<nodes>                        urls;
        std::optional<eth_family_url_list>          eth_family_urls;
        std::optional<bchd_url_list>                bchd_urls;
        std::optional<electrum_servers>             electrum_urls;
        std::optional<light_wallet_d_servers>       z_urls;
        bool                                        is_claimable{false};
        std::string                                 minimal_claim_amount{"0"};
        bool                                        currently_enabled{false};
        bool                                        active{false};
        std::string                                 coinpaprika_id{"test-coin"};
        std::string                                 coingecko_id{"test-coin"};
        std::string                                 nomics_id{"test-coin"};
        bool                                        is_custom_coin{false};
        std::string                                 type;
        std::optional<std::set<CoinType>> other_types;
        std::string                     explorer_url; ///< usefull for transaction, take this url and append transaction id
        std::string                     tx_uri{"tx/"};
        std::string                     address_url{"address/"};
        std::optional<nlohmann::json>   custom_backup;
        nlohmann::json                              activation_status;
        std::optional<bool>             is_testnet{false}; ///< True if testnet (tBTC, tQTUM, QRC-20 on testnet, tETH)
        CoinType                        coin_type;
        bool                            checked{false};
        bool                            wallet_only{false};
        bool                            has_parent_fees_ticker{false}; ///< True if parent fees is different from current ticker eg: ERC20 tokens
        std::string                     fees_ticker;
        bool                            segwit{false};
        bool                            is_segwit_on{false};
        bool                            is_erc_family{false};
        bool                                        is_zhtlc_family{false};
        bool                                        default_coin{false};
    };

    void from_json(const nlohmann::json& j, coin_config& cfg);

    void print_coins(std::vector<coin_config> coins);
    bool is_wallet_only(std::string ticker);
    bool is_default_coin(std::string ticker);
} // namespace atomic_dex
