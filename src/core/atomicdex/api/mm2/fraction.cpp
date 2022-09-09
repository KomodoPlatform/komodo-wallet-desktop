#include <nlohmann/json.hpp>

#include "atomicdex/api/mm2/fraction.hpp"

namespace mm2::api
{
    void from_json(const nlohmann::json& j,  mm2::api::fraction& fraction)
    {
        j.at("denom").get_to(fraction.denom);
        j.at("numer").get_to(fraction.numer);
    }
} // namespace mm2::api