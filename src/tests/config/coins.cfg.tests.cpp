//
// Created by Sztergbaum Roman on 24/03/2021.
//

#include <fstream>
#include <iostream>

//! Deps
#include "doctest/doctest.h"
#include <nlohmann/json.hpp>

#include <antara/gaming/core/real.path.hpp>

#include <atomicdex/config/coins.cfg.hpp>
#include <atomicdex/services/kdf/kdf.service.hpp>
#include <atomicdex/utilities/cpprestsdk.utilities.hpp>

constexpr const char* g_komodolive_endpoint = "http://95.216.160.96:8080/api/v1";
t_http_client_ptr     g_komodolive_client{std::make_unique<t_http_client>(FROM_STD_STR(g_komodolive_endpoint))};

TEST_CASE("generate all coinpaprika possibilities")
{
#if defined(__APPLE__)
    const auto     resp      = atomic_dex::kdf::async_process_rpc_get(g_komodolive_client, "tickers", "/ticker").get();
    std::string    body      = TO_STD_STR(resp.extract_string(true).get());
    nlohmann::json j_metrics = nlohmann::json::parse(body);
    nlohmann::json metrics   = nlohmann::json::object();
    for (auto&& cur: j_metrics)
    {
        for (auto&& [key, obj]: cur.items()) { metrics[key] = obj; }
    }

    std::unordered_set<std::string> visited;
    std::filesystem::path                        cfg_path = antara::gaming::core::assets_real_path() / "config" / "0.4.2-coins.json";
    std::ifstream                   ifs(cfg_path.string());
    nlohmann::json                  j;
    ifs >> j;
    std::unordered_map<std::string, atomic_dex::coin_config_t> cfg;
    auto                                                     out = j.get<std::unordered_map<std::string, atomic_dex::coin_config_t>>();
    CHECK_GT(out.size(), 0);
    std::ofstream ofs("/tmp/out.txt", std::ios::trunc);
    for (auto&& [key, current_cfg]: out)
    {
        if (current_cfg.coinpaprika_id != "test-coin")
        {
            for (auto&& [cur_key, sub_current_cfg]: out)
            {
                if (visited.contains(key + "/" + cur_key) || !metrics.contains(key + "_" + cur_key))
                    continue;
                const auto obj = metrics.at(key + "_" + cur_key);
                if (safe_float(obj.at("base_volume").get<std::string>()) > 0 || safe_float(obj.at("quote_volume").get<std::string>()) > 0)
                {
                    if (key != cur_key && sub_current_cfg.coinpaprika_id != "test-coin")
                    {
                        ofs << key << "/" << cur_key << std::endl;
                    }
                }
                visited.emplace(key + "/" + cur_key);
            }
        }
    }
#endif
}
