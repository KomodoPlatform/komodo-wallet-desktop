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

#pragma once

//! QT
#include <QObject>

//! STD
#include <optional>

//! Deps
#include <nlohmann/json.hpp>

//! Project
#include "atomicdex/config/electrum.cfg.hpp"
#include "atomicdex/constants/mm2.constants.hpp"
#include "atomicdex/constants/qt.coins.enums.hpp"

namespace atomic_dex
{
    struct coin_config
    {
      public:
        static constexpr const char* erc_gas_stations = "https://ethgasstation.info/json/ethgasAPI.json";
        using electrum_servers                        = std::vector<electrum_server>;
        using eth_nodes                               = std::vector<std::string>;
        std::string                     ticker;
        std::string                     gui_ticker; ///< Ticker displayed in the gui
        std::string                     name;       ///< nice name
        std::optional<electrum_servers> electrum_urls;
        std::optional<eth_nodes>        eth_urls;
        bool                            is_claimable{false};
        std::string                     minimal_claim_amount{"0"};
        bool                            currently_enabled{false};
        bool                            active{false};
        std::string                     coinpaprika_id{"test-coin"};
        std::string                     coingecko_id{"test-coin"};
        bool                            is_custom_coin{false};
        std::string                     type;
        std::vector<std::string>        explorer_url; ///< usefull for transaction, take this url and append transaction id
        std::string                     tx_uri{"tx/"};
        std::string                     address_url{"address/"};
        std::optional<nlohmann::json>   custom_backup;
        std::optional<bool>             is_testnet{false}; ///< True if testnet (tBTC, tQTUM, QRC-20 on testnet, tETH)
        CoinType                        coin_type;
        bool                            checked{false};
    };

    void from_json(const nlohmann::json& j, coin_config& cfg);
} // namespace atomic_dex
