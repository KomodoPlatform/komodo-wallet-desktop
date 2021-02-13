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
} // namespace mm2::api