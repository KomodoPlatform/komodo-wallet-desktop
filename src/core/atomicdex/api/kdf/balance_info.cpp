#include <nlohmann/json.hpp>

#include "atomicdex/api/kdf/balance_info.hpp"

namespace atomic_dex::kdf
{
    void from_json(const nlohmann::json& j, balance_info& in)
    {
        j.at("spendable").get_to(in.spendable);
        j.at("unspendable").get_to(in.unspendable);
    }
}