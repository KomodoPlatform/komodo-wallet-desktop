#include <nlohmann/json.hpp>

#include "atomicdex/api/kdf/fraction.hpp"

namespace atomic_dex::kdf
{
    void from_json(const nlohmann::json& j,  kdf::fraction& fraction)
    {
        j.at("denom").get_to(fraction.denom);
        j.at("numer").get_to(fraction.numer);
    }
} // namespace atomic_dex::kdf