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
#include <filesystem>

//! Boost Headers
#include <boost/algorithm/string/case_conv.hpp>
#include <boost/multiprecision/cpp_dec_float.hpp>

//! Dependencies Headers
#include <entt/signal/dispatcher.hpp>
#include <IconsFontAwesome5.h>
#include <imgui.h>
#include <imgui_internal.h>

//! SDK Headers
#include <antara/gaming/core/open.url.browser.hpp>
#include <antara/gaming/core/real.path.hpp>
#include <antara/gaming/event/key.pressed.hpp>
#include <antara/gaming/event/quit.game.hpp>
#include <antara/gaming/graphics/component.canvas.hpp>

//! Project Headers
#include "atomic.dex.gui.hpp"
#include "atomic.dex.gui.widgets.hpp"
#include "atomic.dex.mm2.hpp"

namespace fs = std::filesystem;

// General Utility
namespace
{
    void copy_str(const std::string& input, char *dst, size_t dst_size)
    {
        strncpy(dst, input.c_str(), dst_size - 1);
        dst[dst_size - 1] = '\0';
    }
}

// Helpers
namespace
{
    ImVec4 value_color(128.f / 255.f, 128.f / 255.f, 128.f / 255.f, 1.f);
    ImVec4 bright_color{0, 149.f / 255.f, 143.f / 255.f, 1};
    ImVec4 dark_color{25.f / 255.f, 40.f / 255.f, 56.f / 255.f, 1};

    ImVec4 success_color(128.f / 255.f, 128.f / 255.f, 128.f / 255.f, 1.f);
    ImVec4 error_color{255.f / 255.f, 20.f / 255.f, 20.f / 255.f, 1};

    ImVec4 loss_color{1, 52.f / 255.f, 0, 1.f};
    ImVec4 gain_color{80.f / 255.f, 1, 118.f / 255.f, 1.f};

    std::string
    usd_str(const std::string& amt)
    {
        return amt + " USD";
    }

    bool is_digit_or_letter(char c, bool allow_symbols = false) {
        bool valid = std::isdigit(c) || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');

        if(allow_symbols && (c >= '!' && c <= '@')) valid = true;

        return valid;
    }
} // namespace

// Input filters
namespace {
    int input_filter_password(ImGuiInputTextCallbackData* data) {
        std::string str_data;
        if (data->UserData != nullptr) { str_data = static_cast<char*>(data->UserData); }
        auto c = data->EventChar;

        int valid = str_data.length() < 40 && is_digit_or_letter(c, true);

        return valid ? 0 : 1;
    }

    int input_filter_coin_amount(ImGuiInputTextCallbackData* data) {
      std::string str_data;
      if (data->UserData != nullptr) { str_data = static_cast<char*>(data->UserData); }
      auto c = data->EventChar;
      auto n = std::count(begin(str_data), end(str_data), '.');
      if (n == 1 && c == '.') { return 1; }

      return std::isdigit(c) || c == '.' ? 0 : 1;
    }

    int input_filter_coin_address(ImGuiInputTextCallbackData* data) {
      std::string str_data;
      if (data->UserData != nullptr) { str_data = static_cast<char*>(data->UserData); }
      auto c = data->EventChar;

      int valid = str_data.length() < 40 && is_digit_or_letter(c);

      return valid ? 0 : 1;
    }
}

// GUI Draw
namespace
{
    void
    gui_coin_name_img(const atomic_dex::gui& gui, const std::string ticker, const std::string name = "", bool name_first = false)
    {
        const auto& icons = gui.get_icons();
        const auto& img = icons.at(ticker);

        const auto text = !name.empty() ? name : ticker;
        if(name_first) {
            ImGui::TextWrapped("%s", text.c_str());
            ImGui::SameLine();
            ImGui::SetCursorPosX(ImGui::GetCursorPos().x + 5.f);
        }

        auto orig_text_pos = ImGui::GetCursorPos();
        const float custom_img_size = img.height * 0.8f;
        ImGui::SetCursorPos({ImGui::GetCursorPos().x, ImGui::GetCursorPos().y - (custom_img_size - ImGui::GetFont()->FontSize * 1.15f) * 0.5f});
        ImGui::Image(reinterpret_cast<ImTextureID>(img.id), ImVec2{custom_img_size, custom_img_size});

        if(!name_first) {
            auto pos_after_img = ImGui::GetCursorPos();
            ImGui::SameLine();
            ImGui::SetCursorPos(orig_text_pos);
            ImGui::SetCursorPosX(ImGui::GetCursorPos().x + custom_img_size + 5.f);
            ImGui::TextWrapped("%s", text.c_str());
            ImGui::SetCursorPos(pos_after_img);
        }
    }

    void
    gui_coin_name_img(const atomic_dex::gui& gui, const atomic_dex::coin_config& asset)
    {
        gui_coin_name_img(gui, asset.ticker, asset.name);
    }

    void gui_login_page(atomic_dex::gui_variables& gui_vars)
    {
        auto& vars = gui_vars.startup_page.login_page;
        auto& password_input = vars.password_input;
        auto& show_password  = vars.show_password;

        const ImVec2 child_size{ 392.f, 140.f};
        ImGui::SetCursorPosX((ImGui::GetWindowSize().x - child_size.x) * 0.5f);
        ImGui::BeginChild("##login_page_child", child_size, true);
        {
            ImGui::Text("Login");
            ImGuiInputTextFlags password_flags = ImGuiInputTextFlags_CallbackCharFilter;
            if (!show_password) password_flags |= ImGuiInputTextFlags_Password;
            ImGui::SetNextItemWidth(300.f);
            ImGui::InputText(
                "Password##login_page_password_input", password_input.data(), password_input.size(), password_flags, input_filter_password, password_input.data());
            if (ImGui::Button((std::string(show_password ? "Hide" : "Show") + " Password##login_page_show_password_button").c_str()))
            { show_password = !show_password; }
            ImGui::SameLine();
            if (ImGui::Button("Login##login_page_login_button")) { vars.logged_in = true; }
        }
        ImGui::EndChild();
    }    
    
    void gui_startup_page(atomic_dex::gui& gui, atomic_dex::gui_variables& gui_vars)
    {
        const auto& icons = gui.get_icons();
        const auto& img   = icons.at("APP_LOGO");

        const float custom_img_size = img.height * 0.8f;

        ImGui::SetCursorPos(ImVec2{(ImGui::GetWindowSize().x - custom_img_size) * 0.5f, (ImGui::GetWindowSize().y - custom_img_size) * 0.4f});
        ImGui::Image(reinterpret_cast<ImTextureID>(img.id), ImVec2{custom_img_size, custom_img_size});
        ImGui::SetCursorPosY(ImGui::GetCursorPosY() + 20.0f);

        gui_login_page(gui_vars);
    }

    void
    gui_menubar([[maybe_unused]] atomic_dex::gui& system) noexcept
    {
        if (ImGui::BeginMenuBar())
        {
            if (ImGui::MenuItem("Settings", "Ctrl+O"))
            { /* Do stuff */
            }
#if defined(ENABLE_CODE_RELOAD_UNIX)
            if (ImGui::MenuItem("Code Reloading", "Ctrl+O")) { system.reload_code(); }
#endif
            ImGui::EndMenuBar();
        }
    }

    void
    gui_portfolio_coins_list(atomic_dex::gui& gui, atomic_dex::mm2& mm2, atomic_dex::gui_variables& gui_vars)
    {
        ImGui::BeginChild("left pane", ImVec2(180, 0), true);
        int  i = 0;
        auto assets_contents = mm2.get_enabled_coins();
        for (auto it = assets_contents.begin(); it != assets_contents.end(); ++it, ++i)
        {
            auto& asset = *it;
            if (gui_vars.curr_asset_code.empty()) gui_vars.curr_asset_code = asset.ticker;
            if (ImGui::Selectable(("##" + asset.name).c_str(), asset.ticker == gui_vars.curr_asset_code)) { gui_vars.curr_asset_code = asset.ticker; }
            ImGui::SameLine();

            gui_coin_name_img(gui, asset);
        }
        ImGui::EndChild();
    }

    void
    gui_transaction_details_modal(atomic_dex::coinpaprika_provider& paprika_system, bool open_modal, const atomic_dex::coin_config& curr_asset, const atomic_dex::tx_infos& tx, atomic_dex::gui_variables& gui_vars)
    {
        ImGui::PushID(tx.tx_hash.c_str());

        if (open_modal) ImGui::OpenPopup("Transaction Details");

        ImGui::SetNextWindowSizeConstraints({0, 0}, {0, gui_vars.main_window_size.y - 50});
        if (ImGui::BeginPopupModal("Transaction Details", nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoMove))
        {
            std::error_code ec;

            ImGui::Separator();

            ImGui::Text("%s", tx.am_i_sender ? "Sent" : "Received");
            ImGui::TextColored(
                ImVec4(tx.am_i_sender ? loss_color : gain_color), "%s%s %s", tx.am_i_sender ? "" : "+",
                tx.my_balance_change.c_str(), curr_asset.ticker.c_str());
            ImGui::SameLine(300);
            ImGui::TextColored(value_color, "%s", usd_str(paprika_system.get_price_in_fiat_from_tx("USD", curr_asset.ticker, tx, ec)).c_str());

            if(tx.timestamp != 0) {
                ImGui::Separator();
                ImGui::Text("Date");
                ImGui::TextColored(value_color, "%s", tx.date.c_str());
            }

            ImGui::Separator();
            ImGui::Text("From");
            for (auto& addr: tx.from) ImGui::TextColored(value_color, "%s", addr.c_str());

            ImGui::Separator();

            ImGui::Text("To");
            for (auto& addr: tx.to) ImGui::TextColored(value_color, "%s", addr.c_str());

            ImGui::Separator();

            ImGui::Text("Fees");
            ImGui::TextColored(value_color, "%s", tx.fees.c_str());

            ImGui::Separator();

            ImGui::Text("Transaction Hash");
            ImGui::TextColored(value_color, "%s", tx.tx_hash.c_str());

            ImGui::Separator();

            ImGui::Text("Block Height");
            ImGui::TextColored(value_color, "%s", std::to_string(tx.block_height).c_str());

            ImGui::Separator();

            ImGui::Text("Confirmations");
            ImGui::TextColored(value_color, "%s", std::to_string(tx.confirmations).c_str());

            ImGui::Separator();

            if (ImGui::Button("Close")) ImGui::CloseCurrentPopup();

            ImGui::SameLine();

            if (ImGui::Button("View in Explorer")) antara::gaming::core::open_url_browser(curr_asset.explorer_url[0] + "tx/" + tx.tx_hash);

            ImGui::EndPopup();
        }

        ImGui::PopID();
    }

    void
    gui_portfolio_coin_details(atomic_dex::gui& gui, atomic_dex::mm2& mm2, atomic_dex::coinpaprika_provider& paprika_system, atomic_dex::gui_variables& gui_vars) noexcept
    {
        // Right
        const auto curr_asset = mm2.get_coin_info(gui_vars.curr_asset_code);
        ImGui::BeginChild("item view", ImVec2(0, 0), true);
        {
            gui_coin_name_img(gui, curr_asset);

            ImGui::Separator();

            std::error_code ec;

            ImGui::Text(std::string(std::string(reinterpret_cast<const char*>(ICON_FA_BALANCE_SCALE)) + " Balance: %s %s (%s USD)").c_str(),
                        mm2.my_balance(curr_asset.ticker, ec).c_str(), curr_asset.ticker.c_str(),
                        paprika_system.get_price_in_fiat("USD", curr_asset.ticker, ec).c_str());
            ImGui::Separator();
            if (ImGui::BeginTabBar("##Tabs", ImGuiTabBarFlags_None))
            {
                if (ImGui::BeginTabItem("Transactions"))
                {
                    std::error_code error_code;
                    auto tx_history = mm2.get_tx_history(curr_asset.ticker, error_code);
                    if (not tx_history.empty())
                    {
                        for (std::size_t i = 0; i < tx_history.size(); ++i)
                        {
                            auto  open_modal = false;
                            auto& tx         = tx_history[i];
                            ImGui::BeginGroup();
                            {
                                ImGui::Text("%s", tx.timestamp == 0 ? "" : tx.date.c_str());
                                ImGui::SameLine(300);
                                ImGui::TextColored(
                                    ImVec4(tx.am_i_sender ? loss_color : gain_color), "%s%s %s",
                                    tx.am_i_sender ? "" : "+", tx.my_balance_change.c_str(), curr_asset.ticker.c_str());
                                ImGui::TextColored(value_color, "%s", tx.am_i_sender ? tx.to[0].c_str() : tx.from[0].c_str());
                                ImGui::SameLine(300);
                                ImGui::TextColored(value_color, "%s", usd_str(paprika_system.get_price_in_fiat_from_tx("USD", curr_asset.ticker, tx, error_code)).c_str());
                            }
                            ImGui::EndGroup();
                            if (ImGui::IsItemClicked()) { open_modal = true; }

                            // Transaction Details modal
                            gui_transaction_details_modal(paprika_system, open_modal, curr_asset, tx, gui_vars);

                            if (i != tx_history.size() - 1) ImGui::Separator();
                        }
                    }
                    else ImGui::Text("No transactions");

                    ImGui::EndTabItem();
                }

                if (ImGui::BeginTabItem("Receive"))
                {
                    auto& vars = gui_vars.receive_page;
                    auto& address_read_only = vars.address_read_only;

                    std::error_code ec;
                    auto addr = mm2.address(curr_asset.ticker, ec);
                    copy_str(addr, address_read_only.data(), address_read_only.size());

                    ImGui::Text("Share the address below to receive coins");

                    ImGui::PushItemWidth(addr.length() * ImGui::GetFont()->FontSize * 0.5f);
                    ImGui::InputText("##receive_address", address_read_only.data(), addr.length(), ImGuiInputTextFlags_ReadOnly | ImGuiInputTextFlags_AutoSelectAll);
                    ImGui::PopItemWidth();

                    ImGui::EndTabItem();
                }

                if (ImGui::BeginTabItem("Send"))
                {
                    auto& vars = gui_vars.send_coin[curr_asset.ticker];
                    auto& answer = vars.answer;
                    auto& broadcast_answer = vars.broadcast_answer;
                    auto& address_input = vars.address_input;
                    auto& amount_input = vars.amount_input;

                    bool has_error = answer.rpc_result_code != 200;

                    // Transaction result
                    if(!broadcast_answer.tx_hash.empty() || !broadcast_answer.raw_result.empty()) {
                        has_error = broadcast_answer.rpc_result_code == -1;
                        // Failed transaction
                        if(has_error) {
                            ImGui::Text("Transaction Failed!");

                            // TODO: Make this error text readable
                            ImGui::Separator();
                            ImGui::Text("Error code");
                            ImGui::TextColored(error_color, "%d", broadcast_answer.rpc_result_code);

                            ImGui::Separator();
                            ImGui::Text("Error details");
                            ImGui::TextColored(error_color, "%s", broadcast_answer.raw_result.c_str());
                        }
                        // Successful transaction
                        else {
                            ImGui::TextColored(bright_color, "Transaction Succeed!");

                            ImGui::Separator();
                            ImGui::Text("Transaction Hash");
                            ImGui::TextColored(value_color, "%s", broadcast_answer.tx_hash.c_str());

                            ImGui::Separator();

                            if (ImGui::Button("Okay")) vars.clear();

                            ImGui::SameLine();
                            if (ImGui::Button("View in Explorer##tx_modal_view_transaction_button")) antara::gaming::core::open_url_browser(curr_asset.explorer_url[0] + "tx/" + broadcast_answer.tx_hash);
                        }
                    }
                    // Input page
                    else if(has_error || !answer.result.has_value()) {
                        const float width = 35 * ImGui::GetFont()->FontSize * 0.5f;
                        ImGui::SetNextItemWidth(width);
                        ImGui::InputText("Address##send_coin_address_input", address_input.data(), address_input.size(), ImGuiInputTextFlags_CallbackCharFilter, input_filter_coin_address, address_input.data());

                        ImGui::SetNextItemWidth(width);
                        ImGui::InputText("Amount##send_coin_amount_input", amount_input.data(), amount_input.size(), ImGuiInputTextFlags_CallbackCharFilter, input_filter_coin_amount, amount_input.data());
                        ImGui::SameLine();

                        auto balance = mm2.my_balance(curr_asset.ticker, ec);

                        if (ImGui::Button("MAX##send_coin_max_amount_button")) {
                            copy_str(balance, amount_input.data(), amount_input.size());
                        }

                        if (ImGui::Button("Send##send_coin_button")) {
                            mm2::api::withdraw_request request{curr_asset.ticker, address_input.data(), amount_input.data(), balance == amount_input.data()};
                            answer = mm2::api::rpc_withdraw(std::move(request));
                        }

                        if(has_error) {
                            // TODO: Make this readable
                            ImGui::TextColored(error_color, "%s", answer.raw_result.c_str());
                        }
                        else {
                            ImGui::TextColored(error_color, "No errors");
                        }
                    }
                    else {
                        auto result = answer.result.value();

                        ImGui::Text("You are sending");
                        ImGui::TextColored(bright_color, "%s", amount_input.data());

                        ImGui::Separator();
                        ImGui::Text("To address");
                        for (auto& addr: result.to) ImGui::TextColored(value_color, "%s", addr.c_str());

                        ImGui::Separator();
                        ImGui::Text("Fee");
                        ImGui::TextColored(value_color, "%s", result.fee_details.normal_fees.value().amount.c_str());

                        if (ImGui::Button("Cancel##cancel_send")) vars.clear();

                        ImGui::SameLine();

                        if (ImGui::Button("Confirm##confirm_send")) {
                            broadcast_answer = mm2::api::rpc_send_raw_transaction({curr_asset.ticker, result.tx_hex});
                        }
                    }

                    ImGui::EndTabItem();
                }

                ImGui::EndTabBar();
            }
        }
        ImGui::EndChild();
    }

    void gui_orders_list(atomic_dex::gui& gui, const std::map<std::size_t, mm2::api::my_order_contents>& orders) {
        for(auto it = orders.begin(); it != orders.end(); ++it) {
            auto& info = it->second;

            gui_coin_name_img(gui, info.base);
            ImGui::SameLine();
            ImGui::SetCursorPosX(180);
            ImGui::Text("< >");
            ImGui::SameLine();
            ImGui::SetCursorPosX(300);
            gui_coin_name_img(gui, info.rel, "", true);

            ImGui::TextColored(loss_color, "%s %s", info.available_amount.c_str(), info.base.c_str());

            ImGui::TextColored(value_color, "Price: %s", info.price.c_str());
            ImGui::SameLine(250);
            ImGui::TextColored(value_color, "%s", info.human_timestamp.c_str());
            ImGui::TextColored(value_color, "Order ID: %s", info.order_id.c_str());

            if (ImGui::Button("Cancel##cancel_order")) {
                mm2::api::rpc_cancel_order({ info.order_id });
            }

            auto next = it;
            if(++next != orders.end()) ImGui::Separator();
        }
    }

    void
    gui_enable_coins(atomic_dex::mm2& mm2, atomic_dex::gui_variables& gui_vars)
    {
        if (ImGui::Button("Enable a coin")) ImGui::OpenPopup("Enable coins");
        if (ImGui::BeginPopupModal("Enable coins", nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoMove))
        {
            auto enableable_coins = mm2.get_enableable_coins();
            ImGui::Text(enableable_coins.empty() ? "All coins are already enabled!" : "Select the coins you want to add to your portfolio.");

            if (!enableable_coins.empty()) ImGui::Separator();

            auto& select_list = gui_vars.enableable_coins_select_list;
            // Extend the size of selectables list if the new list is bigger
            if (enableable_coins.size() > select_list.size()) select_list.resize(enableable_coins.size(), false);

            // Create the list
            for (std::size_t i = 0; i < enableable_coins.size(); ++i)
            {
                auto& coin = enableable_coins[i];

                if (ImGui::Selectable((coin.name + " (" + coin.ticker + ")").c_str(), select_list[i], ImGuiSelectableFlags_DontClosePopups))
                    select_list[i] = !select_list[i];
            }

            bool close = false;
            if (enableable_coins.empty())
            {
                if (ImGui::Button("Close")) close = true;
            }
            else
            {
                if (ImGui::Button("Enable", ImVec2(120, 0)))
                {
                    // Enable selected coins
                    for (std::size_t i = 0; i < enableable_coins.size(); ++i)
                    {
                        if (select_list[i]) mm2.enable_coin(enableable_coins[i].ticker);
                    }
                    close = true;
                }

                ImGui::SameLine();

                if (ImGui::Button("Cancel", ImVec2(120, 0))) close = true;
            }

            if (close)
            {
                // Reset the list
                std::fill(select_list.begin(), select_list.end(), false);
                ImGui::CloseCurrentPopup();
            }

            ImGui::EndPopup();
        }
    }

    void
    gui_portfolio(atomic_dex::gui& gui, atomic_dex::mm2& mm2, atomic_dex::coinpaprika_provider& paprika_system, atomic_dex::gui_variables& gui_vars)
    {
        std::error_code ec;
        ImGui::Text("Total Balance: %s", usd_str(paprika_system.get_price_in_fiat_all("USD", ec)).c_str());

        gui_enable_coins(mm2, gui_vars);

        // Left
        gui_portfolio_coins_list(gui, mm2, gui_vars);

        // Right
        ImGui::SameLine();
        gui_portfolio_coin_details(gui, mm2, paprika_system, gui_vars);
    }

    void gui_amount_per_coin(const atomic_dex::gui& gui, const std::string& base, const std::string& rel) {
        gui_coin_name_img(gui, rel);
        ImGui::SameLine();
        ImGui::Text("amount per");
        ImGui::SameLine();
        gui_coin_name_img(gui, base);
    }

    void gui_orderbook_table(const atomic_dex::gui& gui, const std::string& base, const std::string& rel, const std::string& action, const std::vector<mm2::api::order_contents>& list, std::error_code ec) {
        ImGui::Columns(2, ("orderbook_columns_" + action).c_str());

        gui_coin_name_img(gui, action == "Buy" ? rel : base);
        ImGui::SameLine();
        ImGui::Text("Sellers, Volume");
        ImGui::NextColumn();
        gui_amount_per_coin(gui, base, rel);

        if(!list.empty()) {
            ImGui::Separator();

            if (!ec)
            {
                for (const auto & content : list) {
                    ImGui::NextColumn();
                    ImGui::Text("%s", content.maxvolume.c_str());
                    ImGui::NextColumn();
                    ImGui::Text("%s", content.price.c_str());
                }
            }
            else DLOG_F(WARNING, "{}", ec.message());
        }

        ImGui::Columns(1);
    }

    void gui_disable_items() {
        ImGui::PushItemFlag(ImGuiItemFlags_Disabled, true);
        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, ImGui::GetStyle().Alpha * 0.5f);
    }

    void gui_enable_items() {
        ImGui::PopStyleVar();
        ImGui::PopItemFlag();
    }

    void gui_buy_sell_coin(const atomic_dex::gui& gui, atomic_dex::mm2& mm2, atomic_dex::gui_variables& gui_vars, const std::string& base, const std::string& rel, const std::string& action) {
        auto& vars = gui_vars.trade_page;
        auto& sell_answer = vars.sell_request_answer;
        auto& buy_answer = vars.buy_request_answer;

        ImGui::Text("%s", action.c_str());
        ImGui::SameLine();
        gui_coin_name_img(gui, base, "", true);

        ImGui::SameLine();
        std::error_code ec;
        ImGui::Text("(%s)", mm2.my_balance(base, ec).c_str());

        auto& coin_vars = vars.trade_sell_coin[base];
        auto& price_input = action == "Buy" ? coin_vars.price_input_buy : coin_vars.price_input_sell;
        auto& amount_input = action == "Buy" ? coin_vars.amount_input_buy : coin_vars.amount_input_sell;

        ImGui::SetNextItemWidth(125.0f);
        ImGui::InputText(("Volume##trade_sell_volume" + action).c_str(), amount_input.data(), amount_input.size(), ImGuiInputTextFlags_CallbackCharFilter, input_filter_coin_amount, amount_input.data());

        ImGui::SetNextItemWidth(125.0f);
        ImGui::InputText(("Price##trade_sell_price" + action).c_str(), price_input.data(), price_input.size(), ImGuiInputTextFlags_CallbackCharFilter, input_filter_coin_amount, price_input.data());

        std::string total;
        std::string current_price  = price_input.data();
        std::string current_amount = amount_input.data();
        boost::multiprecision::cpp_dec_float_50 current_price_f{};
        boost::multiprecision::cpp_dec_float_50 current_amount_f{};
        boost::multiprecision::cpp_dec_float_50 total_amount;
        bool fields_are_filled = not current_price.empty() && not current_amount.empty();
        if (fields_are_filled)
        {
            current_price_f.assign(current_price);
            current_amount_f.assign(current_amount);
            total_amount = current_price_f * current_amount_f;
            total = total_amount.convert_to<std::string>();
        }

        bool has_funds = current_amount.empty() || mm2.do_i_have_enough_funds(action == "Sell" ? base : rel, action == "Sell" ? current_amount_f : total_amount);
        bool enable = fields_are_filled && has_funds;

        if(!has_funds) {
            std::error_code ec;

            ImGui::TextColored(error_color, "Not enough funds, you have %s %s",
                mm2.my_balance_with_locked_funds(action == "Sell" ? base : rel, ec).c_str(),
                (action == "Sell" ? base : rel).c_str());
        }

        if (not enable)
        {
            gui_disable_items();
        }
        else {
            if(fields_are_filled) ImGui::TextColored(bright_color, "You'll receive %s %s",
                (action == "Buy" ? current_amount_f.convert_to<std::string>() : total).c_str(), (action == "Sell" ? rel : base).c_str());
        }

        if (ImGui::Button((action + "##buy_sell_coin_submit_button").c_str())) {
            std::error_code ec;

            if(action == "Sell") {
                atomic_dex::t_sell_request request{.base = base, .rel = rel, .price = current_price, .volume = current_amount};
                sell_answer = mm2.place_sell_order(std::move(request), current_amount_f, ec);
            }
            else {
                atomic_dex::t_buy_request request{.base = base, .rel = rel, .price = current_price, .volume = current_amount};
                buy_answer = mm2.place_buy_order(std::move(request), total_amount, ec);
            }

            if (ec) { LOG_F(ERROR, "{}", ec.message()); }
        }
        if (not enable) gui_enable_items();


        auto raw_result = action == "Sell" ? sell_answer.raw_result : buy_answer.raw_result;
        auto rpc_result_code = action == "Sell" ? sell_answer.rpc_result_code : buy_answer.rpc_result_code;

        if(rpc_result_code == -1) {
            ImGui::Separator();
            ImGui::Text("Failed to sell");

            ImGui::Separator();
            ImGui::Text("Error code");
            ImGui::TextColored(error_color, "%d", rpc_result_code);

            ImGui::Separator();
            ImGui::Text("Error details");
            ImGui::TextColored(error_color, "%s", raw_result.c_str());
        }
        else if(not raw_result.empty()) {
            ImGui::Separator();
            ImGui::TextColored(bright_color, "%s order placed!", action.c_str());
            ImGui::TextColored(bright_color, "Please wait until it appears at order list");
        }
    }
} // namespace

namespace atomic_dex
{
#if defined(ENABLE_CODE_RELOAD_UNIX)
    //! Platform dependent code
    class AtomicDexHotCodeListener : public jet::ILiveListener
    {
      public:
        void
        onLog(jet::LogSeverity severity, const std::string& message) override
        {
            std::string severityString;
            auto        verbosity = loguru::Verbosity_INFO;
            switch (severity)
            {
            case jet::LogSeverity::kDebug:
                severityString.append("[D]");
                verbosity = loguru::Verbosity_INFO;
                break;
            case jet::LogSeverity::kInfo:
                severityString.append("[I]");
                verbosity = loguru::Verbosity_INFO;
                break;
            case jet::LogSeverity::kWarning:
                severityString.append("[W]");
                verbosity = loguru::Verbosity_WARNING;
                break;
            case jet::LogSeverity::kError:
                severityString.append("[E]");
                verbosity = loguru::Verbosity_ERROR;
                break;
            }
            DVLOG_F(verbosity, "{}", message);
        }
    };
#endif

    // ReSharper disable once CppMemberFunctionMayBeStatic
    void
    gui::reload_code()
    {
        DVLOG_F(loguru::Verbosity_INFO, "reloading code");
#if defined(ENABLE_CODE_RELOAD_UNIX)
        live_->tryReload();
#endif
    }

    // ReSharper disable once CppMemberFunctionMayBeStatic
    void
    gui::init_live_coding()
    {
#if defined(ENABLE_CODE_RELOAD_UNIX)
        live_ = jet::make_unique<jet::Live>(jet::make_unique<AtomicDexHotCodeListener>());
        while (!live_->isInitialized())
        {
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
            live_->update();
        }
        live_->update();
#endif
    }

    // ReSharper disable once CppMemberFunctionMayBeStatic
    void
    gui::update_live_coding()
    {
#if defined(ENABLE_CODE_RELOAD_UNIX)
        live_->update();
#endif
    }
} // namespace atomic_dex

namespace atomic_dex
{
    void
    gui::on_key_pressed(const ag::event::key_pressed& evt) noexcept
    {
        if (evt.key == ag::input::r && evt.control) { reload_code(); }
    }

    gui::gui(entt::registry& registry, mm2& mm2_system, coinpaprika_provider& paprika_system) :
        system(registry), mm2_system_(mm2_system), paprika_system_(paprika_system)
    {
        const auto p = antara::gaming::core::assets_real_path() / "textures";
        for (auto& directory_entry: fs::directory_iterator(p))
        {
            antara::gaming::sdl::opengl_image img{};
            const auto                        res = load_image(directory_entry, img);
            if (!res) continue;
            icons_.insert_or_assign(boost::algorithm::to_upper_copy(directory_entry.path().stem().string()), img);
        }

        init_live_coding();
        style::apply();
        this->dispatcher_.sink<ag::event::key_pressed>().connect<&gui::on_key_pressed>(*this);
    }

    void
    gui::update() noexcept
    {
        update_live_coding();
        //update_live_coding();

        //! Menu bar
        auto& canvas = entity_registry_.ctx<ag::graphics::canvas_2d>();
        auto [x, y]  = canvas.window.size;

        ImGui::SetNextWindowSize(ImVec2(x, y), ImGuiCond_FirstUseEver);
        bool active = true;
        ImGui::Begin("atomicDEX", &active, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_MenuBar);
        gui_vars_.main_window_size = ImGui::GetWindowSize();
        if (not active && mm2_system_.is_mm2_running()) { this->dispatcher_.trigger<ag::event::quit_game>(0); }
        if (!mm2_system_.is_mm2_running())
        {
            ImGui::Text("Loading, please wait...");
            const float  radius = 30.0f;
            const ImVec2 position((ImGui::GetWindowSize().x) * 0.5f - radius, (ImGui::GetWindowSize().y) * 0.5f - radius);
            ImGui::SetCursorPos(position);
            widgets::LoadingIndicatorCircle("foo", radius, ImVec4(bright_color), ImVec4(dark_color), 9, 1.5f);
        }
        else
        {
            if(!gui_vars_.startup_page.login_page.logged_in) {
                gui_startup_page(*this, gui_vars_);
            }
            else {
                gui_menubar(*this);

                if (ImGui::BeginTabBar("##Tabs", ImGuiTabBarFlags_None))
                {
                    auto& vars = gui_vars_.main_tabs_page;
                    auto& in_exchange = vars.in_exchange;
                    auto& in_exchange_prev = vars.in_exchange_prev;
                    auto& trigger_trade_tab = vars.trigger_trade_tab;

                    if (ImGui::BeginTabItem("Portfolio"))
                    {
                        ImGuiIO& io                       = ImGui::GetIO();
                        io.ConfigViewportsNoAutoMerge     = false;
                        io.ConfigViewportsNoDefaultParent = false;
                        gui_portfolio(*this, mm2_system_, paprika_system_, gui_vars_);
                        ImGui::EndTabItem();
                    }

                    if (ImGui::BeginTabItem("Exchange"))
                    {
                        in_exchange = true;
                        if (ImGui::BeginTabBar("##ExchangeTabs", ImGuiTabBarFlags_None))
                        {
                            if (ImGui::BeginTabItem("Trade", nullptr, trigger_trade_tab ? ImGuiTabItemFlags_SetSelected : 0))
                            {
                                trigger_trade_tab = false;

                                auto& vars = gui_vars_.trade_page;
                                auto& current_base = vars.current_base;
                                auto& current_rel = vars.current_rel;
                                auto& locked_base = vars.locked_base;
                                auto& locked_rel = vars.locked_rel;

                                const float remaining_width = ImGui::GetContentRegionAvail().x - ImGui::GetStyle().ItemSpacing.x;

                                ImGui::Text("Select the pair you want to trade");

                                ImGui::SetNextItemWidth(remaining_width / 6);
                                if (ImGui::BeginCombo("##left", current_base.c_str()))
                                {
                                    auto coins = mm2_system_.get_enabled_coins();
                                    for (auto&& current: coins)
                                    {
                                        if (current.ticker == current_rel) continue;
                                        const bool is_selected = current.ticker == current_base;
                                        if (ImGui::Selectable(current.ticker.c_str(), is_selected)) { current_base = current.ticker; }
                                        if (is_selected) { ImGui::SetItemDefaultFocus(); }
                                    }
                                    ImGui::EndCombo();
                                }

                                ImGui::SameLine();
                                ImGui::SetNextItemWidth(remaining_width / 6);
                                if (ImGui::BeginCombo("##right", current_rel.c_str()))
                                {
                                    const auto coins = mm2_system_.get_enabled_coins();

                                    for (auto&& current: coins)
                                    {
                                        if (current.ticker == current_base) continue;
                                        const bool is_selected = current.ticker == current_rel;
                                        if (ImGui::Selectable(current.ticker.c_str(), is_selected)) { current_rel = current.ticker; }
                                        if (is_selected) { ImGui::SetItemDefaultFocus(); }
                                    }

                                    ImGui::EndCombo();
                                }
                                ImGui::SameLine();

                                bool coins_are_selected = not current_base.empty() && not current_rel.empty();

                                if(!coins_are_selected) gui_disable_items();

                                bool load_orderbook = false;
                                if (ImGui::Button("Load") && not current_base.empty() && not current_rel.empty()) {
                                    load_orderbook = true;
                                }

                                ImGui::SameLine();
                                if (ImGui::Button("Swap") && not current_base.empty() && not current_rel.empty())
                                {
                                    auto tmp = current_base;
                                    current_base = current_rel;
                                    current_rel = tmp;
                                    load_orderbook = true;
                                }

                                if (!coins_are_selected) gui_enable_items();

                                if(load_orderbook) {
                                    locked_base = current_base;
                                    locked_rel  = current_rel;
                                    this->dispatcher_.trigger<orderbook_refresh>(current_base, current_rel);
                                }

                                if (not locked_base.empty() && not locked_rel.empty())
                                {
                                    ImGui::BeginChild("Sell Window", ImVec2(275, 0), true);
                                    {
                                        gui_buy_sell_coin(*this, mm2_system_, gui_vars_, locked_base, locked_rel, "Buy");

                                        ImGui::Separator();

                                        gui_buy_sell_coin(*this, mm2_system_, gui_vars_, locked_base, locked_rel, "Sell");
                                    }
                                    ImGui::EndChild();

                                    ImGui::SameLine();
                                    ImGui::BeginGroup();
                                    ImGui::Columns(2, "full_orderbook");
                                    {
                                        std::error_code ec;
                                        auto book = mm2_system_.get_current_orderbook(ec);

                                        ImGui::BeginChild("Sell_Orderbook", ImVec2(0, 0), true);
                                        gui_orderbook_table(*this, locked_base, locked_rel, "Sell", book.asks, ec);
                                        ImGui::EndChild();

                                        ImGui::NextColumn();

                                        ImGui::BeginChild("Buy_Orderbook", ImVec2(0, 0), true);
                                        gui_orderbook_table(*this, locked_base, locked_rel, "Buy", book.bids, ec);
                                        ImGui::EndChild();
                                    }
                                    ImGui::Columns(1);
                                    ImGui::EndGroup();
                                }

                                ImGui::EndTabItem();
                            }


                            if (ImGui::BeginTabItem("Orders")) {
                                auto& orders_vars = gui_vars_.orders_page;
                                auto& current_base = orders_vars.current_base;

                                if (ImGui::BeginCombo("##left", current_base.c_str()))
                                {
                                    auto coins = mm2_system_.get_enabled_coins();
                                    for (auto&& current : coins)
                                    {
                                        const bool is_selected = current.ticker == current_base;
                                        if (ImGui::Selectable(current.ticker.c_str(), is_selected)) { current_base = current.ticker; }
                                        if (is_selected) { ImGui::SetItemDefaultFocus(); }
                                    }
                                    ImGui::EndCombo();
                                }

                                if(current_base.empty()) ImGui::Text("Please select a coin to see the orders");

                                if(!current_base.empty()) {
                                    std::error_code ec;
                                    auto orders = mm2_system_.get_orders(current_base, ec);

                                    if(!orders.maker_orders.empty() || !orders.taker_orders.empty()) {
                                        if (ImGui::Button("Cancel All Orders##cancel_all_orders")) {
                                            ::mm2::api::cancel_data cd;
                                            cd.ticker = current_base;
                                            ::mm2::api::rpc_cancel_all_orders({{"Coin", cd}});
                                        }

                                        ImGui::Separator();
                                    }
                                    else {
                                        ImGui::Text("No orders.");

                                        if (ImGui::Button("Create an order##no_orders_create_an_order")) {
                                            trigger_trade_tab = true;
                                        }
                                    }
                                    // Maker
                                    if(!orders.maker_orders.empty()) {
                                        ImGui::TextColored(bright_color, "Maker Orders (%lu)", orders.maker_orders.size());
                                        gui_orders_list(*this, orders.maker_orders);

                                        if(!orders.taker_orders.empty()) ImGui::Separator();
                                    }

                                    // Trader
                                    if(!orders.taker_orders.empty()) {
                                        ImGui::TextColored(bright_color, "Taker Orders (%lu)", orders.taker_orders.size());
                                        gui_orders_list(*this, orders.taker_orders);
                                    }
                                }


                                ImGui::EndTabItem();
                            }

                            if (ImGui::BeginTabItem("History")) {
                                ImGui::Text("Work in progress");
                                ImGui::EndTabItem();
                            }

                            ImGui::EndTabBar();
                        }
                        ImGui::EndTabItem();
                    }

                    // If entered exchange,
                    if (!in_exchange_prev && in_exchange) { this->dispatcher_.trigger<gui_enter_trading>(); }
                    else if (in_exchange_prev && !in_exchange)
                    {
                        this->dispatcher_.trigger<gui_leave_trading>();
                    }
                    in_exchange_prev = in_exchange;

                    ImGui::EndTabBar();
                }
            }
        }

        ImGui::End();
    }
} // namespace atomic_dex
