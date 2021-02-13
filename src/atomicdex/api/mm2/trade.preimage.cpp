//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/mm2/trade.preimage.hpp"

namespace mm2::api
{
    void
    to_json(nlohmann::json& j, const trade_preimage_request& request)
    {
        j["base"]        = request.base_coin;
        j["rel"]         = request.rel_coin;
        j["swap_method"] = request.swap_method;
        j["volume"]      = request.volume;
        if (request.max.has_value())
        {
            j["max"] = request.max.value();
        }
    }

    void
    from_json(const nlohmann::json& j, coin_fee& fee)
    {
        j.at("coin").get_to(fee.coin);
        j.at("amount").get_to(fee.amount);
        j.at("amount_fraction").get_to(fee.amount_fraction);
    }

    void
    from_json(const nlohmann::json& j, trade_preimage_answer_success& answer)
    {
        j.at("base_coin_fee").get_to(answer.base_coin_fee);
        j.at("rel_coin_fee").get_to(answer.rel_coin_fee);
        if (j.contains("taker_fee"))
        {
            answer.taker_fee = j.at("taker_fee").get<std::string>();
        }
        if (j.contains("taker_fee_fraction"))
        {
            answer.taker_fee_fraction = j.at("taker_fee_fraction").get<fraction>();
        }
        if (j.contains("fee_to_send_taker_fee"))
        {
            answer.fee_to_send_taker_fee = j.at("fee_to_send_taker_fee").get<coin_fee>();
        }
        if (j.contains("volume"))
        {
            answer.volume = j.at("volume").get<std::string>();
        }
        if (j.contains("volume_fraction"))
        {
            answer.volume_fraction = j.at("volume_fraction").get<fraction>();
        }
    }

    void
    from_json(const nlohmann::json& j, trade_preimage_answer& answer)
    {
        if (j.contains("error") && j.at("error").is_string())
        {
            answer.error = j.at("error").get<std::string>();
        }
        else if (j.contains("result"))
        {
            answer.result = j.at("result").get<trade_preimage_answer_success>();
        }
    }
} // namespace mm2::api