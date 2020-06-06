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

//! PCH Headers
#include "atomic.dex.pch.hpp"

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
        bool                     am_i_sender;
        std::size_t              confirmations;
        std::vector<std::string> from;
        std::vector<std::string> to;
        std::string              date;
        std::size_t              timestamp;
        std::string              tx_hash;
        std::string              fees;
        std::string              my_balance_change;
        std::string              total_amount;
        std::size_t              block_height;
        t_mm2_ec                 ec{dextop_error::success};
    };

    struct tx_state
    {
        std::string state;
        std::size_t transactions_left;
        std::size_t blocks_left;
        std::size_t current_block;
    };

    using t_allocator = folly::AlignedSysAllocator<std::uint8_t, folly::FixedAlign<bit_size<std::size_t>()>>;
    template <typename Key, typename Value>
    using t_concurrent_reg = folly::ConcurrentHashMap<Key, Value, std::hash<Key>, std::equal_to<>, t_allocator>;
    using t_ticker         = std::string;
    using t_tx_state       = tx_state;
    using t_coins_registry = t_concurrent_reg<t_ticker, coin_config>;
    using t_transactions   = std::vector<tx_infos>;
    using t_coins          = std::vector<coin_config>;

    //! Constants
    inline constexpr const std::size_t g_tx_max_limit{50_sz};

    class mm2 final : public ag::ecs::pre_update_system<mm2>
    {
      private:
        //! Private typedefs
        using t_mm2_time_point      = std::chrono::high_resolution_clock::time_point;
        using t_balance_registry    = t_concurrent_reg<t_ticker, t_balance_answer>;
        using t_my_orders           = t_concurrent_reg<t_ticker, t_my_orders_answer>;
        using t_tx_history_registry = t_concurrent_reg<t_ticker, t_transactions>;
        using t_tx_state_registry   = t_concurrent_reg<t_ticker, t_tx_state>;
        using t_orderbook_registry  = t_concurrent_reg<t_ticker, std::vector<t_orderbook_answer>>;
        using t_swaps_registry      = t_concurrent_reg<t_ticker, t_my_recent_swaps_answer>;
        using t_swaps_avrg_datas    = t_concurrent_reg<t_ticker, std::string>;
        using t_fees_registry       = t_concurrent_reg<t_ticker, t_get_trade_fee_answer>;

        //! Process
        reproc::process m_mm2_instance;

        //! Current orderbook
        std::string m_current_orderbook_ticker_base{"KMD"};
        std::string m_current_orderbook_ticker_rel{"BTC"};
        std::mutex  m_orderbook_mutex;
        //! Timers
        t_mm2_time_point m_orderbook_clock;
        t_mm2_time_point m_info_clock;

        //! Atomicity / Threads
        std::atomic_bool m_mm2_running{false};
        std::atomic_bool m_orderbook_thread_active{false};
        std::thread      m_mm2_init_thread;

        //! Concurrent Registry.
        t_coins_registry&     m_coins_informations{entity_registry_.set<t_coins_registry>()};
        t_balance_registry&   m_balance_informations{entity_registry_.set<t_balance_registry>()};
        t_tx_history_registry m_tx_informations;
        t_tx_state_registry   m_tx_state;
        t_my_orders           m_orders_registry;
        t_fees_registry       m_trade_fees_registry;
        t_orderbook_registry  m_current_orderbook;
        t_swaps_registry      m_swaps_registry;
        t_swaps_avrg_datas    m_swaps_avrg_registry;

        //! Refresh the current orderbook (internally call process_orderbook)
        void fetch_current_orderbook_thread();

        //! Refresh the balance registry (internal)
        void process_balance(const std::string& ticker) const;

        //! Refresh the transaction registry (internal)
        void process_tx(const std::string& ticker);

        //! Refresh the fees registry (internal)
        void process_fees();

        //! Refresh the orderbook registry (internal)
        void process_orderbook(std::string base);

      public:
        //! Constructor
        explicit mm2(entt::registry& registry);

        //! Delete useless operator
        mm2(const mm2& other)  = delete;
        mm2(const mm2&& other) = delete;
        mm2& operator=(const mm2& other) = delete;
        mm2& operator=(const mm2&& other) = delete;

        //! Destructor
        ~mm2() noexcept final;

        //! Refresh the orders registry (internal)
        void process_orders();

        //! Events
        void on_refresh_orderbook(const orderbook_refresh& evt);

        void on_gui_enter_trading(const gui_enter_trading& evt) noexcept;

        void on_gui_leave_trading(const gui_leave_trading& evt) noexcept;

        //! Spawn mm2 instance with given seed
        void spawn_mm2_instance(std::string passphrase);

        //! Refresh the current info (internally call process_balance and process_tx)
        void fetch_infos_thread();

        //! Refresh the swaps history
        void process_swaps();

        //! Enable coins
        bool enable_default_coins() noexcept;

        //! Batch Enable coins
        void batch_enable_coins(const std::vector<std::string>& tickers, bool emit_event = false) noexcept;

        //! Enable multiple coins
        void enable_multiple_coins(const std::vector<std::string>& tickers) noexcept;

        //! Enable single coin
        bool enable_coin(const std::string& ticker, bool emit_event = false);

        //! Disable a single coin
        bool disable_coin(const std::string& ticker, std::error_code& ec) noexcept;

        //! Disable multiple coins, prefer this function if you want persistent disabling
        void disable_multiple_coins(const std::vector<std::string>& tickers) noexcept;

        //! Called every ticks, and execute tasks if the timer expire.
        void update() noexcept final;

        //! Check and process for logging rotation.
        void rotate_log() noexcept;

        //! Retrieve public address of the given ticker
        std::string address(const std::string& ticker, t_mm2_ec& ec) const noexcept;

        //! Is MM2 Process correctly running ?
        [[nodiscard]] const std::atomic_bool& is_mm2_running() const noexcept;

        //! Retrieve my balance for a given ticker as a string.
        [[nodiscard]] std::string my_balance(const std::string& ticker, t_mm2_ec& ec) const;

        //! Retrieve my balance with locked funds for a given ticker as a string.
        [[nodiscard]] std::string my_balance_with_locked_funds(const std::string& ticker, t_mm2_ec& ec) const;

        //! Place a buy order, Doesn't work if i don't have enough funds.
        t_buy_answer place_buy_order(t_buy_request&& request, const t_float_50& total, t_mm2_ec& ec) const;

        //! Place a buy order, Doesn't work if i don't have enough funds.
        t_sell_answer place_sell_order(t_sell_request&& request, const t_float_50& total, t_mm2_ec& ec) const;

        //! Withdraw Money to another address
        [[nodiscard]] static t_withdraw_answer withdraw(t_withdraw_request&& request, t_mm2_ec& ec) noexcept;

        //! Broadcast a raw transaction on the blockchain
        [[nodiscard]] static t_broadcast_answer broadcast(t_broadcast_request&& request, t_mm2_ec& ec) noexcept;

        //! Last 50 transactions maximum
        [[nodiscard]] t_transactions get_tx_history(const std::string& ticker, t_mm2_ec& ec) const;

        //! Last 50 transactions maximum
        [[nodiscard]] t_tx_state get_tx_state(const std::string& ticker, t_mm2_ec& ec) const;

        //! Claim Reward is possible on this specific ticker ?
        [[nodiscard]] bool is_claiming_ready(const std::string& ticker) const noexcept;

        //! Claim rewards
        t_withdraw_answer claim_rewards(const std::string& ticker, t_mm2_ec& ec) noexcept;

        //! Send Rewards
        t_broadcast_answer send_rewards(t_broadcast_request&& req, t_mm2_ec& ec) noexcept;

        //! Get coins that are currently enabled
        [[nodiscard]] t_coins get_enabled_coins() const noexcept;

        //! Get coins that are active, but may be not enabled
        [[nodiscard]] t_coins get_active_coins() const noexcept;

        //! Get coins that can be activated
        [[nodiscard]] t_coins get_enableable_coins() const noexcept;

        //! Get Specific info about one coin
        [[nodiscard]] coin_config get_coin_info(const std::string& ticker) const;

        [[nodiscard]] t_float_50  get_trade_fee(const std::string& ticker, const std::string& sell_amount, bool is_max) const;
        [[nodiscard]] std::string get_trade_fee_str(const std::string& ticker, const std::string& sell_amount, bool is_max) const;

        [[nodiscard]] t_get_trade_fee_answer get_trade_fixed_fee(const std::string& ticker) const;

        void apply_erc_fees(const std::string& ticker, t_float_50& value);
        ;

        //! Get Current orderbook
        [[nodiscard]] std::vector<t_orderbook_answer> get_orderbook(const std::string& ticker, t_mm2_ec& ec) const noexcept;

        //! Get orders
        [[nodiscard]] ::mm2::api::my_orders_answer              get_orders(const std::string& ticker, t_mm2_ec& ec) const noexcept;
        [[nodiscard]] std::vector<::mm2::api::my_orders_answer> get_orders(t_mm2_ec& ec) const noexcept;

        //! Get Swaps
        [[nodiscard]] t_my_recent_swaps_answer get_swaps() const noexcept;
        t_my_recent_swaps_answer               get_swaps() noexcept;

        //! Get balance with locked funds for a given ticker as a boost::multiprecision::cpp_dec_float_50.
        [[nodiscard]] t_float_50 get_balance_with_locked_funds(const std::string& ticker) const;

        //! Return true if we the balance of the `ticker` > amount, false otherwise.
        [[nodiscard]] bool do_i_have_enough_funds(const std::string& ticker, const t_float_50& amount) const;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::mm2))