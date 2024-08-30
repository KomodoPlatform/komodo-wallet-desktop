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
#include "atomicdex/api/kdf/rpc_v1/rpc.max_taker_vol.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

//! Implementation RPC [max_taker_vol]
namespace atomic_dex::kdf
{
    //! Serialization
    void
    to_json(nlohmann::json& j, const max_taker_vol_request& cfg)
    {
        j["coin"] = cfg.coin;
        if (cfg.trade_with.has_value())
        {
            j["trade_with"] = cfg.trade_with.value();
        }
    }

    //! Deserialization
    void
    from_json(const nlohmann::json& j, max_taker_vol_answer_success& cfg)
    {
        j.at("denom").get_to(cfg.denom);
        j.at("numer").get_to(cfg.numer);
        // SPDLOG_INFO("max: {}", j.dump(4));

        t_rational rat(boost::multiprecision::cpp_int(cfg.numer), boost::multiprecision::cpp_int(cfg.denom));
        t_float_50 res = rat.convert_to<t_float_50>();
        cfg.decimal    = atomic_dex::utils::extract_large_float(res.str(50));
        //SPDLOG_INFO("decimal: {}", cfg.decimal);
    }

    void
    from_json(const nlohmann::json& j, max_taker_vol_answer& answer)
    {
        //SPDLOG_INFO("max: {}", j.dump(4));
        extract_rpc_json_answer<max_taker_vol_answer_success>(j, answer);
        if (answer.error.has_value()) ///< we need a default fallback in this case fixed on upstream already, need to update
        {
            SPDLOG_WARN("Max taker volume need a default value, fallback with 0 as value, this is probably because you have an empty balance or not enough "
                        "funds (< 0.00777)., error: {}", answer.error.value());
            answer.result = max_taker_vol_answer_success{.denom = "1", .numer = "0", .decimal = "0"};
        } else {
            answer.result.value().coin = j.at("coin").get<std::string>();
        }
    }
} // namespace atomic_dex::kdf