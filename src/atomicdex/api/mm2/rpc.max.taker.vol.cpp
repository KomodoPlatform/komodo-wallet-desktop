//
// Created by Roman Szterg on 13/02/2021.
//

//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/mm2/rpc.max.taker.vol.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

//! Implementation RPC [max_taker_vol]
namespace mm2::api
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
        t_rational rat(boost::multiprecision::cpp_int(cfg.numer), boost::multiprecision::cpp_int(cfg.denom));
        t_float_50 res = rat.convert_to<t_float_50>();
        cfg.decimal    = res.str(8);
    }

    void
    from_json(const nlohmann::json& j, max_taker_vol_answer& answer)
    {
        if (j.contains("error") && j.at("error").is_string())
        {
            answer.error = j.at("error").get<std::string>();
            SPDLOG_WARN("Max taker volume need a default value, fallback with 0 as value, this is probably because you have an empty balance or not enough "
                        "funds (< 0.00777).");
            answer.result = max_taker_vol_answer_success{.denom = "1", .numer = "0", .decimal = "0"};
        }
        else if (j.contains("result"))
        {
            answer.result = j.at("result").get<max_taker_vol_answer_success>();
        }
    }
} // namespace mm2::api