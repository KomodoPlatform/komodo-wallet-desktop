//
// Created by Sztergbaum Roman on 10/04/2021.
//

#pragma once

//! Deps
#include <nlohmann/json_fwd.hpp>

#include "atomicdex/api/mm2/rpc.min.volume.hpp"

namespace mm2::api
{
    struct min_volume_request
    {
        std::string coin;
    };

    void to_json(nlohmann::json& j, const min_volume_request& cfg);
} // namespace mm2::api