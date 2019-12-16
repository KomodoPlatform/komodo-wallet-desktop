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

#pragma once

//! C++ System Headers
#include <atomic>
#include <thread>
#include <vector>

//! Dependencies Headers
#include <boost/multiprecision/cpp_dec_float.hpp>
#include <folly/concurrency/ConcurrentHashMap.h>
#include <reproc++/reproc.hpp>

//! SDK Headers
#include <antara/gaming/ecs/system.hpp>

//! Project Headers
#include "atomic.dex.coins.config.hpp"
#include "atomic.dex.events.hpp"
#include "atomic.dex.mm2.api.hpp"
#include "atomic.dex.mm2.error.code.hpp"
#include "atomic.dex.utilities.hpp"

namespace atomic_dex
{
	namespace bm = boost::multiprecision;
	namespace ag = antara::gaming;

	struct tx_infos
	{
		bool am_i_sender;
		std::size_t confirmations;
		std::vector<std::string> from;
		std::vector<std::string> to;
		std::string date;
		std::size_t timestamp;
		std::string tx_hash;
		std::string fees;
		std::string my_balance_change;
		std::string total_amount;
		std::size_t block_height;
		mm2_ec ec{ mm2_error::success };
	};

	//! Public typedefs
	using t_transactions = std::vector<tx_infos>;
	using t_float_50 = bm::cpp_dec_float_50;
	using t_coins = std::vector<coin_config>;

	class mm2 final : public ag::ecs::pre_update_system<mm2>
	{
	private:
		//! Private typedefs
		using t_mm2_time_point = std::chrono::high_resolution_clock::time_point;
		using t_coins_registry = folly::ConcurrentHashMap<std::string, coin_config>;
		using t_balance_registry = folly::ConcurrentHashMap<std::string, ::mm2::api::balance_answer>;
		using t_my_orders = folly::ConcurrentHashMap<std::string, ::mm2::api::my_orders_answer>;
		using t_tx_history_registry = folly::ConcurrentHashMap<std::string, std::vector<tx_infos>>;
		using t_orderbook_registry = folly::ConcurrentHashMap<std::string, ::mm2::api::orderbook_answer>;

		//! Process
		reproc::process mm2_instance_;

		//! Timers
		t_mm2_time_point orderbook_clock_;
		t_mm2_time_point info_clock_;

		//! Atomicity / Threads
		std::atomic_bool mm2_running_{ false };
		std::atomic_bool orderbook_thread_active{ false };
		thread_pool tasks_pool_{ 6 };
		std::thread mm2_init_thread_;

		//! Concurent Registry.
		t_coins_registry& coins_informations_{ entity_registry_.set<t_coins_registry>() };
		t_balance_registry& balance_informations_{ entity_registry_.set<t_balance_registry>() };
		t_tx_history_registry tx_informations_;
		t_my_orders orders_registry_;
		t_orderbook_registry current_orderbook_;

		void spawn_mm2_instance() noexcept;

		//! Refresh the current info (internally call process_balance and process_tx)
		void fetch_infos_thread();

		//! Refresh the current orderbook (internally call process_orderbook)
		void fetch_current_orderbook_thread();

		//! Refresh the balance registry (internal)
		void process_balance(const std::string& ticker) const noexcept;

		//! Refresh the orders registry (internal)
		void process_orders(const std::string& ticker) noexcept;

		//! Refresh the transaction registry (internal)
		void process_tx(const std::string& ticker) noexcept;

		//! Refresh the orderbook registry (internal)
		void process_orderbook(const std::string& base, const std::string& rel);

	public:
		//! Constructor
		explicit mm2(entt::registry& registry) noexcept;

		//! Destructor
		~mm2() noexcept final;

		//! Events
		void on_refresh_orderbook(const orderbook_refresh& evt) noexcept;

		void on_gui_enter_trading(const gui_enter_trading& evt) noexcept;

		void on_gui_leave_trading(const gui_leave_trading& evt) noexcept;

		//! Enable coins
		bool enable_default_coins() noexcept;

		bool enable_coin(const std::string& ticker) noexcept;

		//! Called every ticks, and execute tasks if the timer expire.
		void update() noexcept;

		//! Is MM2 Process correctly running ?
		[[nodiscard]] const std::atomic_bool& is_mm2_running() const noexcept;

		//! Retrieve my balance for a given ticker as a string.
		[[nodiscard]] std::string my_balance(const std::string& ticker, mm2_ec& ec) const noexcept;

		//! Retrieve my balance with lockeds funds for a given ticker as a string.
		[[nodiscard]] std::string my_balance_with_locked_funds(const std::string& ticker, mm2_ec& ec) const noexcept;

		//! Place a buy order, Doesn't work if i don't have enough funds.
		t_buy_answer place_buy_order(t_buy_request&& request, const t_float_50& total, mm2_ec& ec) const noexcept;

		//! Withdraw Money to another address
		[[nodiscard]] t_withdraw_answer withdraw(t_withdraw_request&& request, mm2_ec& ec) const noexcept;

		//! Broadcast a raw transaction on the blockchain
		[[nodiscard]] t_broadcast_answer broadcast(t_broadcast_request&& request, mm2_ec& ec) const noexcept;

		//! Last 50 transactions maximum
		[[nodiscard]] t_transactions get_tx_history(const std::string& ticker, mm2_ec& ec) const noexcept;

		//! Get coins that are currently enabled
		[[nodiscard]] t_coins get_enabled_coins() const noexcept;

		//! Get coins that are active, but may be not enabled
		[[nodiscard]] t_coins get_active_coins() const noexcept;

		//! Get coins that can be activated
		[[nodiscard]] t_coins get_enableable_coins() const noexcept;

		//! Get Specific info about one coin
		[[nodiscard]] coin_config get_coin_info(const std::string& ticker) const noexcept;

		//! Get Current orderbook
		[[nodiscard]] t_orderbook_answer get_current_orderbook(mm2_ec& ec) const noexcept;

		//! Get balance with locked funds for a given ticker as a boost::multiprecision::cpp_dec_float_50.
		[[nodiscard]] t_float_50 get_balance_with_locked_funds(const std::string& ticker) const;

		//! Return true if we the balance of the `ticker` > amount, false otherwise.
		[[nodiscard]] bool do_i_have_enough_funds(const std::string& ticker, const t_float_50& amount) const;
	};
}

REFL_AUTO(type(atomic_dex::mm2))
