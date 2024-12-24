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

#pragma once

//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/config/electrum.cfg.hpp"
#include "atomicdex/constants/qt.coins.enums.hpp"
#include "atomicdex/api/kdf/address_format.hpp"

namespace atomic_dex::kdf
{
    struct electrum_request
    {
        std::string                                  coin_name;
        std::vector<atomic_dex::electrum_server>     servers;
        CoinType                                     coin_type;
        bool                                         is_testnet{false};
        bool                                         with_tx_history{true};
        std::optional<std::string>                   swap_contract_address{std::nullopt};
        std::optional<std::string>                   fallback_swap_contract{std::nullopt};
        std::optional<address_format_t>              address_format;
        std::optional<nlohmann::json>                merge_params;
        std::optional<std::vector<std::string>>      bchd_urls;
        std::optional<bool>                          allow_slp_unsafe_conf;
        int                                          min_connected{1};
        int                                          max_connected{3};
    };

    struct electrum_answer
    {
        std::string address;
        std::string balance;
        std::string result;
        int         rpc_result_code;
        std::string raw_result;
    };

    void to_json(nlohmann::json& j, const electrum_request& cfg);

    void from_json(const nlohmann::json& j, electrum_answer& answer);
} // namespace atomic_dex::kdf

namespace atomic_dex
{
    using t_electrum_request = kdf::electrum_request;
    using t_electrum_answer  = kdf::electrum_answer;
} // namespace atomic_dex
