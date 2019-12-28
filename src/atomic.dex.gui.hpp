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
#include "atomic.dex.gui.style.hpp"
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"

namespace atomic_dex
{
    namespace ag = antara::gaming;

    struct gui_variables
    {
        ImVec2                   main_window_size;
        std::vector<bool>        enableable_coins_select_list;
        std::vector<std::string> enableable_coins_select_list_tickers;
        std::string              curr_asset_code = "";

        struct startup_vars
        {
            struct new_user_vars
            {
                enum
                {
                    NONE,
                    SEED_CREATION,
                    SEED_RECOVERY
                } current_page = NONE;
            } new_user_page;

            struct seed_creation_vars
            {
                std::array<char, 3000> generated_seed_read_only{};
                std::array<char, 3000> generated_seed_confirm{};
                std::array<char, 100>  password_input{};
                bool                   show_password{false};
                std::string            error_text;
            } seed_creation_page;

            struct seed_recovery_vars
            {
                std::array<char, 3000> seed_input{};
                std::array<char, 100>  password_input{};
                bool                   show_password{false};
                std::string            error_text;
            } seed_recovery_page;

            struct login_vars
            {
                bool logged_in{true};

                std::array<char, 100> password_input{};
                bool                  show_password{false};
                std::string           error_text;
            } login_page;

            bool seed_exists{false};
        } startup_page;

        struct trade_vars
        {
            struct trade_sell_coin_vars
            {
                std::array<char, 100> price_input_buy{};
                std::array<char, 100> amount_input_buy{};
                std::array<char, 100> price_input_sell{};
                std::array<char, 100> amount_input_sell{};
                std::string   sell_error_text;
                std::string   buy_error_text;
            };

            std::string   current_base;
            std::string   current_rel;
            std::string   locked_base;
            std::string   locked_rel;
            t_sell_answer sell_request_answer;
            t_buy_answer  buy_request_answer;

            std::unordered_map<std::string, trade_sell_coin_vars> trade_sell_coin;
        } trade_page;

        struct orders_vars
        {
            std::string current_base;
        } orders_page;

        struct receive_vars
        {
            std::array<char, 100> address_read_only{};
        } receive_page;

        struct send_coin_vars
        {
            void
            clear()
            {
                answer           = {};
                broadcast_answer = {};
            }
            t_withdraw_answer     answer;
            t_broadcast_answer    broadcast_answer;
            std::array<char, 100> address_input{};
            double amount_input{0.0};
        };

        struct main_tabs_vars
        {
            bool in_exchange_prev{false};
            bool in_exchange{false};
            bool trigger_trade_tab{false};
        } main_tabs_page;

        std::unordered_map<std::string, send_coin_vars> send_coin;
    };

    class gui final : public ag::ecs::post_update_system<gui>
    {
#if defined(ENABLE_CODE_RELOAD_UNIX)
        std::unique_ptr<jet::Live> live_{nullptr};
#endif
      public:
        using icons_registry = t_concurrent_reg<std::string, antara::gaming::sdl::opengl_image>;

        void on_key_pressed(const ag::event::key_pressed& evt) noexcept;

        explicit gui(entt::registry& registry, mm2& mm2_system, coinpaprika_provider& paprika_system);

        // ReSharper disable once CppFinalFunctionInFinalClass
        void update() noexcept final;

        void init_live_coding();
        void reload_code();
        void update_live_coding();

        const icons_registry&
        get_icons() const noexcept
        {
            return icons_;
        }

      private:
        t_concurrent_reg<std::string, antara::gaming::sdl::opengl_image> icons_;
        gui_variables                                                    gui_vars_;
        mm2&                                                             mm2_system_;
        coinpaprika_provider&                                            paprika_system_;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::gui))
