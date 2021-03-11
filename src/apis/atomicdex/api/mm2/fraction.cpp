//
// Created by Roman Szterg on 13/02/2021.
//

//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/mm2/fraction.hpp"

namespace mm2::api
{
    void
    from_json(const nlohmann::json& j, fraction& fraction)
    {
        j.at("denom").get_to(fraction.denom);
        j.at("numer").get_to(fraction.numer);
    }
} // namespace mm2::api