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
#include <folly/concurrency/ConcurrentHashMap.h>
#include <reproc++/reproc.hpp>
#include <antara/gaming/ecs/system.hpp>
#include "atomic.dex.coins.config.hpp"
#include "atomic.dex.mm2.api.hpp"
#include "atomic.dex.utilities.hpp"
#include "atomic.dex.mm2.error.code.hpp"

namespace atomic_dex {
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
        std::error_code ec{ mm2_error::success };
	};
	
    class mm2 : public ag::ecs::pre_update_system<mm2> {
        reproc::process mm2_instance_;
        std::atomic<bool> mm2_running_{false};
        std::thread mm2_init_thread_;
        std::thread mm2_fetch_infos_thread_;
        timed_waiter balance_thread_timer_;
        using coins_enabled_array = std::vector<std::string>;
        coins_enabled_array active_coins_;
        using coins_registry = folly::ConcurrentHashMap<std::string, atomic_dex::coins_config>;
        coins_registry coins_informations_;
        using balance_registry = folly::ConcurrentHashMap<std::string, ::mm2::api::balance_answer>;
        balance_registry balance_informations_;
        using tx_history_registry = folly::ConcurrentHashMap<std::string, std::vector<tx_infos>>;
        tx_history_registry tx_informations_;

        void fetch_infos_thread();

        void spawn_mm2_instance() noexcept;

    public:
        bool enable_default_coins() noexcept;

        bool enable_coin(const std::string &ticker) noexcept;

        explicit mm2(entt::registry &registry) noexcept;

        ~mm2() noexcept;

        void update() noexcept final;

        [[nodiscard]] const std::atomic<bool> &is_mm2_running() const noexcept;

        std::string my_balance(const std::string &ticker, std::error_code& ec) const noexcept;

        std::string my_balance_with_locked_funds(const std::string &ticker, std::error_code& ec) const noexcept;

    	//! Last 50 transactions maximum
        [[nodiscard]] std::vector<tx_infos> get_tx_history(const std::string& ticker, std::error_code &ec) const noexcept;

        //! Get coins that are currently activated
        [[nodiscard]] std::vector<coins_config> get_enabled_coins() const noexcept;

        //! Get coins that can be activated
        [[nodiscard]] std::vector<coins_config> get_enableable_coins() const noexcept;

        //! Get Specific info about one coin
        [[nodiscard]] coins_config get_coin_info(const std::string &ticker) const noexcept;
    };
}

REFL_AUTO(type(atomic_dex::mm2))