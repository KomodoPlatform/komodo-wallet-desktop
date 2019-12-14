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

#include <thread>
#include <vector>
#include <atomic>
#include <boost/multiprecision/cpp_dec_float.hpp>
#include <folly/concurrency/ConcurrentHashMap.h>
#include <reproc++/reproc.hpp>
#include <taskflow/taskflow.hpp>
#include <antara/gaming/ecs/system.hpp>
#include "atomic.dex.coins.config.hpp"
#include "atomic.dex.mm2.api.hpp"
#include "atomic.dex.mm2.error.code.hpp"
#include "atomic.dex.events.hpp"

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
		std::error_code ec{mm2_error::success};
	};

	class mm2 final : public ag::ecs::pre_update_system<mm2>
	{
	private:
		tf::Executor executor_;
		tf::Taskflow orderbook_flow_;
		tf::Taskflow info_flow_;
		std::chrono::high_resolution_clock::time_point orderbook_clock_;
		std::chrono::high_resolution_clock::time_point info_clock_;
		using coins_registry = folly::ConcurrentHashMap<std::string, coin_config>;
		reproc::process mm2_instance_;
		std::atomic<bool> mm2_running_{false};
		std::atomic<bool> orderbook_thread_active{false};
		std::thread mm2_init_thread_;
		coins_registry& coins_informations_{this->entity_registry_.set<coins_registry>()};
		using balance_registry = folly::ConcurrentHashMap<std::string, ::mm2::api::balance_answer>;
		balance_registry& balance_informations_{this->entity_registry_.set<balance_registry>()};
		using tx_history_registry = folly::ConcurrentHashMap<std::string, std::vector<tx_infos>>;
		tx_history_registry tx_informations_;
		//! Key will be RICK/MORTY
		using orderbook_registry = folly::ConcurrentHashMap<std::string, ::mm2::api::orderbook_answer>;
		orderbook_registry current_orderbook_;

		void fetch_infos_thread();

		void fetch_current_orderbook_thread();

		void spawn_mm2_instance() noexcept;

		void process_balance(const std::string& ticker) const noexcept;
		void process_tx(const std::string& ticker) noexcept;

	public:
		void on_refresh_orderbook(const orderbook_refresh& evt) noexcept;
		void on_gui_enter_trading(const gui_enter_trading& evt) noexcept;
		void on_gui_leave_trading(const gui_leave_trading& evt) noexcept;
		bool enable_default_coins() noexcept;

		bool enable_coin(const std::string& ticker) noexcept;

		explicit mm2(entt::registry& registry) noexcept;

		~mm2() noexcept;

		void update() noexcept;

		[[nodiscard]] const std::atomic<bool>& is_mm2_running() const noexcept;

		std::string my_balance(const std::string& ticker, std::error_code& ec) const noexcept;

		std::string my_balance_with_locked_funds(const std::string& ticker, std::error_code& ec) const noexcept;

		::mm2::api::buy_answer place_buy_order(::mm2::api::buy_request&& request,
		                                       const bm::cpp_dec_float_50& total,
		                                       std::error_code& ec) const noexcept;

		[[nodiscard]] ::mm2::api::withdraw_answer
		withdraw(::mm2::api::withdraw_request&& request, std::error_code& ec) const noexcept;

		[[nodiscard]] ::mm2::api::send_raw_transaction_answer
		broadcast(::mm2::api::send_raw_transaction_request&& request, std::error_code& ec) const noexcept;

		//! Last 50 transactions maximum
		[[nodiscard]] std::vector<tx_infos>
		get_tx_history(const std::string& ticker, std::error_code& ec) const noexcept;

		//! Get coins that are currently enabled
		[[nodiscard]] std::vector<coin_config> get_enabled_coins() const noexcept;

		//! Get coins that are active, but may be not enabled
		[[nodiscard]] std::vector<coin_config> get_active_coins() const noexcept;

		//! Get coins that can be activated
		[[nodiscard]] std::vector<coin_config> get_enableable_coins() const noexcept;

		//! Get Specific info about one coin
		[[nodiscard]] coin_config get_coin_info(const std::string& ticker) const noexcept;
		[[nodiscard]] ::mm2::api::orderbook_answer get_current_orderbook(std::error_code& ec) const noexcept;
		void process_orderbook(const std::string& base, const std::string& rel);
	};
}

REFL_AUTO(type(atomic_dex::mm2))
