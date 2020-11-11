#pragma once

//! Deps
#include <antara/gaming/core/real.path.hpp>
#include <nlohmann/json.hpp>

//! Project
#include "atomicdex/utilities/global.utilities.hpp"

#ifndef NLOHMANN_OPT_HELPER
#    define NLOHMANN_OPT_HELPER
namespace nlohmann
{
    template <typename T>
    struct adl_serializer<std::optional<T>>
    {
        static void
        to_json(json& j, const std::optional<T>& opt)
        {
            if (opt.has_value())
            {
                j = opt.value();
            }
        }

        static std::optional<T>
        from_json(const json& j)
        {
            return j.is_null() ? std::optional<T>{std::nullopt} : j.get<T>();
        }
    };
} // namespace nlohmann
#endif

namespace atomic_dex
{
    using nlohmann::json;

    inline json
    get_untyped(const json& j, const char* property)
    {
        if (j.find(property) != j.end())
        {
            return j.at(property).get<json>();
        }
        return json();
    }

    inline json
    get_untyped(const json& j, std::string property)
    {
        return get_untyped(j, property.data());
    }

    template <typename T>
    inline std::optional<T>
    get_optional(const json& j, const char* property)
    {
        if (j.contains(property))
        {
            return j.at(property).get<std::optional<T>>();
        }
        return std::optional<T>();
    }

    template <typename T>
    inline std::optional<T>
    get_optional(const json& j, std::string property)
    {
        return get_optional<T>(j, property.data());
    }

    struct address_format
    {
        std::string format;
        std::string network;
    };

    struct coin_element
    {
        std::string                   coin;
        std::optional<std::string>    name;
        std::optional<std::string>    fname;
        std::optional<std::string>    etomic;
        std::optional<int64_t>        rpcport;
        std::optional<int64_t>        pubtype;
        std::optional<int64_t>        p2_shtype;
        std::optional<int64_t>        wiftype;
        std::optional<int64_t>        txfee;
        std::optional<std::string>    confpath;
        std::optional<int64_t>        mm2;
        std::optional<int64_t>        required_confirmations;
        std::optional<std::string>    asset;
        std::optional<int64_t>        txversion;
        std::optional<int64_t>        overwintered;
        std::optional<bool>           requires_notarization;
        std::optional<int64_t>        is_po_s;
        std::optional<bool>           segwit;
        std::optional<address_format> address_format;
        std::optional<std::string>    estimate_fee_mode;
        std::optional<int64_t>        taddr;
        std::optional<int64_t>        decimals;
        std::optional<bool>           force_min_relay_fee;
        std::optional<int64_t>        p2_p;
        std::optional<std::string>    magic;
        std::optional<std::string>    n_spv;
        std::optional<std::string>    version_group_id;
        std::optional<std::string>    consensus_branch_id;
    };

    using coins = std::vector<coin_element>;
} // namespace atomic_dex

namespace atomic_dex
{
    using t_mm2_raw_coins          = std::vector<coin_element>;
    using t_mm2_raw_coins_registry = std::unordered_map<std::string, coin_element>;
} // namespace atomic_dex

namespace atomic_dex
{
    void from_json(const json& j, atomic_dex::address_format& x);
    void to_json(json& j, const atomic_dex::address_format& x);

    void from_json(const json& j, atomic_dex::coin_element& x);
    void to_json(json& j, const atomic_dex::coin_element& x);

    inline void
    from_json(const json& j, atomic_dex::address_format& x)
    {
        x.format  = j.at("format").get<std::string>();
        x.network = j.at("network").get<std::string>();
    }

    inline void
    to_json(json& j, const atomic_dex::address_format& x)
    {
        j            = json::object();
        j["format"]  = x.format;
        j["network"] = x.network;
    }

    inline void
    from_json(const json& j, atomic_dex::coin_element& x)
    {
        x.coin                   = j.at("coin").get<std::string>();
        x.name                   = atomic_dex::get_optional<std::string>(j, "name");
        x.fname                  = atomic_dex::get_optional<std::string>(j, "fname");
        x.etomic                 = atomic_dex::get_optional<std::string>(j, "etomic");
        x.rpcport                = atomic_dex::get_optional<int64_t>(j, "rpcport"); // j.at("rpcport").get<int64_t>();
        x.pubtype                = atomic_dex::get_optional<int64_t>(j, "pubtype");
        x.p2_shtype              = atomic_dex::get_optional<int64_t>(j, "p2shtype");
        x.wiftype                = atomic_dex::get_optional<int64_t>(j, "wiftype");
        x.txfee                  = atomic_dex::get_optional<int64_t>(j, "txfee");
        x.confpath               = atomic_dex::get_optional<std::string>(j, "confpath");
        x.mm2                    = atomic_dex::get_optional<int64_t>(j, "mm2");
        x.required_confirmations = atomic_dex::get_optional<int64_t>(j, "required_confirmations");
        x.asset                  = atomic_dex::get_optional<std::string>(j, "asset");
        x.txversion              = atomic_dex::get_optional<int64_t>(j, "txversion");
        x.overwintered           = atomic_dex::get_optional<int64_t>(j, "overwintered");
        x.requires_notarization  = atomic_dex::get_optional<bool>(j, "requires_notarization");
        x.is_po_s                = atomic_dex::get_optional<int64_t>(j, "isPoS");
        x.segwit                 = atomic_dex::get_optional<bool>(j, "segwit");
        x.address_format         = atomic_dex::get_optional<atomic_dex::address_format>(j, "address_format");
        x.estimate_fee_mode      = atomic_dex::get_optional<std::string>(j, "estimate_fee_mode");
        x.taddr                  = atomic_dex::get_optional<int64_t>(j, "taddr");
        x.decimals               = atomic_dex::get_optional<int64_t>(j, "decimals");
        x.force_min_relay_fee    = atomic_dex::get_optional<bool>(j, "force_min_relay_fee");
        x.p2_p                   = atomic_dex::get_optional<int64_t>(j, "p2p");
        x.magic                  = atomic_dex::get_optional<std::string>(j, "magic");
        x.n_spv                  = atomic_dex::get_optional<std::string>(j, "nSPV");
        x.version_group_id       = atomic_dex::get_optional<std::string>(j, "version_group_id");
        x.consensus_branch_id    = atomic_dex::get_optional<std::string>(j, "consensus_branch_id");
    }

    inline void
    to_json(json& j, const atomic_dex::coin_element& x)
    {
        j                           = json::object();
        j["coin"]                   = x.coin;
        j["name"]                   = x.name;
        j["fname"]                  = x.fname;
        j["etomic"]                 = x.etomic;
        j["rpcport"]                = x.rpcport;
        j["pubtype"]                = x.pubtype;
        j["p2shtype"]               = x.p2_shtype;
        j["wiftype"]                = x.wiftype;
        j["txfee"]                  = x.txfee;
        j["confpath"]               = x.confpath;
        j["mm2"]                    = x.mm2;
        j["required_confirmations"] = x.required_confirmations;
        j["asset"]                  = x.asset;
        j["txversion"]              = x.txversion;
        j["overwintered"]           = x.overwintered;
        j["requires_notarization"]  = x.requires_notarization;
        j["isPoS"]                  = x.is_po_s;
        j["segwit"]                 = x.segwit;
        j["address_format"]         = x.address_format;
        j["estimate_fee_mode"]      = x.estimate_fee_mode;
        j["taddr"]                  = x.taddr;
        j["decimals"]               = x.decimals;
        j["force_min_relay_fee"]    = x.force_min_relay_fee;
        j["p2p"]                    = x.p2_p;
        j["magic"]                  = x.magic;
        j["nSPV"]                   = x.n_spv;
        j["version_group_id"]       = x.version_group_id;
        j["consensus_branch_id"]    = x.consensus_branch_id;
    }

    inline t_mm2_raw_coins_registry
    parse_raw_mm2_coins_file()
    {
        t_mm2_raw_coins_registry out;
        // fs::path                 file_path{ag::core::assets_real_path() / "tools" / "mm2" / "coins"};
        fs::path file_path{atomic_dex::utils::get_current_configs_path() / "coins.json"};
        if (not fs::exists(file_path))
        {
            fs::path original_mm2_coins_path{ag::core::assets_real_path() / "tools" / "mm2" / "coins"};
            //! Copy our json to current version
            spdlog::info("Copying mm2 coins cfg: {} to {}", original_mm2_coins_path.string(), file_path.string());

            fs::copy_file(original_mm2_coins_path, file_path, get_override_options());
        }
        std::ifstream ifs(file_path.string());
        assert(ifs.is_open());
        try
        {
            nlohmann::json j;
            ifs >> j;
            t_mm2_raw_coins coins = j;
            out.reserve(coins.size());
            for (auto&& coin: coins) { out[coin.coin] = coin; }
            spdlog::info("successfully parsed: {}, nb_coins: {}", file_path.string(), out.size());
        }
        catch (const std::exception& error)
        {
            spdlog::error("cannot parse mm2 raw cfg file: {} {}", file_path.string(), error.what());
        }
        return out;
    }
} // namespace atomic_dex
