//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/oasis/hashed.time.lock.contract.hpp"

//! Serialization
namespace atomic_dex::oasis::api
{
    void
    to_json(nlohmann::json& j, const preimage& cfg)
    {
        j["size"] = cfg.size;
        if (cfg.value.has_value())
        {
            j["value"] = *cfg.value;
        }
    }

    void
    to_json(nlohmann::json& j, const hash& cfg)
    {
        j["algorithm"] = cfg.algorithm;
        j["value"]     = cfg.value;
    }

    void
    to_json(nlohmann::json& j, const elliptic_curve_key& eck)
    {
        j["kty"] = eck.kty;
        j["crv"] = eck.crv;
        j["x"]   = eck.x;
        j["y"]   = eck.y;
    }

    void
    to_json(nlohmann::json& j, const hashed_timed_lock_contract& htlc)
    {
        j["asset"]       = htlc.asset;
        j["amount"]      = htlc.amount;
        j["beneficiary"] = htlc.beneficiary;
        j["hash"]        = htlc.hash;
        j["preimage"]    = htlc.preimage;
        j["expires"]     = htlc.expires;
        if (htlc.include_fee.has_value())
        {
            j["includeFee"] = htlc.include_fee.value();
        }
    }
} // namespace atomic_dex::oasis::api

//! Deserialization
namespace atomic_dex::oasis::api
{
}
