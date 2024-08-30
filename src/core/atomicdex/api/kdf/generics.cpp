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

//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/kdf/generics.hpp"
#include "atomicdex/api/kdf/rpc_v1/rpc.buy.hpp"
#include "atomicdex/api/kdf/rpc_v1/rpc.convertaddress.hpp"
#include "atomicdex/api/kdf/rpc_v1/rpc.disable_coin.hpp"
#include "atomicdex/api/kdf/rpc_v1/rpc.max_taker_vol.hpp"
#include "atomicdex/api/kdf/rpc_v1/rpc.min_trading_vol.hpp"
#include "atomicdex/api/kdf/rpc_v1/rpc.recover_funds_of_swap.hpp"
#include "atomicdex/api/kdf/rpc_v1/rpc.sell.hpp"
#include "atomicdex/api/kdf/rpc_v1/rpc.validateaddress.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.bestorders.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.trade_preimage.hpp"

namespace atomic_dex::kdf
{
    template <typename RpcSuccessReturnType, typename RpcReturnType>
    void
    extract_rpc_json_answer(const nlohmann::json& j, RpcReturnType& answer)
    {
        if (j.contains("error") && j.at("error").is_string())
        {
            answer.error = j.at("error").get<std::string>();
        }
        else if (j.contains("result"))
        {
            answer.result = j.at("result").get<RpcSuccessReturnType>();
        }
    }

    template void extract_rpc_json_answer<trade_preimage_answer_success>(const nlohmann::json& j, trade_preimage_answer& answer);
    template void extract_rpc_json_answer<max_taker_vol_answer_success>(const nlohmann::json& j, max_taker_vol_answer& answer);
    template void extract_rpc_json_answer<min_volume_answer_success>(const nlohmann::json& j, min_volume_answer& answer);
    template void extract_rpc_json_answer<buy_answer_success>(const nlohmann::json& j, buy_answer& answer);
    template void extract_rpc_json_answer<sell_answer_success>(const nlohmann::json& j, sell_answer& answer);
    template void extract_rpc_json_answer<disable_coin_answer_success>(const nlohmann::json& j, disable_coin_answer& answer);
    template void extract_rpc_json_answer<validate_address_answer_success>(const nlohmann::json& j, validate_address_answer& answer);
    template void extract_rpc_json_answer<convert_address_answer_success>(const nlohmann::json& j, convert_address_answer& answer);
    template void extract_rpc_json_answer<recover_funds_of_swap_answer_success>(const nlohmann::json& j, recover_funds_of_swap_answer& answer);
} // namespace atomic_dex::kdf