#pragma once

#include <string>

#include <nlohmann/json_fwd.hpp> //> nlohmann::json

namespace atomic_dex::mm2
{
    struct balance_info
    { 
        std::string spendable; 
        std::string unspendable; 
    };

    void from_json(const nlohmann::json& j, balance_info& in);
}