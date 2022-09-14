#include <nlohmann/json.hpp>

#include "atomicdex/api/mm2/fraction.hpp"

namespace atomic_dex::mm2
{
    void from_json(const nlohmann::json& j,  mm2::fraction& fraction)
    {
        j.at("denom").get_to(fraction.denom);
        j.at("numer").get_to(fraction.numer);
    }
} // namespace atomic_dex::mm2