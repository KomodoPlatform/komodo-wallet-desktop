#include <nlohmann/json.hpp>

#include "atomicdex/api/mm2/rpc.validate.address.hpp"
#include "atomicdex/api/mm2/generics.hpp"

namespace atomic_dex::mm2
{
    void
    to_json(nlohmann::json& j, const mm2::validate_address_request& req)
    {
        j["coin"]    = req.coin;
        j["address"] = req.address;
    }

    void
    from_json(const nlohmann::json& j, validate_address_answer_success& answer)
    {
        j.at("is_valid").get_to(answer.is_valid);
        if (j.contains("reason"))
        {
            answer.reason = j.at("reason").get<std::string>();
        }
    }
    void
    from_json(const nlohmann::json& j, validate_address_answer& answer)
    {
        extract_rpc_json_answer<validate_address_answer_success>(j, answer);
    }
} // namespace atomic_dex::mm2
