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
#include <boost/multiprecision/cpp_dec_float.hpp>
#include <antara/gaming/core/real.path.hpp>
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.mm2.config.hpp"
#include "atomic.dex.mm2.api.hpp"

namespace {
    namespace ag = antara::gaming;

    void update_coin_status(const std::string &ticker) {
        std::filesystem::path cfg_path = ag::core::assets_real_path() / "config";
        std::ifstream ifs(cfg_path / "active.coins.json");
        assert(ifs.is_open());
        nlohmann::json config_json_data;
        ifs >> config_json_data;
        if (config_json_data.find(ticker) != config_json_data.end()) {
            return;
        }
        config_json_data.push_back(ticker);
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
            for (auto &&element : config_json_data) {
                atomic_dex::electrum_server current_electrum_infos{
                        .url = element.at("url").get<std::string>()
                };
                if (element.find("protocol") != element.end()) {
                    current_electrum_infos.protocol = element.at("protocol").get<std::string>();
                }
                if (element.find("disable_cert_verification") != element.end()) {
                    current_electrum_infos.disable_cert_verification = element.at(
                            "disable_cert_verification").get<bool
                    >();
                }
                electrum_urls.push_back(std::move(current_electrum_infos));
            }
        }
        return electrum_urls;
    }

    bool
    retrieve_coins_information(
            folly::ConcurrentHashMap<std::string, atomic_dex::coins_config> &coins_registry) noexcept {
        std::filesystem::path tools_path = ag::core::assets_real_path() / "tools/mm2/";
        if (std::filesystem::exists(tools_path / "coins.json")) {
            std::ifstream ifs(tools_path / "coins.json");
            assert(ifs.is_open());
            nlohmann::json config_json_data;
            ifs >> config_json_data;
            for (auto &&element : config_json_data) {
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
                        coins_registry.insert_or_assign(current_ticker, std::move(current_coin));
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
        spawn_mm2_instance();
        check_coin_enabled(active_coins_);
        retrieve_coins_information(coins_informations_);
    }

    void mm2::update() noexcept {
    }

    mm2::~mm2() noexcept {
        mm2_running_ = false;
        reproc::stop_actions stop_actions = {
                {reproc::stop::terminate, reproc::milliseconds(2000)},
                {reproc::stop::kill,      reproc::milliseconds(5000)},
                {reproc::stop::wait,      reproc::milliseconds(2000)}
        };

        auto ec = mm2_instance_.stop(stop_actions);
        if (ec) {
            VLOG_SCOPE_F(loguru::Verbosity_ERROR, "error: %s", ec.message().c_str());
        }
        balance_thread_timer_.interrupt();
        mm2_init_thread_.join();
        mm2_fetch_infos_thread_.join();
    }

    const std::atomic<bool> &mm2::is_mm2_running() const noexcept {
        return mm2_running_;
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
        for (auto&&[key, value] : coins_informations_) {
            if (not value.currently_enabled) {
                destination.push_back(value);
            }
        }
        return destination;
    }

    bool mm2::enable_coin(const std::string &ticker) noexcept {
        auto coin_info = coins_informations_.at(ticker);
        if (coin_info.currently_enabled) return true;
        ::mm2::api::electrum_request request{
                .coin_name = coin_info.ticker,
                .servers = coin_info.electrum_urls,
                .with_tx_history = true
        };
        auto answer = ::mm2::api::rpc_electrum(std::move(request));
        if (answer.result != "success") {
            return false;
        }
        coin_info.currently_enabled = true;
        coins_informations_.assign(coin_info.ticker, coin_info);
        update_coin_status(ticker);
        return true;
    }

    bool mm2::enable_default_coins() noexcept {
        auto result = true;
        auto coins = get_enabled_coins();
        for (auto &&current_coin : coins) {
            result &= enable_coin(current_coin.ticker);
        }
        return result;
    }

    coins_config mm2::get_coin_info(const std::string &ticker) const noexcept {
        return coins_informations_.at(ticker);
    }

    void mm2::fetch_infos_thread() {
        loguru::set_thread_name("balance thread");
        using namespace std::chrono_literals;
        std::vector<coins_config> coins;
        do {
            DVLOG_F(loguru::Verbosity_INFO, "Fetching coins balance");
            coins = get_enabled_coins();
            for (auto &&current_coin : coins) {
                ::mm2::api::balance_request request{.coin = current_coin.ticker};
                balance_informations_.insert_or_assign(current_coin.ticker,
                                                       ::mm2::api::rpc_balance(std::move(request)));
                ::mm2::api::tx_history_request tx_request{.coin = current_coin.ticker, .limit = 50};
                auto answer = ::mm2::api::rpc_my_tx_history(std::move(tx_request));
                if (answer.error.has_value()) {
                    VLOG_F(loguru::Verbosity_ERROR, "tx error: {}", answer.error.value());
                } else if (answer.rpc_result_code != -1 && answer.result.has_value()) {
                    std::vector<tx_infos> out;
                    for (auto &&current : answer.result.value().transactions) {
                        tx_infos current_info{
                                .am_i_sender = current.my_balance_change[0] == '-',
                                .my_balance_change = current.my_balance_change,
                                .block_height = current.block_height,
                                .date = current.timestamp_as_date,
                                .from = current.from,
                                .to = current.to,
                                .total_amount = current.total_amount,
                                .fees = current.fee_details.normal_fees.has_value()
                                        ? current.fee_details.normal_fees.value().amount
                                        : current.fee_details.erc_fees.value().total_fee,
                                .ec = mm2_error::success,
                                .confirmations = current.confirmations.has_value() ? current.confirmations.value() : 0,
                                .timestamp = current.timestamp,
                                .tx_hash = current.tx_hash
                        };
                        out.push_back(std::move(current_info));
                    }
                    std::sort(begin(out), end(out), [](auto &&a, auto &&b) {
                        return a.timestamp < b.timestamp;
                    });
                    tx_informations_.insert_or_assign(current_coin.ticker, std::move(out));
                }
            }
        } while (not balance_thread_timer_.wait_for(30s));
    }

    void mm2::spawn_mm2_instance() noexcept {
        atomic_dex::mm2_config cfg{};
        nlohmann::json json_cfg;
        nlohmann::to_json(json_cfg, cfg);
        std::filesystem::path tools_path = ag::core::assets_real_path() / "tools/mm2/";
        DVLOG_F(loguru::Verbosity_INFO, "command line {}", json_cfg.dump());
        std::array<std::string, 2> args = {(tools_path / "mm2").string(), json_cfg.dump()};
        auto ec = this->mm2_instance_.start(args, reproc::options{
                nullptr, tools_path.string().c_str(),
                {
                        reproc::redirect::inherit,
                        reproc::redirect::inherit,
                        reproc::redirect::inherit
                }
        });
        if (ec) {
            DVLOG_F(loguru::Verbosity_ERROR, "error: {}", ec.message());
        }


        this->mm2_init_thread_ = std::thread([this]() {
            loguru::set_thread_name("mm2 init thread");
            using namespace std::chrono_literals;
            auto ec = mm2_instance_.wait(5s);
            if (ec == reproc::error::wait_timeout) {
                DVLOG_F(loguru::Verbosity_INFO, "mm2 is initialized");
                this->enable_default_coins();
                mm2_running_ = true;
                mm2_fetch_infos_thread_ = std::thread([this]() { this->fetch_infos_thread(); });
            } else {
                DVLOG_F(loguru::Verbosity_ERROR, "error: {}", ec.message());
            }
        });
    }

    std::string mm2::my_balance_with_locked_funds(const std::string &ticker, std::error_code &ec) const noexcept {
        if (balance_informations_.find(ticker) == balance_informations_.cend()) {
            ec = mm2_error::balance_of_a_non_enabled_coin;
            return "0";
        }
        ::mm2::api::balance_answer answer = balance_informations_.at(ticker);
        namespace bm = boost::multiprecision;
        bm::cpp_dec_float_50 balance(answer.balance);
        bm::cpp_dec_float_50 locked_funds(answer.locked_by_swaps);
        auto final_balance = balance - locked_funds;
        return final_balance.convert_to<std::string>();
    }

    std::vector<tx_infos> mm2::get_tx_history(const std::string &ticker, std::error_code &ec) const noexcept {
        if (tx_informations_.find(ticker) == tx_informations_.cend()) {
            ec = mm2_error::tx_history_of_a_non_enabled_coin;
            return {};
        }
        return tx_informations_.at(ticker);
    }

    std::string mm2::my_balance(const std::string &ticker, std::error_code &ec) const noexcept {
        if (balance_informations_.find(ticker) == balance_informations_.cend()) {
            ec = mm2_error::balance_of_a_non_enabled_coin;
            return "0";
        }
        return balance_informations_.at(ticker).balance;
    }

    ::mm2::api::withdraw_answer
    mm2::withdraw(::mm2::api::withdraw_request &&request, std::error_code &ec) const noexcept {
        auto result = ::mm2::api::rpc_withdraw(std::move(request));
        if (result.error.has_value()) {
            ec = mm2_error::rpc_withdraw_error;
        }
        return result;
    }

    ::mm2::api::send_raw_transaction_answer
    mm2::broadcast(::mm2::api::send_raw_transaction_request &&request, std::error_code &ec) const noexcept {
        auto result = ::mm2::api::rpc_send_raw_transaction(std::move(request));
        if (result.rpc_result_code == -1) {
            ec = mm2_error::rpc_send_raw_transaction_error;
        }
        return result;
    }
}
