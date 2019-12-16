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

//! C++ System Headers
#include <array>
#include <filesystem>
#include <fstream>
#include <future>

//! Dependencies Headers
#include <boost/algorithm/string/split.hpp>
#include <boost/multiprecision/cpp_dec_float.hpp>

//! SDK Headers
#include <antara/gaming/core/real.path.hpp>

//! Project Headers
#include "atomic.dex.mm2.config.hpp"
#include "atomic.dex.mm2.hpp"

//! Anonymous functions
namespace
{
    namespace ag = antara::gaming;

    void
    update_coin_status(const std::string& ticker)
    {
        std::filesystem::path cfg_path = ag::core::assets_real_path() / "config";
        std::ifstream         ifs(cfg_path / "coins.json");
        nlohmann::json        config_json_data;

        assert(ifs.is_open());
        ifs >> config_json_data;
        config_json_data.at(ticker)["active"] = true;
        ifs.close();

        //! Discard contents and rewrite all ?
        std::ofstream ofs(cfg_path / "coins.json", std::ios::trunc);
        assert(ofs.is_open());
        ofs << config_json_data;
    }

    bool
    retrieve_coins_information(folly::ConcurrentHashMap<std::string, atomic_dex::coin_config>& coins_registry) noexcept
    {
        const auto cfg_path = ag::core::assets_real_path() / "config";
        if (exists(cfg_path / "coins.json"))
        {
            std::ifstream ifs(cfg_path / "coins.json");
            assert(ifs.is_open());
            nlohmann::json config_json_data;
            ifs >> config_json_data;
            auto res = config_json_data.get<std::unordered_map<std::string, atomic_dex::coin_config>>();
            for (auto&& [key, value]: res) coins_registry.insert_or_assign(key, value);
            return true;
        }
        return false;
    }
} // namespace

namespace atomic_dex
{
    mm2::mm2(entt::registry& registry) noexcept : system(registry)
    {
        orderbook_clock_ = std::chrono::high_resolution_clock::now();
        info_clock_      = std::chrono::high_resolution_clock::now();
        dispatcher_.sink<gui_enter_trading>().connect<&mm2::on_gui_enter_trading>(*this);
        dispatcher_.sink<gui_leave_trading>().connect<&mm2::on_gui_leave_trading>(*this);
        dispatcher_.sink<orderbook_refresh>().connect<&mm2::on_refresh_orderbook>(*this);
        retrieve_coins_information(coins_informations_);
        spawn_mm2_instance();
    }

    void
    mm2::update() noexcept
    {
        if (not mm2_running_) return;
        using namespace std::chrono_literals;
        const auto now    = std::chrono::high_resolution_clock::now();
        const auto s      = std::chrono::duration_cast<std::chrono::seconds>(now - orderbook_clock_);
        const auto s_info = std::chrono::duration_cast<std::chrono::seconds>(now - info_clock_);
        if (s >= 5s)
        {
            tasks_pool_.enqueue([this]() { fetch_current_orderbook_thread(); });
            orderbook_clock_ = std::chrono::high_resolution_clock::now();
        }

        if (s_info >= 30s)
        {
            tasks_pool_.enqueue([this]() { fetch_infos_thread(); });
            info_clock_ = std::chrono::high_resolution_clock::now();
        }
    }

    mm2::~mm2() noexcept
    {
        const reproc::stop_actions stop_actions = {{reproc::stop::terminate, reproc::milliseconds(2000)},
                                                   {reproc::stop::kill, reproc::milliseconds(5000)},
                                                   {reproc::stop::wait, reproc::milliseconds(2000)}};

        mm2_running_  = false;
        const auto ec = mm2_instance_.stop(stop_actions);
        if (ec) { VLOG_SCOPE_F(loguru::Verbosity_ERROR, "error: %s", ec.message().c_str()); }
        mm2_init_thread_.join();
    }

    const std::atomic_bool&
    mm2::is_mm2_running() const noexcept
    {
        return mm2_running_;
    }

    t_coins
    mm2::get_enabled_coins() const noexcept
    {
        t_coins destination;
        for (auto&& [key, value]: coins_informations_)
        {
            if (value.currently_enabled) { destination.push_back(value); }
        }
        std::sort(begin(destination), end(destination), [](auto&& lhs, auto&& rhs) { return lhs.ticker < rhs.ticker; });
        return destination;
    }

    t_coins
    mm2::get_enableable_coins() const noexcept
    {
        t_coins destination;
        for (auto&& [key, value]: coins_informations_)
        {
            if (not value.currently_enabled) { destination.emplace_back(value); }
        }
        return destination;
    }

    t_coins
    mm2::get_active_coins() const noexcept
    {
        t_coins destination;
        for (auto&& [key, value]: coins_informations_)
        {
            if (value.active) { destination.emplace_back(value); }
        }
        return destination;
    }

    bool
    mm2::enable_coin(const std::string& ticker) noexcept
    {
        auto coin_info = coins_informations_.at(ticker);
        if (coin_info.currently_enabled) return true;
        t_electrum_request request{.coin_name = coin_info.ticker, .servers = coin_info.electrum_urls, .with_tx_history = true};
        auto               answer = rpc_electrum(std::move(request));
        if (answer.result not_eq "success") { return false; }
        coin_info.currently_enabled = true;
        coins_informations_.assign(coin_info.ticker, coin_info);
        if (not coin_info.active)
        {
            update_coin_status(ticker);
            coin_info.active = true;
        }
        dispatcher_.trigger<coin_enabled>(ticker);

        tasks_pool_.enqueue([this, ticker]() {
            loguru::set_thread_name("balance thread");
            process_balance(ticker);
        });

        tasks_pool_.enqueue([this, ticker]() {
            loguru::set_thread_name("tx thread");
            process_tx(ticker);
        });
        return true;
    }

    bool
    mm2::enable_default_coins() noexcept
    {
        using t_futures = std::vector<std::future<void>>;

        t_futures                futures;
        std::atomic<std::size_t> result{1};
        auto                     coins = get_active_coins();

        futures.reserve(coins.size());

        for (auto&& current_coin: coins)
        {
            futures.emplace_back(tasks_pool_.enqueue([this, ticker = current_coin.ticker]() {
                loguru::set_thread_name("enable thread");
                enable_coin(ticker);
            }));
        }

        for (auto&& fut: futures) fut.get();
        return result.load() == 1;
    }

    coin_config
    mm2::get_coin_info(const std::string& ticker) const noexcept
    {
        if (coins_informations_.find(ticker) == coins_informations_.cend()) return {};
        return coins_informations_.at(ticker);
    }

    t_orderbook_answer
    mm2::get_current_orderbook(mm2_ec& ec) const noexcept
    {
        if (current_orderbook_.empty())
        {
            ec = mm2_error::orderbook_empty;
            return {};
        }
        else
        {
            return current_orderbook_.begin()->second;
        }
    }

    void
    mm2::process_orderbook(const std::string& base, const std::string& rel)
    {
        t_orderbook_request request{.base = base, .rel = rel};
        auto                answer = rpc_orderbook(std::move(request));

        if (answer.rpc_result_code not_eq -1)
        {
            current_orderbook_.clear();
            current_orderbook_.insert_or_assign(base + "/" + rel, answer);
        }
    }

    void
    mm2::fetch_current_orderbook_thread()
    {
        loguru::set_thread_name("orderbook thread");
        DLOG_F(INFO, "Fetch current orderbook");
        //! If thread is not active ex: we are not on the trading page anymore, we continue sleeping.
        if (not orderbook_thread_active or current_orderbook_.empty())
        {
            DLOG_F(WARNING, "Nothing todo, sleeping...");
            return;
        }
        std::string              current = (*current_orderbook_.begin()).first;
        std::vector<std::string> results;
        boost::split(results, current, [](char c) { return c == '/'; });
        process_orderbook(results[0], results[1]);
    }

    void
    mm2::fetch_infos_thread()
    {
        loguru::set_thread_name("info thread");
        DVLOG_F(loguru::Verbosity_INFO, "Fetching Infos");
        t_coins                        coins = get_enabled_coins();
        std::vector<std::future<void>> futures;
        for (auto&& current_coin: coins)
        {
            futures.emplace_back(tasks_pool_.enqueue([this, ticker = current_coin.ticker]() {
                loguru::set_thread_name("balance thread");
                process_balance(ticker);
            }));
            futures.emplace_back(tasks_pool_.enqueue([this, ticker = current_coin.ticker]() {
                loguru::set_thread_name("tx thread");
                process_tx(ticker);
            }));
            futures.emplace_back(tasks_pool_.enqueue([this, ticker = current_coin.ticker]() {
                loguru::set_thread_name("orders thread");
                process_orders(ticker);
            }));
        }

        for (auto&& fut: futures) { fut.get(); }
    }

    void
    mm2::spawn_mm2_instance() noexcept
    {
        mm2_config cfg{};
        json       json_cfg;
        const auto tools_path = ag::core::assets_real_path() / "tools/mm2/";

        nlohmann::to_json(json_cfg, cfg);

        DVLOG_F(loguru::Verbosity_INFO, "command line {}", json_cfg.dump());

        const std::array<std::string, 2> args = {(tools_path / "mm2").string(), json_cfg.dump()};
        const auto                       ec =
            mm2_instance_.start(args, reproc::options{nullptr,
                                                      tools_path.string().c_str(),
                                                      {reproc::redirect::inherit, reproc::redirect::inherit, reproc::redirect::inherit}});
        if (ec) { DVLOG_F(loguru::Verbosity_ERROR, "error: {}", ec.message()); }


        mm2_init_thread_ = std::thread([this]() {
            loguru::set_thread_name("mm2 init thread");
            using namespace std::chrono_literals;
            const auto ec = mm2_instance_.wait(2s);
            if (ec == reproc::error::wait_timeout)
            {
                DVLOG_F(loguru::Verbosity_INFO, "mm2 is initialized");
                enable_default_coins();
                mm2_running_ = true;
                dispatcher_.trigger<mm2_started>();
            }
            else
            {
                DVLOG_F(loguru::Verbosity_ERROR, "error: {}", ec.message());
            }
        });
    }

    std::string
    mm2::my_balance_with_locked_funds(const std::string& ticker, mm2_ec& ec) const noexcept
    {
        if (balance_informations_.find(ticker) == balance_informations_.cend())
        {
            ec = mm2_error::balance_of_a_non_enabled_coin;
            return "0";
        }
        t_float_50 final_balance = get_balance_with_locked_funds(ticker);
        return final_balance.convert_to<std::string>();
    }

    t_float_50
    mm2::get_balance_with_locked_funds(const std::string& ticker) const
    {
        const auto       answer = balance_informations_.at(ticker);
        const t_float_50 balance(answer.balance);
        const t_float_50 locked_funds(answer.locked_by_swaps);
        auto             final_balance = balance - locked_funds;
        return final_balance;
    }

    t_transactions
    mm2::get_tx_history(const std::string& ticker, mm2_ec& ec) const noexcept
    {
        if (tx_informations_.find(ticker) == tx_informations_.cend())
        {
            ec = mm2_error::tx_history_of_a_non_enabled_coin;
            return {};
        }
        return tx_informations_.at(ticker);
    }

    std::string
    mm2::my_balance(const std::string& ticker, mm2_ec& ec) const noexcept
    {
        if (balance_informations_.find(ticker) == balance_informations_.cend())
        {
            ec = mm2_error::balance_of_a_non_enabled_coin;
            return "0";
        }
        return balance_informations_.at(ticker).balance;
    }

    t_withdraw_answer
    mm2::withdraw(t_withdraw_request&& request, mm2_ec& ec) const noexcept
    {
        auto result = rpc_withdraw(std::move(request));
        if (result.error.has_value()) { ec = mm2_error::rpc_withdraw_error; }
        return result;
    }

    t_broadcast_answer
    mm2::broadcast(t_broadcast_request&& request, mm2_ec& ec) const noexcept
    {
        auto result = rpc_send_raw_transaction(std::move(request));
        if (result.rpc_result_code == -1) { ec = mm2_error::rpc_send_raw_transaction_error; }
        return result;
    }

    void
    mm2::process_balance(const std::string& ticker) const noexcept
    {
        t_balance_request balance_request{.coin = ticker};
        balance_informations_.insert_or_assign(ticker, rpc_balance(std::move(balance_request)));
    }

    void
    mm2::process_orders(const std::string& ticker) noexcept
    {
        orders_registry_.insert_or_assign(ticker, ::mm2::api::rpc_my_orders());
    }

    void
    mm2::process_tx(const std::string& ticker) noexcept
    {
        t_tx_history_request tx_request{.coin = ticker, .limit = 50};
        auto                 answer = rpc_my_tx_history(std::move(tx_request));
        if (answer.error.has_value()) { VLOG_F(loguru::Verbosity_ERROR, "tx error: {}", answer.error.value()); }
        else if (answer.rpc_result_code not_eq -1 and answer.result.has_value())
        {
            t_transactions out;
            out.reserve(answer.result.value().transactions.size());
            for (auto&& current: answer.result.value().transactions)
            {
                tx_infos current_info{
                    .am_i_sender   = current.my_balance_change[0] == '-',
                    .confirmations = current.confirmations.has_value() ? current.confirmations.value() : 0,
                    .from          = current.from,
                    .to            = current.to,
                    .date          = current.timestamp_as_date,
                    .timestamp     = current.timestamp,
                    .tx_hash       = current.tx_hash,
                    .fees          = current.fee_details.normal_fees.has_value() ? current.fee_details.normal_fees.value().amount
                                                                        : current.fee_details.erc_fees.value().total_fee,
                    .my_balance_change = current.my_balance_change,
                    .total_amount      = current.total_amount,
                    .block_height      = current.block_height,
                    .ec                = mm2_error::success,
                };
                out.push_back(std::move(current_info));
            }
            std::sort(begin(out), end(out), [](auto&& a, auto&& b) { return a.timestamp > b.timestamp; });
            tx_informations_.insert_or_assign(ticker, std::move(out));
        }
    }

    void
    mm2::on_refresh_orderbook(const orderbook_refresh& evt) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        const auto key = evt.base + "/" + evt.rel;
        if (current_orderbook_.find(key) == current_orderbook_.cend()) { process_orderbook(evt.base, evt.rel); }
        else
        {
            DLOG_F(WARNING, "This book is already loaded, skipping");
        }
    }

    void
    mm2::on_gui_enter_trading([[maybe_unused]] const gui_enter_trading& evt) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        orderbook_thread_active = true;
    }

    void
    mm2::on_gui_leave_trading([[maybe_unused]] const gui_leave_trading& evt) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        orderbook_thread_active = false;
    }

    t_buy_answer
    mm2::place_buy_order(t_buy_request&& request, const t_float_50& total, mm2_ec& ec) const noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        mm2_ec balance_ec;
        if (not do_i_have_enough_funds(request.rel, total))
        {
            ec = mm2_error::balance_not_enough_found;
            return {};
        }
        auto answer = ::mm2::api::rpc_buy(std::move(request));
        if (answer.error.has_value())
        {
            ec = mm2_error::rpc_buy_error;
            return {};
        }
        return answer;
    }

    bool
    mm2::do_i_have_enough_funds(const std::string& ticker, const t_float_50& amount) const
    {
        auto funds = get_balance_with_locked_funds(ticker);
        return funds > amount;
    }
} // namespace atomic_dex
