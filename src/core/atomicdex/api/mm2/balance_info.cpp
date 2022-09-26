#include <nlohmann/json.hpp>

#include "balance_info.hpp"

namespace atomic_dex::mm2
{
    void from_json(const nlohmann::json& j, balance_info& in)
    {
        j.at("spendable").get_to(in.spendable);
        j.at("unspendable").get_to(in.unspendable);
    }
}