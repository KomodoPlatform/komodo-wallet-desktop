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
    void
    from_json(const nlohmann::json& j, sepa_recipient& cfg)
    {
        j.at("bic").get_to(cfg.bic);
        j.at("iban").get_to(cfg.iban);
        j.at("name").get_to(cfg.name);
    }

    void
    from_json(const nlohmann::json& j, clearing_instructions& cfg)
    {
        j.at("type").get_to(cfg.type);
        if (j.contains("amount"))
        {
            cfg.amount = j.at("amount").get<t_asset_quantity>();
        }
        if (j.contains("purpose"))
        {
            cfg.purpose = j.at("purpose").get<std::string>();
        }
        if (j.contains("description"))
        {
            cfg.description = j.at("description").get<std::string>();
        }
        if (j.contains("recipient"))
        {
            cfg.recipient = j.at("recipient").get<sepa_recipient>();
        }
    }

    void
    from_json(const nlohmann::json& j, clearing& cfg)
    {
        j.at("status").get_to(cfg.status);
    }

    void
    from_json(const nlohmann::json& j, preimage& cfg)
    {
        j.at("size").get_to(cfg.size);
        if (j.contains("value"))
        {
            cfg.value = j.at("value").get<std::string>();
        }
    }

    void
    from_json(const nlohmann::json& j, hash& cfg)
    {
        j.at("algorithm").get_to(cfg.algorithm);
        j.at("value").get_to(cfg.value);
    }

    void
    from_json(const nlohmann::json& j, elliptic_curve_key& eck)
    {
        j.at("kty").get_to(eck.kty);
        j.at("crv").get_to(eck.crv);
        j.at("x").get_to(eck.x);
        j.at("y").get_to(eck.y);
    }

    void
    from_json(const nlohmann::json& j, hashed_timed_lock_contract& htlc)
    {
        j.at("asset").get_to(htlc.asset);
        j.at("amount").get_to(htlc.amount);
        j.at("beneficiary").get_to(htlc.beneficiary);
        j.at("hash").get_to(htlc.hash);

        if (j.contains("id"))
        {
            htlc.id = j.at("id").get<t_contract_id>();
        }

        if (j.contains("status"))
        {
            htlc.status = j.at("status").get<t_contract_status>();
        }

        if (j.contains("preimage"))
        {
            htlc.preimage = j.at("preimage").get<preimage>();
        }

        j.at("expires").get_to(htlc.expires);
    }
} // namespace atomic_dex::oasis::api
