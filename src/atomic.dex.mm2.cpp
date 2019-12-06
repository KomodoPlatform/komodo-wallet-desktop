/******************************************************************************
 * Copyright © 2013-2019 The Komodo Platform Developers.                      *
 *                                                                            *
 * See the AUTHORS, DEVELOPER-AGREEMENT and LICENSE files at                  *
 * the top-level directory of this distribution for the individual copyright  *
 * holder information and the developer policies on copyright and licensing.  *
 *                                                                            *
 * Unless otherwise agreed in a custom licensing agreement, no part of the    *
 * Komodo Platform software, including this file may be copied, modified,     *
 * propagated or distributed except according to the terms contained in the   *
 * LICENSE file                                                               *
 *                                                                            *
 * Removal or modification of this copyright notice is prohibited.            *
 *                                                                            *
 ******************************************************************************/

#include <array>
#include <fstream>
#include <filesystem>
#include <antara/gaming/core/real.path.hpp>
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.mm2.config.hpp"

namespace {
    namespace ag = antara::gaming;

    void spawn_mm2_instance(reproc::process &mm2_instance, std::atomic<bool> &mm2_initialized,
                            std::thread &mm2_init_thread) noexcept {
        atomic_dex::mm2_config cfg{};
        nlohmann::json json_cfg;
        nlohmann::to_json(json_cfg, cfg);
        std::filesystem::path tools_path = ag::core::assets_real_path() / "tools/mm2/";
        DVLOG_F(loguru::Verbosity_INFO, "command line {}", json_cfg.dump());
        std::array<std::string, 2> args = {(tools_path / "mm2").string(), json_cfg.dump()};
        auto ec = mm2_instance.start(args, reproc::options{nullptr, tools_path.string().c_str(),
                                                           {reproc::redirect::inherit,
                                                            reproc::redirect::inherit,
                                                            reproc::redirect::inherit}});
        if (ec) {
            DVLOG_F(loguru::Verbosity_ERROR, "error: {}", ec.message());
        }


        mm2_init_thread = std::thread([&mm2_instance, &mm2_initialized]() {
            loguru::set_thread_name("mm2 init thread");
            using namespace std::chrono_literals;
            auto ec = mm2_instance.wait(5s);
            if (ec == reproc::error::wait_timeout) {
                DVLOG_F(loguru::Verbosity_INFO, "mm2 is initialized");
                mm2_initialized = true;
            } else {
                DVLOG_F(loguru::Verbosity_ERROR, "error: {}", ec.message());
            }
        });
    }

    void check_coin_enabled(std::vector<std::string> &active_coins) noexcept {
        std::filesystem::path cfg_path = ag::core::assets_real_path() / "config";
        if (std::filesystem::exists(cfg_path / "active.coins.json")) {
            std::ifstream ifs(cfg_path / "active.coins.json");
            assert(ifs.is_open());
            nlohmann::json config_json_data;
            ifs >> config_json_data;
            config_json_data.get_to(active_coins);
        } else {
            std::ofstream ofs(cfg_path / "active.coins.json");
            assert(ofs.is_open());
            ofs << "[]";
        }
        DVLOG_F(loguru::Verbosity_INFO, "There is {} active coins", active_coins.size());
    }

    std::vector<atomic_dex::electrum_server> get_electrum_for_this_coin(const std::string &ticker) {
        std::vector<atomic_dex::electrum_server> electrum_urls;
        std::filesystem::path electrum_cfg_path = ag::core::assets_real_path() / "tools/mm2/electrums";
        if (std::filesystem::exists(electrum_cfg_path / ticker)) {
            std::ifstream ifs(electrum_cfg_path / ticker);
            assert(ifs.is_open());
            nlohmann::json config_json_data;
            ifs >> config_json_data;
            for (auto &&element: config_json_data) {
                atomic_dex::electrum_server current_electrum_infos{
                        .url = element.at("url").get<std::string>()
                };
                if (element.find("protocol") != element.end()) {
                    current_electrum_infos.protocol = element.at("protocol").get<std::string>();
                }
                if (element.find("disable_cert_verification") != element.end()) {
                    current_electrum_infos.disable_cert_verification = element.at(
                            "disable_cert_verification").get<bool>();
                }
                electrum_urls.push_back(std::move(current_electrum_infos));
            }
        }
        return electrum_urls;
    }

    bool
    retrieve_coins_information(std::unordered_map<std::string, atomic_dex::coins_config> &coins_registry) noexcept {
        std::filesystem::path tools_path = ag::core::assets_real_path() / "tools/mm2/";
        if (std::filesystem::exists(tools_path / "coins.json")) {
            std::ifstream ifs(tools_path / "coins.json");
            assert(ifs.is_open());
            nlohmann::json config_json_data;
            ifs >> config_json_data;
            for (auto &&element: config_json_data) {
                if (element.find("mm2") != element.end()) {
                    auto current_ticker = element.at("coin").get<std::string>();
                    atomic_dex::coins_config current_coin{
                            .ticker = current_ticker,
                            .fname = element.at("fname").get<std::string>(),
                            .electrum_urls = get_electrum_for_this_coin(current_ticker),
                            .currently_enabled = false
                    };
                    if (current_coin.electrum_urls.size()) {
                        DVLOG_F(loguru::Verbosity_INFO,
                                "coin {} is mm2 compatible, adding...\n nb electrum_urls found: {}",
                                current_ticker, current_coin.electrum_urls.size());
                        coins_registry[current_ticker] = std::move(current_coin);
                    }
                }
            }
            return true;
        }
        return false;
    }
}

namespace atomic_dex {
    mm2::mm2(entt::registry &registry) noexcept : system(registry) {
        spawn_mm2_instance(mm2_instance_, mm2_initialized_, mm2_init_thread_);
        check_coin_enabled(active_coins_);
        retrieve_coins_information(coins_informations_);
    }

    void mm2::update() noexcept {
    }

    mm2::~mm2() noexcept {
        reproc::stop_actions stop_actions = {
                {reproc::stop::terminate, reproc::milliseconds(2000)},
                {reproc::stop::kill,      reproc::milliseconds(5000)},
                {reproc::stop::wait,      reproc::milliseconds(2000)}
        };

        auto ec = mm2_instance_.stop(stop_actions);
        if (ec) {
            VLOG_SCOPE_F(loguru::Verbosity_ERROR, "error: %s", ec.message().c_str());
        }
        mm2_init_thread_.join();
    }

    const std::atomic<bool> &mm2::is_mm2_initialized() const noexcept {
        return mm2_initialized_;
    }

    std::vector<coins_config> mm2::get_enabled_coins() const noexcept {
        std::vector<coins_config> destination;
        //! Active coins is persistent on disk, field from coins_information is at runtime.
        for (auto &&current_ticker : active_coins_) {
            destination.push_back(coins_informations_.at(current_ticker));
        }
        return destination;
    }

    std::vector<coins_config> mm2::get_enableable_coins() const noexcept {
        std::vector<coins_config> destination;
        for (auto&&[key, value]: coins_informations_) {
            if (not value.currently_enabled) {
                destination.push_back(value);
            }
        }
        return destination;
    }
}

