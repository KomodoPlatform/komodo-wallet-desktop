// komodo-wallet
// Author(s): syl

#include <nlohmann/json.hpp>

#include "atomicdex/api/kdf/paging_options.hpp"

namespace atomic_dex::kdf
{
    void to_json(nlohmann::json& j, const paging_options_t& in)
    {
        if (in.from_id)
        {
            j["FromId"] = *in.from_id;
        }
        if (in.page_number)
        {
            j["PageNumber"] = *in.page_number;
        }
    }
}