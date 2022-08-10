#include <nlohmann/json.hpp>

#include "rpc.hpp"

namespace mm2::api
{
    inline void from_json(const nlohmann::json& j, rpc_basic_error_type& in)
    {
        j.at("error").get_to(in.error);
        j.at("error_path").get_to(in.error_path);
        j.at("error_trace").get_to(in.error_trace);
        j.at("error_type").get_to(in.error_type);
        j.at("error_data").get_to(in.error_data);
    }
}