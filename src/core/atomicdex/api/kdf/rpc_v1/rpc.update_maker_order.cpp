//
// Created by Sztergbaum Roman on 18/05/2021.
//

//! Dependencies
#include <nlohmann/json.hpp>

//! Project Headers
#include <atomicdex/api/kdf/rpc_v1/rpc.update_maker_order.hpp>

namespace atomic_dex::kdf
{
    void
    to_json(nlohmann::json& j, const kdf::update_maker_order_request& request)
    {
        j["uuid"]      = request.uuid;
        j["new_price"] = request.new_price;
        j["max"]       = request.max;
        if (request.volume_delta.has_value())
        {
            j["volume_delta"] = request.volume_delta.value();
        }
        if (request.min_volume.has_value())
        {
            j["min_volume"] = request.min_volume.value();
        }
        if (request.base_confs.has_value())
        {
            j["base_confs"] = request.base_confs.value();
        }
        if (request.base_nota.has_value())
        {
            j["base_nota"] = request.base_nota.value();
        }
        if (request.rel_confs.has_value())
        {
            j["rel_confs"] = request.rel_confs.value();
        }
        if (request.rel_nota.has_value())
        {
            j["rel_nota"] = request.rel_nota.value();
        }
    }
} // namespace atomic_dex::kdf
