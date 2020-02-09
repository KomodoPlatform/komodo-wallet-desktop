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

//! Project Headers
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.mm2.config.hpp"
#include "atomic.threadpool.hpp"

//! Anonymous functions
namespace
{
    namespace ag = antara::gaming;

    void
    update_coin_status(const std::vector<std::string> tickers, bool status = true)
    {
        std::filesystem::path cfg_path = ag::core::assets_real_path() / "config";
        std::ifstream         ifs(cfg_path / "coins.json");
        nlohmann::json        config_json_data;

        assert(ifs.is_open());
        ifs >> config_json_data;

        for (auto&& ticker: tickers) { config_json_data.at(ticker)["active"] = status; }

        ifs.close();

        //! Write contents
        std::ofstream ofs(cfg_path / "coins.json", std::ios::trunc);
        assert(ofs.is_open());
        ofs << config_json_data;
    }

    bool
    retrieve_coins_information(atomic_dex::t_coins_registry& coins_registry)
    {
        const auto cfg_path = ag::core::assets_real_path() / "config";
        if (exists(cfg_path / "coins.json"))
        {
            std::ifstream ifs(cfg_path / "coins.json");
            assert(ifs.is_open());
            nlohmann::json config_json_data;
            ifs >> config_json_data;
            auto res = config_json_data.get<std::unordered_map<std::string, atomic_dex::coin_config>>();
            for (auto&& [key, value]: res) { coins_registry.insert_or_assign(key, value); }
            return true;
        }
        return false;
    }
} // namespace

namespace atomic_dex
{
    mm2::mm2(entt::registry& registry) : system(registry)
    {
        m_orderbook_clock = std::chrono::high_resolution_clock::now();
        m_info_clock      = std::chrono::high_resolution_clock::now();

        dispatcher_.sink<gui_enter_trading>().connect<&mm2::on_gui_enter_trading>(*this);
        dispatcher_.sink<gui_leave_trading>().connect<&mm2::on_gui_leave_trading>(*this);
        dispatcher_.sink<orderbook_refresh>().connect<&mm2::on_refresh_orderbook>(*this);

        m_swaps_registry.insert("result", t_my_recent_swaps_answer{.total = 0});
        retrieve_coins_information(m_coins_informations);
    }

    void
    mm2::update() noexcept
    {
        using namespace std::chrono_literals;

        if (not m_mm2_running)
        {
            return;
        }

        const auto now    = std::chrono::high_resolution_clock::now();
        const auto s      = std::chrono::duration_cast<std::chrono::seconds>(now - m_orderbook_clock);
        const auto s_info = std::chrono::duration_cast<std::chrono::seconds>(now - m_info_clock);

        if (s >= 5s)
        {
            spawn([this]() { fetch_current_orderbook_thread(); });
            m_orderbook_clock = std::chrono::high_resolution_clock::now();
        }

        if (s_info >= 30s)
        {
            spawn([this]() { fetch_infos_thread(); });
            m_info_clock = std::chrono::high_resolution_clock::now();
        }
    }

    mm2::~mm2() noexcept
    {
        const reproc::stop_actions stop_actions = {{reproc::stop::terminate, reproc::milliseconds(2000)},
                                                   {reproc::stop::kill, reproc::milliseconds(5000)},
                                                   {reproc::stop::wait, reproc::milliseconds(2000)}};

        m_mm2_running = false;
        const auto ec = m_mm2_instance.stop(stop_actions);

        if (ec)
        {
            VLOG_SCOPE_F(loguru::Verbosity_ERROR, "error: %s", ec.message().c_str());
        }

        if (m_mm2_init_thread.joinable())
        {
            m_mm2_init_thread.join();
        }
    }

    const std::atomic_bool&
    mm2::is_mm2_running() const noexcept
    {
        return m_mm2_running;
    }

    t_coins
    mm2::get_enabled_coins() const noexcept
    {
        t_coins destination;

        for (auto&& [key, value]: m_coins_informations)
        {
            if (value.currently_enabled)
            {
                destination.push_back(value);
            }
        }

        std::sort(begin(destination), end(destination), [](auto&& lhs, auto&& rhs) { return lhs.ticker < rhs.ticker; });

        return destination;
    }

    t_coins
    mm2::get_enableable_coins() const noexcept
    {
        t_coins destination;

        for (auto&& [key, value]: m_coins_informations)
        {
            if (not value.currently_enabled)
            {
                destination.emplace_back(value);
            }
        }

        return destination;
    }

    t_coins
    mm2::get_active_coins() const noexcept
    {
        t_coins destination;

        for (auto&& [key, value]: m_coins_informations)
        {
            if (value.active)
            {
                destination.emplace_back(value);
            }
        }

        return destination;
    }

    bool
    mm2::disable_coin(const std::string& ticker, std::error_code& ec) noexcept
    {
        coin_config coin_info = m_coins_informations.at(ticker);
        if (not coin_info.currently_enabled)
        {
            return true;
        }

        t_disable_coin_request request{.coin = ticker};
        auto                   answer = rpc_disable_coin(std::move(request));

        if (answer.error.has_value())
        {
            std::string error = answer.error.value();
            if (error.find("such coin") != std::string::npos)
            {
                ec = dextop_error::disable_unknown_coin;
                return false;
            }
            else if (error.find("active swaps") != std::string::npos)
            {
                ec = dextop_error::active_swap_is_using_the_coin;
                return false;
            }
            else if (error.find("matching orders") != std::string::npos)
            {
                ec = dextop_error::order_is_matched_at_the_moment;
                return false;
            }
        }

        coin_info.currently_enabled = false;
        m_coins_informations.assign(coin_info.ticker, coin_info);

        dispatcher_.trigger<coin_disabled>(ticker);
        return true;
    }

    bool
    mm2::enable_coin(const std::string& ticker, bool emit_event)
    {
        coin_config coin_info = m_coins_informations.at(ticker);

        if (coin_info.currently_enabled)
        {
            return true;
        }

        if (not coin_info.is_erc_20)
        {
            t_electrum_request request{.coin_name = coin_info.ticker, .servers = coin_info.electrum_urls.value(), .with_tx_history = true};
            auto               answer = rpc_electrum(std::move(request));
            if (answer.result not_eq "success")
            {
                return false;
            }
        }
        else
        {
            t_enable_request request{.coin_name = coin_info.ticker, .urls = coin_info.eth_urls.value()};
            auto             answer = rpc_enable(std::move(request));
            if (answer.result not_eq "success")
            {
                return false;
            }
        }


        coin_info.currently_enabled = true;
        m_coins_informations.assign(coin_info.ticker, coin_info);

        spawn([this, copy_ticker = ticker]() {
            loguru::set_thread_name("balance thread");
            process_balance(copy_ticker);
        });

        spawn([this, copy_ticker = ticker]() {
            loguru::set_thread_name("tx thread");
            process_tx(copy_ticker);
        });

        dispatcher_.trigger<coin_enabled>(ticker);
        if (emit_event)
        {
            this->dispatcher_.trigger<enabled_coins_event>();
        }
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
            futures.emplace_back(spawn([this, ticker = current_coin.ticker]() {
                loguru::set_thread_name("enable thread");
                enable_coin(ticker);
            }));
        }

        for (auto&& fut: futures) { fut.get(); }

        this->dispatcher_.trigger<enabled_coins_event>();

        spawn([this]() {
            loguru::set_thread_name("swaps thread");
            process_swaps();
        });

        spawn([this]() {
            loguru::set_thread_name("orders thread");
            process_orders();
        });

        return result.load() == 1;
    }

    void
    mm2::disable_multiple_coins(const std::vector<std::string>& tickers) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);

        for (const auto& ticker: tickers)
        {
            spawn([this, ticker]() {
                loguru::set_thread_name("disable multiple coins");
                std::error_code ec;
                disable_coin(ticker, ec);
                if (ec)
                {
                    LOG_F(WARNING, "{}", ec.message());
                }
            });
        }

        update_coin_status(tickers, false);
    }

    void
    mm2::enable_multiple_coins(const std::vector<std::string>& tickers) noexcept
    {
        for (const auto& ticker: tickers)
        {
            spawn([this, ticker]() {
                loguru::set_thread_name("enable multiple coins");
                enable_coin(ticker, true);
            });
        }

        update_coin_status(tickers, true);
    }

    coin_config
    mm2::get_coin_info(const std::string& ticker) const
    {
        if (m_coins_informations.find(ticker) == m_coins_informations.cend())
        {
            return {};
        }
        return m_coins_informations.at(ticker);
    }

    t_orderbook_answer
    mm2::get_current_orderbook(t_mm2_ec& ec) const noexcept
    {
        if (m_current_orderbook.empty())
        {
            ec = dextop_error::orderbook_empty;
            return {};
        }
        return m_current_orderbook.begin()->second;
    }

    void
    mm2::process_orderbook(const std::string& base, const std::string& rel)
    {
        t_orderbook_request request{.base = base, .rel = rel};
        auto                answer = rpc_orderbook(std::move(request));

        if (answer.rpc_result_code not_eq -1)
        {
            m_current_orderbook.clear();
            m_current_orderbook.insert_or_assign(base + "/" + rel, answer);
        }
    }

    void
    mm2::fetch_current_orderbook_thread()
    {
        loguru::set_thread_name("orderbook thread");
        DLOG_F(INFO, "Fetch current orderbook");

        //! If thread is not active ex: we are not on the trading page anymore, we continue sleeping.
        if (not m_orderbook_thread_active or m_current_orderbook.empty())
        {
            DLOG_F(WARNING, "Nothing todo, sleeping...");
            return;
        }

        std::string              current = (*m_current_orderbook.begin()).first;
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

        futures.reserve(coins.size() * 2 + 2);

        futures.emplace_back(spawn([this]() {
            loguru::set_thread_name("swaps thread");
            process_swaps();
        }));

        futures.emplace_back(spawn([this]() {
            loguru::set_thread_name("orders thread");
            process_orders();
        }));

        for (auto&& current_coin: coins)
        {
            futures.emplace_back(spawn([this, ticker = current_coin.ticker]() {
                loguru::set_thread_name("balance thread");
                process_balance(ticker);
            }));
            futures.emplace_back(spawn([this, ticker = current_coin.ticker]() {
                loguru::set_thread_name("tx thread");
                process_tx(ticker);
            }));
        }

        for (auto&& fut: futures) { fut.get(); }
    }

    void
    mm2::spawn_mm2_instance(std::string passphrase)
    {
        mm2_config cfg{.passphrase = std::move(passphrase)};
        json       json_cfg;
        const auto tools_path = ag::core::assets_real_path() / "tools/mm2/";

        nlohmann::to_json(json_cfg, cfg);
        // DVLOG_F(loguru::Verbosity_INFO, "command line {}", json_cfg.dump());

        const std::array<std::string, 2> args          = {(tools_path / "mm2").string(), json_cfg.dump()};
        reproc::redirect                 redirect_type = reproc::redirect::inherit;
        const auto                       ec = m_mm2_instance.start(args, {nullptr, tools_path.string().c_str(), {redirect_type, redirect_type, redirect_type}});

        if (ec)
        {
            DVLOG_F(loguru::Verbosity_ERROR, "error: {}", ec.message());
        }

        m_mm2_init_thread = std::thread([this]() {
            using namespace std::chrono_literals;
            loguru::set_thread_name("mm2 init thread");

            const auto wait_ec = m_mm2_instance.wait(2s);

            if (wait_ec == reproc::error::wait_timeout)
            {
                DVLOG_F(loguru::Verbosity_INFO, "mm2 is initialized");
                dispatcher_.trigger<mm2_initialized>();
                enable_default_coins();
                m_mm2_running = true;
                dispatcher_.trigger<mm2_started>();
            }
            else
            {
                DVLOG_F(loguru::Verbosity_ERROR, "error: {}", wait_ec.message());
            }
        });
    }

    std::string
    mm2::my_balance_with_locked_funds(const std::string& ticker, t_mm2_ec& ec) const
    {
        if (m_balance_informations.find(ticker) == m_balance_informations.cend())
        {
            ec = dextop_error::balance_of_a_non_enabled_coin;
            return "0";
        }

        t_float_50 final_balance = get_balance_with_locked_funds(ticker);

        return final_balance.convert_to<std::string>();
    }

    t_float_50
    mm2::get_balance_with_locked_funds(const std::string& ticker) const
    {
        if (m_balance_informations.find(ticker) == m_balance_informations.end())
        {
            return 0;
        }
        const auto       answer = m_balance_informations.at(ticker);
        const t_float_50 balance(answer.balance);
        const t_float_50 locked_funds(answer.locked_by_swaps);
        auto             final_balance = balance - locked_funds;

        return final_balance;
    }

    t_transactions
    mm2::get_tx_history(const std::string& ticker, t_mm2_ec& ec) const
    {
        if (m_tx_informations.find(ticker) == m_tx_informations.cend())
        {
            ec = dextop_error::tx_history_of_a_non_enabled_coin;
            return {};
        }

        return m_tx_informations.at(ticker);
    }

    std::string
    mm2::my_balance(const std::string& ticker, t_mm2_ec& ec) const
    {
        if (m_balance_informations.find(ticker) == m_balance_informations.cend())
        {
            ec = dextop_error::balance_of_a_non_enabled_coin;
            return "0";
        }

        return m_balance_informations.at(ticker).balance;
    }

    t_withdraw_answer
    mm2::withdraw(t_withdraw_request&& request, t_mm2_ec& ec) noexcept
    {
        auto result = rpc_withdraw(std::move(request));
        if (result.error.has_value())
        {
            ec = dextop_error::rpc_withdraw_error;
        }
        return result;
    }

    t_broadcast_answer
    mm2::broadcast(t_broadcast_request&& request, t_mm2_ec& ec) noexcept
    {
        auto result = rpc_send_raw_transaction(std::move(request));
        if (result.rpc_result_code == -1)
        {
            ec = dextop_error::rpc_send_raw_transaction_error;
        }
        return result;
    }

    void
    mm2::process_balance(const std::string& ticker) const
    {
        t_balance_request balance_request{.coin = ticker};
        m_balance_informations.insert_or_assign(ticker, rpc_balance(std::move(balance_request)));
    }

    void
    mm2::process_swaps()
    {
        t_my_recent_swaps_request request{.limit = 50};
        auto                      answer = rpc_my_recent_swaps(std::move(request));
        if (answer.result.has_value())
        {
            m_swaps_registry.insert_or_assign("result", answer.result.value());
        }
    }

    void
    mm2::process_orders()
    {
        m_orders_registry.insert_or_assign("result", ::mm2::api::rpc_my_orders());
    }

    void
    mm2::process_tx(const std::string& ticker)
    {
        LOG_SCOPE_FUNCTION(INFO);
        t_tx_history_request tx_request{.coin = ticker, .limit = g_tx_max_limit};
        auto                 answer = rpc_my_tx_history(std::move(tx_request));

        if (answer.error.has_value())
        {
            VLOG_F(loguru::Verbosity_ERROR, "tx error: {}", answer.error.value());
        }
        else if (answer.rpc_result_code not_eq -1 and answer.result.has_value())
        {
            t_tx_state     state{.state = answer.result.value().sync_status.state, .current_block = answer.result.value().current_block};
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
                    .ec                = dextop_error::success,
                };
                if (get_coin_info(ticker).is_erc_20)
                {
                    current_info.tx_hash = "0x" + current_info.tx_hash;
                }
                out.push_back(std::move(current_info));
            }

            std::sort(begin(out), end(out), [](auto&& a, auto&& b) { return a.timestamp > b.timestamp; });

            m_tx_informations.insert_or_assign(ticker, std::move(out));
            m_tx_state.insert_or_assign(ticker, std::move(state));
            this->dispatcher_.trigger<tx_fetch_finished>();
        }
    }

    void
    mm2::on_refresh_orderbook(const orderbook_refresh& evt)
    {
        LOG_SCOPE_FUNCTION(INFO);

        const auto key = evt.base + "/" + evt.rel;

        if (m_current_orderbook.find(key) == m_current_orderbook.cend())
        {
            process_orderbook(evt.base, evt.rel);
        }
        else
        {
            DLOG_F(WARNING, "This book is already loaded, skipping");
        }
    }

    void
    mm2::on_gui_enter_trading([[maybe_unused]] const gui_enter_trading& evt) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);

        m_orderbook_thread_active = true;
    }

    void
    mm2::on_gui_leave_trading([[maybe_unused]] const gui_leave_trading& evt) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        m_orderbook_thread_active = false;
    }

    t_buy_answer
    mm2::place_buy_order(t_buy_request&& request, const t_float_50& total, t_mm2_ec& ec) const
    {
        LOG_SCOPE_FUNCTION(INFO);

        t_mm2_ec balance_ec;

        if (not do_i_have_enough_funds(request.rel, total))
        {
            ec = dextop_error::balance_not_enough_found;
            return {};
        }

        auto answer = ::mm2::api::rpc_buy(std::move(request));

        if (answer.error.has_value())
        {
            ec = dextop_error::rpc_buy_error;
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

    std::string
    mm2::address(const std::string& ticker, t_mm2_ec& ec) const noexcept
    {
        if (m_balance_informations.find(ticker) == m_balance_informations.cend())
        {
            ec = dextop_error::unknown_ticker;
            return "Invalid";
        }
        return m_balance_informations.at(ticker).address;
    }

    ::mm2::api::my_orders_answer
    mm2::get_orders(const std::string& ticker, t_mm2_ec& ec) const noexcept
    {
        static_cast<void>(ec);
        auto  result                = m_orders_registry.at("result");
        auto& taker                 = result.taker_orders;
        auto& maker                 = result.maker_orders;
        auto  is_ticker_not_present = [&ticker](const std::pair<std::size_t, t_my_order_contents>& contents) {
            return contents.second.base != ticker && contents.second.rel != ticker;
        };

        erase_if(taker, is_ticker_not_present);
        erase_if(maker, is_ticker_not_present);

        return result;
    }

    std::vector<::mm2::api::my_orders_answer>
    mm2::get_orders(t_mm2_ec& ec) const noexcept
    {
        auto                                      coins = get_enabled_coins();
        std::vector<::mm2::api::my_orders_answer> out;
        out.reserve(coins.size());
        for (auto&& coin: coins) { out.emplace_back(get_orders(coin.ticker, ec)); }
        return out;
    }

    t_my_recent_swaps_answer
    mm2::get_swaps() const noexcept
    {
        return m_swaps_registry.at("result");
    }

    t_sell_answer
    mm2::place_sell_order(t_sell_request&& request, const t_float_50& total, t_mm2_ec& ec) const
    {
        LOG_SCOPE_FUNCTION(INFO);

        t_mm2_ec balance_ec;

        if (not do_i_have_enough_funds(request.rel, total))
        {
            ec = dextop_error::balance_not_enough_found;
            return {};
        }

        auto answer = ::mm2::api::rpc_sell(std::move(request));

        if (answer.error.has_value())
        {
            ec = dextop_error::rpc_sell_error;
            return {};
        }

        return answer;
    }

    t_tx_state
    mm2::get_tx_state(const std::string& ticker, t_mm2_ec& ec) const
    {
        if (m_tx_state.find(ticker) == m_tx_state.cend())
        {
            ec = dextop_error::tx_history_of_a_non_enabled_coin;
            return {};
        }

        return m_tx_state.at(ticker);
    }

    bool
    mm2::is_claiming_ready(const std::string& ticker) const noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        using namespace std::chrono_literals;
        auto lock_claim_file_path = fs::temp_directory_path() / (ticker + ".claim.lock");

        DLOG_F(INFO, "checking if {} exist", lock_claim_file_path.string());
        if (not fs::exists(lock_claim_file_path))
        {
            return true;
        }

        if (fs::file_time_type::clock::now() - fs::last_write_time(lock_claim_file_path) > 1h)
        {
            DLOG_F(INFO, "1 hour expire, removing {}", lock_claim_file_path.string());
            fs::remove(lock_claim_file_path);
            return true;
        }
        return false;
    }

    t_withdraw_answer
    mm2::claim_rewards(const std::string& ticker, t_mm2_ec& ec) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        const auto& info = get_coin_info(ticker);
        if (not info.is_claimable || not do_i_have_enough_funds(ticker, t_float_50(info.minimal_claim_amount)))
        {
            ec = not info.is_claimable ? dextop_error::ticker_is_not_claimable : dextop_error::claim_not_enough_funds;
            return {};
        }
        t_withdraw_request req{.max = true, .coin = ticker, .amount = "0", .to = m_balance_informations.at(ticker).address};
        auto               answer = ::mm2::api::rpc_withdraw(std::move(req));
        return answer;
    }

    t_broadcast_answer
    mm2::send_rewards(t_broadcast_request&& req, t_mm2_ec& ec) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        auto ticker   = req.coin;
        auto b_answer = mm2::broadcast(std::move(req), ec);
        if (!ec)
        {
            auto          lock_claim_file_path = fs::temp_directory_path() / (ticker + ".claim.lock");
            std::ofstream ofs(lock_claim_file_path.string());
            assert(ofs);
            DLOG_F(INFO, "created file {}", lock_claim_file_path.string());
        }
        return b_answer;
    }
} // namespace atomic_dex
