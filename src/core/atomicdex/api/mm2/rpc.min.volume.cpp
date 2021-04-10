//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/mm2/rpc.min.volume.hpp"

namespace mm2::api
{
    void
    to_json(nlohmann::json& j, const min_volume_request& cfg)
    {
        j["coin"] = cfg.coin;
    }
} // namespace mm2::api