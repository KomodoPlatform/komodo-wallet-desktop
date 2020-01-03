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
#include "atomic.dex.gui.hpp"
#include "atomic.dex.gui.widgets.hpp"
#include "atomic.threadpool.hpp"

//! ImGui Headers
#include <imgui_stdlib.h>

namespace fs = std::filesystem;

// General Utility
namespace
{
    void
    copy_str(const std::string& input, char* dst, size_t dst_size)
    {
        strncpy(dst, input.c_str(), dst_size - 1);
        dst[dst_size - 1] = '\0';
    }
} // namespace

// Global Constants
namespace
{
    ImVec4 value_color(128.f / 255.f, 128.f / 255.f, 128.f / 255.f, 1.f);
    ImVec4 bright_color{0, 149.f / 255.f, 143.f / 255.f, 1};
    ImVec4 dark_color{25.f / 255.f, 40.f / 255.f, 56.f / 255.f, 1};

    ImVec4 success_color(128.f / 255.f, 128.f / 255.f, 128.f / 255.f, 1.f);
    ImVec4 error_color{255.f / 255.f, 20.f / 255.f, 20.f / 255.f, 1};

    ImVec4 loss_color{1, 52.f / 255.f, 0, 1.f};
    ImVec4 gain_color{80.f / 255.f, 1, 118.f / 255.f, 1.f};

    const double input_slow_step_crypto = 0.1;
    const double input_fast_step_crypto = 1.0;
    const char*  input_format_crypto    = "%.8lf";
} // namespace

// Helpers
namespace
{
    std::string
    fiat_str(const std::string& amt, const std::string& fiat)
    {
        return amt + " " + fiat;
    }

    bool
    is_digit_or_letter(char c, bool allow_symbols = false)
    {
        bool valid = std::isdigit(c) || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');

        if (allow_symbols && (c >= '!' && c <= '@'))
            valid = true;

        return valid;
    }

    std::string
    double_to_str(const atomic_dex::t_float_50& d)
    {
        std::stringstream ss;
        ss.precision(8);
        ss << std::fixed << d;
        auto result = ss.str();
        boost::trim_right_if(result, boost::is_any_of("0"));
        boost::trim_right_if(result, boost::is_any_of("."));
        return result;
    }

    bool
    compare_double(const double& d, const std::string& str)
    {
        return str == double_to_str(d);
    }
} // namespace

// Input filters
namespace
{
    int
    input_filter_password(ImGuiInputTextCallbackData* data)
    {
        std::string str_data;
        if (data->UserData != nullptr)
        {
            str_data = static_cast<char*>(data->UserData);
        }
        auto c = data->EventChar;

        int valid = str_data.length() < 40 && is_digit_or_letter(c, true);

        return valid ? 0 : 1;
    }

    int
    input_filter_coin_address(ImGuiInputTextCallbackData* data)
    {
        std::string str_data;
        if (data->UserData != nullptr)
        {
            str_data = static_cast<char*>(data->UserData);
        }
        auto c = data->EventChar;

        int valid = str_data.length() < 40 && is_digit_or_letter(c);

        return valid ? 0 : 1;
    }
} // namespace

// GUI Draw
namespace
{
    void
    gui_enable_viewport()
    {
        ImGuiIO& io                       = ImGui::GetIO();
        io.ConfigViewportsNoAutoMerge     = true;
        io.ConfigViewportsNoDefaultParent = true;
    }

    void
    gui_disable_viewport()
    {
        ImGuiIO& io                       = ImGui::GetIO();
        io.ConfigViewportsNoAutoMerge     = false;
        io.ConfigViewportsNoDefaultParent = false;
    }

    void
    gui_disable_items(bool only_visual = false)
    {
        if (!only_visual)
            ImGui::PushItemFlag(ImGuiItemFlags_Disabled, true);
        ImGui::PushStyleVar(ImGuiStyleVar_Alpha, ImGui::GetStyle().Alpha * 0.5f);
    }

    void
    gui_enable_items(bool only_visual = false)
    {
        ImGui::PopStyleVar();
        if (!only_visual)
            ImGui::PopItemFlag();
    }

    void
    gui_coin_name_img(const atomic_dex::gui& gui, const std::string ticker, const std::string name = "", bool name_first = false)
    {
        const auto& icons = gui.get_icons();
        const auto& img   = icons.at(ticker);

        const auto text = !name.empty() ? name : ticker;
        if (name_first)
        {
            ImGui::TextWrapped("%s", text.c_str());
            ImGui::SameLine();
            ImGui::SetCursorPosX(ImGui::GetCursorPos().x + 5.f);
        }

        auto        orig_text_pos   = ImGui::GetCursorPos();
        const float custom_img_size = img.height * 0.8f;
        ImGui::SetCursorPos({ImGui::GetCursorPos().x, ImGui::GetCursorPos().y - (custom_img_size - ImGui::GetFont()->FontSize * 1.15f) * 0.5f});
        ImGui::Image(reinterpret_cast<ImTextureID>(img.id), ImVec2{custom_img_size, custom_img_size});

        if (!name_first)
        {
            auto pos_after_img = ImGui::GetCursorPos();
            ImGui::SameLine();
            ImGui::SetCursorPos(orig_text_pos);
            ImGui::SetCursorPosX(ImGui::GetCursorPos().x + custom_img_size + 5.f);
            ImGui::TextWrapped("%s", text.c_str());
            ImGui::SetCursorPos(pos_after_img);
        }
    }

    void
    gui_logs_console(const atomic_dex::gui& gui, atomic_dex::gui_variables& gui_vars)
    {
        gui_enable_viewport();

        bool active = true;
        ImGui::SetNextWindowSize(ImVec2(1000, 500), ImGuiCond_FirstUseEver);
        ImGui::Begin(gui.get_text("logs_console_title").c_str(), &active, ImGuiWindowFlags_NoCollapse);
        if (!active)
            gui_vars.console.is_open = false;

        auto logs = gui.get_console_buffer();
        ImGui::InputTextMultiline("##console_text", &logs, ImGui::GetContentRegionAvail(), ImGuiInputTextFlags_ReadOnly);

        ImGui::End();

        gui_disable_viewport();
    }

    void
    gui_coin_name_img(const atomic_dex::gui& gui, const atomic_dex::coin_config& asset)
    {
        gui_coin_name_img(gui, asset.ticker, asset.name);
    }

    void
    gui_password_input(atomic_dex::gui& gui, std::array<char, 100>& password_input, bool& show_password)
    {
        ImGuiInputTextFlags password_flags = ImGuiInputTextFlags_CallbackCharFilter;
        if (!show_password)
            password_flags |= ImGuiInputTextFlags_Password;
        ImGui::Text("%s", gui.get_text("password_input_name").c_str());
        ImGui::SetNextItemWidth(300.0f);
        ImGui::InputText(
            "##login_page_password_input", password_input.data(), password_input.size(), password_flags, input_filter_password, password_input.data());
        ImGui::SameLine();
        if (ImGui::Button((std::string(show_password ? gui.get_text("hide_password_name").c_str() : gui.get_text("show_password_name").c_str()) +
                           "##login_page_show_password_button")
                              .c_str()))
        {
            show_password = !show_password;
        }
    }

    void
    gui_login_page(entt::dispatcher& dispatcher, atomic_dex::gui& gui, atomic_dex::gui_variables& gui_vars)
    {
        auto& startup        = gui_vars.startup_page;
        auto& vars           = startup.login_page;
        auto& password_input = vars.password_input;
        auto& show_password  = vars.show_password;
        auto& error_text     = vars.error_text;

        const ImVec2 child_size{385.f, 215.f};
        ImGui::SetCursorPosX((ImGui::GetWindowSize().x - child_size.x) * 0.5f);
        ImGui::BeginChild("##login_page_child", child_size, true);
        {
            ImGui::Text("%s", gui.get_text("login_page_title").c_str());
            ImGui::Separator();
            gui_password_input(gui, password_input, show_password);
            ImGui::Separator();
            if (ImGui::Button((gui.get_text("login_page_recover_seed_button") + "##login_page_recover_seed_button").c_str()))
                startup.current_page = startup.SEED_RECOVERY;
            ImGui::SameLine();
            if (ImGui::Button((gui.get_text("login_page_login_button") + "##login_page_login_button").c_str()))
            {
                if (strcmp(password_input.data(), "") == 0)
                {
                    error_text = "Please fill the Password field!";
                }
                else
                {
                    // Derive password
                    std::error_code ec;
                    auto            key = atomic_dex::derive_password(password_input.data(), ec);
                    if (ec)
                    {
                        DLOG_F(WARNING, "{}", ec.message());
                        if (ec == dextop_error::derive_password_failed)
                        {
                            dispatcher.trigger<atomic_dex::ag::event::quit_game>(1);
                        }
                    }
                    else
                    {
                        // Decrypt seed
                        auto seed = atomic_dex::decrypt(gui_vars.wallet_data.seed_path, key.data(), ec);

                        if (ec == dextop_error::wrong_password)
                        {
                            error_text = "Wrong password!";
                        }
                        else if (ec == dextop_error::corrupted_file)
                        {
                            error_text = "Corrupted seed file, failed to decrypt!";
                        }
                        else
                        {
                            // TODO: Use the decrypted seed to login
                            vars.logged_in = true;
                        }
                    }
                }
            }
            ImGui::TextColored(error_color, "%s", error_text.c_str());
        }
        ImGui::EndChild();
    }

    void
    gui_open_login_page(atomic_dex::gui_variables& gui_vars)
    {
        gui_vars.startup_page.seed_exists = gui_vars.wallet_data.seed_exists();
        if (gui_vars.startup_page.seed_exists)
        {
            auto& startup        = gui_vars.startup_page;
            startup.current_page = startup.LOGIN;
        }
    }

    void
    gui_seed_creation(entt::dispatcher& dispatcher, atomic_dex::gui& gui, atomic_dex::gui_variables& gui_vars)
    {
        auto& startup                  = gui_vars.startup_page;
        auto& vars                     = startup.seed_creation_page;
        auto& generated_seed_read_only = vars.generated_seed_read_only;
        auto& generated_seed_confirm   = vars.generated_seed_confirm;
        auto& password_input           = vars.password_input;
        auto& show_password            = vars.show_password;
        auto& error_text               = vars.error_text;

        // TODO: Remove this placeholder
        copy_str(
            "handyman sierra quickly gluten gallstone customize subsector wobbling cheer grunt magnitude disposal usual alarm lukewarm passivism atlas amiable "
            "rounding nimbly decimeter frenzied deafness uproar radar",
            generated_seed_read_only.data(), generated_seed_read_only.size());

        const ImVec2 child_size{385.f, 390.f};
        ImGui::SetCursorPosX((ImGui::GetWindowSize().x - child_size.x) * 0.5f);
        ImGui::BeginChild("##seed_creation_child", child_size, true);
        {
            ImGui::Text("%s", gui.get_text("seed_creation_title").c_str());
            ImGui::Separator();
            ImGui::Text("%s", gui.get_text("seed_creation_warning").c_str());
            ImGui::Text("%s", gui.get_text("seed_creation_generated_seed").c_str());
            ImGui::SetNextItemWidth(300.0f);
            gui_disable_items(true);
            ImGui::InputText(
                "##generated_seed_read_only", generated_seed_read_only.data(), generated_seed_read_only.size(),
                ImGuiInputTextFlags_ReadOnly | ImGuiInputTextFlags_AutoSelectAll);
            gui_enable_items(true);
            ImGui::Text("%s", gui.get_text("seed_creation_confirm_seed").c_str());
            ImGui::SetNextItemWidth(300.0f);
            ImGui::InputText("##generated_seed_confirmation", generated_seed_confirm.data(), generated_seed_confirm.size());
            gui_password_input(gui, password_input, show_password);
            ImGui::Separator();
            if (ImGui::Button((gui.get_text("seed_creation_back_to_new_user_page_button") + "##seed_creation_back_to_new_user_page_button").c_str()))
            {
                startup.current_page = startup.NONE;
            }
            ImGui::SameLine();
            if (ImGui::Button((gui.get_text("seed_creation_confirm_button") + "##seed_creation_confirm_button").c_str()))
            {
                if (strcmp(generated_seed_confirm.data(), "") == 0)
                {
                    error_text = gui.get_text("seed_creation_confirm_seed_empty_error");
                }
                else if (strcmp(password_input.data(), "") == 0)
                {
                    error_text = gui.get_text("seed_creation_password_empty_error");
                }
                else if (generated_seed_read_only != generated_seed_confirm)
                {
                    error_text = gui.get_text("seed_creation_seeds_dont_match_error");
                }
                else
                {
                    // Derive password
                    std::error_code ec;
                    auto            key = atomic_dex::derive_password(password_input.data(), ec);
                    if (ec)
                    {
                        DLOG_F(WARNING, "{}", ec.message());
                        if (ec == dextop_error::derive_password_failed)
                        {
                            dispatcher.trigger<atomic_dex::ag::event::quit_game>(1);
                        }
                    }
                    else
                    {
                        // Encrypt seed
                        atomic_dex::encrypt(gui_vars.wallet_data.seed_path, generated_seed_read_only.data(), key.data());

                        // Open login page
                        gui_open_login_page(gui_vars);
                    }
                }
            }
            ImGui::TextColored(error_color, "%s", error_text.c_str());
        }
        ImGui::EndChild();
    }

    void
    gui_seed_recovery(entt::dispatcher& dispatcher, atomic_dex::gui& gui, atomic_dex::gui_variables& gui_vars)
    {
        auto& startup        = gui_vars.startup_page;
        auto& vars           = startup.seed_recovery_page;
        auto& seed_input     = vars.seed_input;
        auto& password_input = vars.password_input;
        auto& show_password  = vars.show_password;
        auto& error_text     = vars.error_text;

        const ImVec2 child_size{385.f, 290.f};
        ImGui::SetCursorPosX((ImGui::GetWindowSize().x - child_size.x) * 0.5f);
        ImGui::BeginChild("##seed_creation_child", child_size, true);
        {
            ImGui::Text("%s", gui.get_text("seed_recovery_title").c_str());
            ImGui::Separator();
            ImGui::Text("%s", gui.get_text("seed_recovery_seed_input_name").c_str());
            ImGui::SetNextItemWidth(300.0f);
            ImGui::InputText("##seed_recovery_seed_input", seed_input.data(), seed_input.size());
            gui_password_input(gui, password_input, show_password);
            ImGui::Separator();
            if (ImGui::Button((gui.get_text("seed_recovery_back_to_new_user_page_button") + "##seed_recovery_back_to_new_user_page_button").c_str()))
            {
                startup.current_page = startup.NONE;
            }
            ImGui::SameLine();
            if (ImGui::Button((gui.get_text("seed_recovery_confirm_button") + "##seed_recovery_confirm_button").c_str()))
            {
                if (strcmp(seed_input.data(), "") == 0)
                {
                    error_text = gui.get_text("seed_recovery_seed_empty_error");
                }
                else if (strcmp(password_input.data(), "") == 0)
                {
                    error_text = gui.get_text("seed_recovery_password_empty_error");
                }
                else
                {
                    // Derive password
                    std::error_code ec;
                    auto            key = atomic_dex::derive_password(password_input.data(), ec);
                    if (ec)
                    {
                        DLOG_F(WARNING, "{}", ec.message());
                        if (ec == dextop_error::derive_password_failed)
                        {
                            dispatcher.trigger<atomic_dex::ag::event::quit_game>(1);
                        }
                    }
                    else
                    {
                        // Encrypt seed
                        atomic_dex::encrypt(gui_vars.wallet_data.seed_path, seed_input.data(), key.data());

                        // Login page
                        gui_open_login_page(gui_vars);
                    }
                }
            }
            ImGui::TextColored(error_color, "%s", error_text.c_str());
        }
        ImGui::EndChild();
    }

    void
    gui_new_user_page(entt::dispatcher& dispatcher, atomic_dex::gui& gui, atomic_dex::gui_variables& gui_vars)
    {
        auto& startup      = gui_vars.startup_page;
        auto& current_page = startup.current_page;

        if (current_page == startup.NONE)
        {
            const ImVec2 child_size{210.f, 63.f};
            ImGui::SetCursorPosX((ImGui::GetWindowSize().x - child_size.x) * 0.5f);
            ImGui::BeginChild("##login_page_child", child_size, true);
            {
                if (ImGui::Button((gui.get_text("new_user_page_recover_seed_button") + "##new_user_page_recover_seed_button").c_str()))
                    current_page = startup.SEED_RECOVERY;
                ImGui::SameLine();
                if (ImGui::Button((gui.get_text("new_user_page_create_new_user_button") + "##new_user_page_create_new_user_button").c_str()))
                    current_page = startup.SEED_CREATION;
            }
            ImGui::EndChild();
        }
        else
        {
            if (current_page == startup.SEED_CREATION)
                gui_seed_creation(dispatcher, gui, gui_vars);
            else if (current_page == startup.SEED_RECOVERY)
                gui_seed_recovery(dispatcher, gui, gui_vars);
        }
    }

    void
    gui_startup_page(entt::dispatcher& dispatcher, atomic_dex::gui& gui, atomic_dex::gui_variables& gui_vars)
    {
        const auto& icons = gui.get_icons();
        const auto& img   = icons.at("APP_LOGO");

        const float custom_img_size = img.height * 0.8f;

        ImGui::SetCursorPos(ImVec2{(ImGui::GetWindowSize().x - custom_img_size) * 0.5f, (ImGui::GetWindowSize().y - custom_img_size) * 0.2f});
        ImGui::Image(reinterpret_cast<ImTextureID>(img.id), ImVec2{custom_img_size, custom_img_size});
        ImGui::SetCursorPosY(ImGui::GetCursorPosY() + 20.0f);

        auto& startup = gui_vars.startup_page;
        if (startup.seed_exists && startup.current_page == startup.LOGIN)
        {
            gui_login_page(dispatcher, gui, gui_vars);
        }
        else
        {
            gui_new_user_page(dispatcher, gui, gui_vars);
        }
    }

    void
    gui_settings_modal(atomic_dex::gui& gui, atomic_dex::gui_variables& gui_vars)
    {
        if (ImGui::BeginPopupModal(
                (gui.get_text("settings_modal_title") + "##settings_modal").c_str(), nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoMove))
        {
            // Languages
            auto& vars = gui_vars.settings;

            auto& curr_lang = vars.curr_lang;
            if (ImGui::BeginCombo((gui.get_text("settings_language") + "##settings_language").c_str(), curr_lang.c_str()))
            {
                for (auto&& l: vars.available_languages)
                {
                    const bool is_selected = curr_lang == l;
                    if (ImGui::Selectable(l.c_str(), is_selected))
                    {
                        curr_lang = l;
                    }
                    if (is_selected)
                    {
                        ImGui::SetItemDefaultFocus();
                    }
                }
                ImGui::EndCombo();
            }

            ImGui::Separator();

            auto& curr_fiat = vars.curr_fiat;
            if (ImGui::BeginCombo((gui.get_text("settings_fiat") + "##settings_fiat").c_str(), curr_fiat.c_str()))
            {
                for (auto&& f: vars.available_fiats)
                {
                    const bool is_selected = curr_fiat == f;
                    if (ImGui::Selectable(f.c_str(), is_selected))
                    {
                        curr_fiat = f;
                    }
                    if (is_selected)
                    {
                        ImGui::SetItemDefaultFocus();
                    }
                }
                ImGui::EndCombo();
            }

            ImGui::Separator();

            if (ImGui::Button(gui.get_text("settings_close_button").c_str()))
            {
                // TODO: Do required changes
                ImGui::CloseCurrentPopup();
            }

            ImGui::EndPopup();
        }
    }

    void
    gui_menubar([[maybe_unused]] atomic_dex::gui& gui, atomic_dex::gui_variables& gui_vars) noexcept
    {
        if (ImGui::BeginMenuBar())
        {
            if (ImGui::MenuItem(gui.get_text("menu_item_settings").c_str(), "Ctrl+G"))
            {
                ImGui::OpenPopup((gui.get_text("settings_modal_title") + "##settings_modal").c_str());
            }

            gui_settings_modal(gui, gui_vars);

            if (ImGui::MenuItem(gui.get_text("menu_item_console").c_str(), "Ctrl+K"))
            {
                gui_vars.console.is_open = true;
            }
#if defined(ENABLE_CODE_RELOAD_UNIX)
            if (ImGui::MenuItem(gui.get_text("menu_item_code_reloading").c_str(), "Ctrl+O"))
            {
                gui.reload_code();
            }
#endif
            ImGui::EndMenuBar();
        }
    }

    void
    gui_portfolio_coins_list(atomic_dex::gui& gui, atomic_dex::mm2& mm2, atomic_dex::gui_variables& gui_vars)
    {
        ImGui::BeginChild("left pane", ImVec2(180, 0), true);
        int  i               = 0;
        auto assets_contents = mm2.get_enabled_coins();
        for (auto it = assets_contents.begin(); it != assets_contents.end(); ++it, ++i)
        {
            auto& asset = *it;
            if (gui_vars.curr_asset_code.empty())
                gui_vars.curr_asset_code = asset.ticker;
            if (ImGui::Selectable(("##" + asset.name).c_str(), asset.ticker == gui_vars.curr_asset_code))
            {
                gui_vars.curr_asset_code = asset.ticker;
            }
            ImGui::SameLine();

            gui_coin_name_img(gui, asset);
        }
        ImGui::EndChild();
    }

    void
    gui_transaction_details_modal(
        atomic_dex::gui& gui, atomic_dex::coinpaprika_provider& paprika_system, bool open_modal, const atomic_dex::coin_config& curr_asset,
        const atomic_dex::tx_infos& tx, atomic_dex::gui_variables& gui_vars)
    {
        ImGui::PushID(tx.tx_hash.c_str());

        if (open_modal)
            ImGui::OpenPopup(gui.get_text("tx_details_title").c_str());

        ImGui::SetNextWindowSizeConstraints({0, 0}, {gui_vars.main_window_size.x - 50, gui_vars.main_window_size.y - 50});
        if (ImGui::BeginPopupModal(gui.get_text("tx_details_title").c_str(), nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoMove))
        {
            std::error_code ec;

            ImGui::Separator();

            ImGui::Text("%s", tx.am_i_sender ? gui.get_text("tx_details_sent").c_str() : gui.get_text("tx_details_received").c_str());
            ImGui::TextColored(
                ImVec4(tx.am_i_sender ? loss_color : gain_color), "%s%s %s", tx.am_i_sender ? "" : "+", tx.my_balance_change.c_str(),
                curr_asset.ticker.c_str());
            ImGui::SameLine(300);

            const auto& curr_fiat = gui_vars.settings.curr_fiat;
            ImGui::TextColored(value_color, "%s", fiat_str(paprika_system.get_price_in_fiat_from_tx(curr_fiat, curr_asset.ticker, tx, ec), curr_fiat).c_str());

            if (tx.timestamp != 0)
            {
                ImGui::Separator();
                ImGui::Text("%s", gui.get_text("tx_details_date").c_str());
                ImGui::TextColored(value_color, "%s", tx.date.c_str());
            }

            ImGui::Separator();
            ImGui::Text("%s", gui.get_text("tx_details_from").c_str());
            for (auto& addr: tx.from) ImGui::TextColored(value_color, "%s", addr.c_str());

            ImGui::Separator();

            ImGui::Text("%s", gui.get_text("tx_details_to").c_str());
            for (auto& addr: tx.to) ImGui::TextColored(value_color, "%s", addr.c_str());

            ImGui::Separator();

            ImGui::Text("%s", gui.get_text("tx_details_fees").c_str());
            ImGui::TextColored(value_color, "%s", tx.fees.c_str());

            ImGui::Separator();

            ImGui::Text("%s", gui.get_text("tx_details_tx_hash").c_str());
            ImGui::TextColored(value_color, "%s", tx.tx_hash.c_str());

            ImGui::Separator();

            ImGui::Text("%s", gui.get_text("tx_details_block_height").c_str());
            ImGui::TextColored(value_color, "%lu", tx.block_height);

            ImGui::Separator();

            ImGui::Text("%s", gui.get_text("tx_details_confirmations").c_str());
            ImGui::TextColored(value_color, "%lu", tx.confirmations);

            ImGui::Separator();

            if (ImGui::Button(gui.get_text("tx_details_close_button").c_str()))
                ImGui::CloseCurrentPopup();

            ImGui::SameLine();

            if (ImGui::Button(gui.get_text("tx_details_view_in_explorer").c_str()))
                antara::gaming::core::open_url_browser(curr_asset.explorer_url[0] + "tx/" + tx.tx_hash);

            ImGui::EndPopup();
        }

        ImGui::PopID();
    }

    void
    gui_portfolio_coin_details(
        atomic_dex::gui& gui, atomic_dex::mm2& mm2, atomic_dex::coinpaprika_provider& paprika_system, atomic_dex::gui_variables& gui_vars) noexcept
    {
        // Right
        const auto curr_asset = mm2.get_coin_info(gui_vars.curr_asset_code);
        if (curr_asset.ticker.empty())
        {
            return;
        }

        ImGui::BeginChild("item view", ImVec2(0, 0), true);
        {
            gui_coin_name_img(gui, curr_asset);

            ImGui::Separator();

            std::error_code ec;
            const auto& curr_fiat = gui_vars.settings.curr_fiat;
            ImGui::Text(
                std::string(std::string(reinterpret_cast<const char*>(ICON_FA_BALANCE_SCALE)) + " %s: %s %s (%s %s)").c_str(),
                gui.get_text("coin_details_balance").c_str(), mm2.my_balance(curr_asset.ticker, ec).c_str(), curr_asset.ticker.c_str(),
                paprika_system.get_price_in_fiat(curr_fiat, curr_asset.ticker, ec).c_str(), curr_fiat.c_str());
            ImGui::Separator();
            if (ImGui::BeginTabBar("##Tabs", ImGuiTabBarFlags_None))
            {
                if (ImGui::BeginTabItem(gui.get_text("coin_details_transactions_tab").c_str()))
                {
                    std::error_code error_code;
                    auto            tx_history = mm2.get_tx_history(curr_asset.ticker, error_code);
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
                                    ImVec4(tx.am_i_sender ? loss_color : gain_color), "%s%s %s", tx.am_i_sender ? "" : "+", tx.my_balance_change.c_str(),
                                    curr_asset.ticker.c_str());
                                ImGui::TextColored(value_color, "%s", tx.am_i_sender ? tx.to[0].c_str() : tx.from[0].c_str());
                                ImGui::SameLine(300);
                                const auto& curr_fiat = gui_vars.settings.curr_fiat;
                                ImGui::TextColored(
                                    value_color, "%s",
                                    fiat_str(paprika_system.get_price_in_fiat_from_tx(curr_fiat, curr_asset.ticker, tx, error_code), curr_fiat).c_str());
                            }
                            ImGui::EndGroup();
                            if (ImGui::IsItemClicked())
                            {
                                open_modal = true;
                            }

                            // Transaction Details modal
                            gui_transaction_details_modal(gui, paprika_system, open_modal, curr_asset, tx, gui_vars);

                            if (i != tx_history.size() - 1)
                                ImGui::Separator();
                        }
                    }
                    else
                        ImGui::Text("%s", gui.get_text("coin_details_transactions_page_no_transactions").c_str());

                    ImGui::EndTabItem();
                }

                if (ImGui::BeginTabItem(gui.get_text("coin_details_receive_tab").c_str()))
                {
                    auto& vars              = gui_vars.receive_page;
                    auto& address_read_only = vars.address_read_only;

                    std::error_code ec;
                    auto            addr = mm2.address(curr_asset.ticker, ec);
                    copy_str(addr, address_read_only.data(), address_read_only.size());

                    ImGui::Text("%s", gui.get_text("coin_details_receive_page_address_info_message").c_str());

                    ImGui::PushItemWidth(addr.length() * ImGui::GetFont()->FontSize * 0.5f);
                    ImGui::InputText(
                        "##receive_address", address_read_only.data(), addr.length(), ImGuiInputTextFlags_ReadOnly | ImGuiInputTextFlags_AutoSelectAll);
                    ImGui::PopItemWidth();

                    ImGui::EndTabItem();
                }

                if (ImGui::BeginTabItem(gui.get_text("coin_details_send_tab").c_str()))
                {
                    auto& vars             = gui_vars.send_coin[curr_asset.ticker];
                    auto& answer           = vars.answer;
                    auto& broadcast_answer = vars.broadcast_answer;
                    auto& address_input    = vars.address_input;
                    auto& amount_input     = vars.amount_input;

                    bool has_error = answer.rpc_result_code != 200;

                    // Transaction result
                    if (!broadcast_answer.tx_hash.empty() || !broadcast_answer.raw_result.empty())
                    {
                        has_error = broadcast_answer.rpc_result_code == -1;
                        // Failed transaction
                        if (has_error)
                        {
                            ImGui::Text("%s", gui.get_text("send_coin_tx_results_failed").c_str());

                            // TODO: Make this error text readable
                            ImGui::Separator();
                            ImGui::Text("%s", gui.get_text("send_coin_tx_results_error_code").c_str());
                            ImGui::TextColored(error_color, "%d", broadcast_answer.rpc_result_code);

                            ImGui::Separator();
                            ImGui::Text("%s", gui.get_text("send_coin_tx_results_error_details").c_str());
                            ImGui::TextColored(error_color, "%s", broadcast_answer.raw_result.c_str());
                        }
                        // Successful transaction
                        else
                        {
                            ImGui::TextColored(bright_color, "%s", gui.get_text("send_coin_tx_results_succeed").c_str());

                            ImGui::Separator();
                            ImGui::Text("%s", gui.get_text("send_coin_tx_results_tx_hash").c_str());
                            ImGui::TextColored(value_color, "%s", broadcast_answer.tx_hash.c_str());

                            ImGui::Separator();

                            if (ImGui::Button(gui.get_text("send_coin_tx_results_okay_button").c_str()))
                                vars.clear();

                            ImGui::SameLine();
                            if (ImGui::Button((gui.get_text("send_coin_tx_results_view_in_explorer") + "##tx_modal_view_transaction_button").c_str()))
                                antara::gaming::core::open_url_browser(curr_asset.explorer_url[0] + "tx/" + broadcast_answer.tx_hash);
                        }
                    }
                    // Input page
                    else if (has_error || !answer.result.has_value())
                    {
                        const float width = 35 * ImGui::GetFont()->FontSize * 0.5f;
                        ImGui::SetNextItemWidth(width);
                        ImGui::InputText(
                            (gui.get_text("send_coin_address_input") + "##send_coin_address_input").c_str(), address_input.data(), address_input.size(),
                            ImGuiInputTextFlags_CallbackCharFilter, input_filter_coin_address, address_input.data());

                        ImGui::SetNextItemWidth(width);
                        ImGui::InputDouble(
                            (gui.get_text("send_coin_amount_input") + "##send_coin_amount_input").c_str(), &amount_input, input_slow_step_crypto,
                            input_fast_step_crypto, input_format_crypto);
                        ImGui::SameLine();

                        auto balance = mm2.my_balance(curr_asset.ticker, ec);

                        if (ImGui::Button((gui.get_text("send_coin_max_amount_button") + "##send_coin_max_amount_button").c_str()))
                        {
                            amount_input = std::stod(balance);
                        }

                        if (ImGui::Button((gui.get_text("send_coin_send_button") + "##send_coin_send_button").c_str()))
                        {
                            mm2::api::withdraw_request request{curr_asset.ticker, address_input.data(), double_to_str(amount_input),
                                                               compare_double(amount_input, balance)};
                            answer = mm2::api::rpc_withdraw(std::move(request));
                        }

                        if (has_error)
                        {
                            // TODO: Make this readable
                            ImGui::TextColored(error_color, "%s", answer.raw_result.c_str());
                        }
                        else
                        {
                            ImGui::TextColored(error_color, "%s", gui.get_text("send_coin_send_button").c_str());
                        }
                    }
                    else
                    {
                        auto result = answer.result.value();

                        ImGui::Text("%s", gui.get_text("send_coin_confirmation_amount").c_str());
                        ImGui::TextColored(bright_color, "%lf", amount_input);

                        ImGui::Separator();
                        ImGui::Text("%s", gui.get_text("send_coin_confirmation_to_address").c_str());
                        for (auto& addr: result.to) ImGui::TextColored(value_color, "%s", addr.c_str());

                        ImGui::Separator();
                        ImGui::Text("%s", gui.get_text("send_coin_confirmation_fee").c_str());
                        ImGui::TextColored(value_color, "%s", result.fee_details.normal_fees.value().amount.c_str());

                        if (ImGui::Button((gui.get_text("send_coin_confirmation_cancel_button") + "##send_coin_confirmation_cancel_button").c_str()))
                            vars.clear();

                        ImGui::SameLine();

                        if (ImGui::Button((gui.get_text("send_coin_confirmation_confirm_button") + "##send_coin_confirmation_confirm_button").c_str()))
                        {
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

    void
    gui_orders_list(atomic_dex::gui& gui, atomic_dex::mm2& mm2, const std::map<std::size_t, mm2::api::my_order_contents>& orders)
    {
        for (auto it = orders.begin(); it != orders.end(); ++it)
        {
            auto& info = it->second;

            gui_coin_name_img(gui, info.base);
            ImGui::SameLine();
            ImGui::SetCursorPosX(180);
            ImGui::Text("< >");
            ImGui::SameLine();
            ImGui::SetCursorPosX(300);
            gui_coin_name_img(gui, info.rel, "", true);

            ImGui::TextColored(loss_color, "%s %s", info.available_amount.c_str(), info.base.c_str());

            ImGui::TextColored(value_color, "%s: %s", gui.get_text("orders_list_price").c_str(), info.price.c_str());
            ImGui::SameLine(250);
            ImGui::TextColored(value_color, "%s", info.human_timestamp.c_str());
            ImGui::TextColored(value_color, "%s: %s", gui.get_text("orders_list_order_id").c_str(), info.order_id.c_str());

            if (ImGui::Button((gui.get_text("orders_list_cancel_button") + "##cancel_order").c_str()))
            {
                atomic_dex::spawn([&mm2, info]() {
                    mm2::api::rpc_cancel_order({info.order_id});
                    mm2.process_orders();
                });
            }

            auto next = it;
            if (++next != orders.end())
                ImGui::Separator();
        }
    }

    void
    gui_enable_coins(atomic_dex::gui& gui, atomic_dex::mm2& mm2, atomic_dex::gui_variables& gui_vars)
    {
        if (ImGui::Button(gui.get_text("enable_coins_enable_a_coin_button").c_str()))
            ImGui::OpenPopup(gui.get_text("enable_coins_popup_name").c_str());
        if (ImGui::BeginPopupModal(gui.get_text("enable_coins_popup_name").c_str(), nullptr, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoMove))
        {
            auto enableable_coins = mm2.get_enableable_coins();
            ImGui::Text(
                "%s", enableable_coins.empty() ? gui.get_text("enable_coins_empty_list").c_str() : gui.get_text("enable_coins_select_coins_text").c_str());

            if (!enableable_coins.empty())
                ImGui::Separator();

            auto& select_list   = gui_vars.enableable_coins_select_list;
            auto& select_list_t = gui_vars.enableable_coins_select_list_tickers;
            // Extend the size of selectables list if the new list is bigger
            if (enableable_coins.size() > select_list.size())
                select_list.resize(enableable_coins.size(), false);

            // Create the list
            for (std::size_t i = 0; i < enableable_coins.size(); ++i)
            {
                auto& coin = enableable_coins[i];

                if (ImGui::Selectable((coin.name + " (" + coin.ticker + ")").c_str(), select_list[i], ImGuiSelectableFlags_DontClosePopups))
                {
                    select_list_t.emplace_back(coin.ticker);
                    select_list[i] = !select_list[i];
                }
            }

            bool close = false;
            if (enableable_coins.empty())
            {
                if (ImGui::Button(gui.get_text("enable_coins_close_button").c_str()))
                    close = true;
            }
            else
            {
                if (ImGui::Button(gui.get_text("enable_coins_enable_button").c_str(), ImVec2(120, 0)))
                {
                    // Enable selected coins
                    atomic_dex::spawn([&mm2, select_list_cpy = select_list_t]() { mm2.enable_multiple_coins(select_list_cpy); });
                    close = true;
                }

                ImGui::SameLine();

                if (ImGui::Button(gui.get_text("enable_coins_cancel_button").c_str(), ImVec2(120, 0)))
                    close = true;
            }

            if (close)
            {
                // Reset the list
                std::fill(select_list.begin(), select_list.end(), false);
                select_list_t.clear();
                ImGui::CloseCurrentPopup();
            }

            ImGui::EndPopup();
        }
    }

    void
    gui_portfolio(atomic_dex::gui& gui, atomic_dex::mm2& mm2, atomic_dex::coinpaprika_provider& paprika_system, atomic_dex::gui_variables& gui_vars)
    {
        const auto& curr_fiat = gui_vars.settings.curr_fiat;

        std::error_code ec;
        ImGui::Text(
            "%s: %s", gui.get_text("portfolio_total_balance").c_str(), fiat_str(paprika_system.get_price_in_fiat_all(curr_fiat, ec), curr_fiat).c_str());

        gui_enable_coins(gui, mm2, gui_vars);

        // Left
        gui_portfolio_coins_list(gui, mm2, gui_vars);

        // Right
        ImGui::SameLine();
        gui_portfolio_coin_details(gui, mm2, paprika_system, gui_vars);
    }

    void
    gui_amount_per_coin(const atomic_dex::gui& gui, const std::string& base, const std::string& rel)
    {
        gui_coin_name_img(gui, rel);
        ImGui::SameLine();
        ImGui::Text("%s", gui.get_text("x_amount_per_y").c_str());
        ImGui::SameLine();
        gui_coin_name_img(gui, base);
    }

    void
    gui_orderbook_table(
        const atomic_dex::gui& gui, const std::string& base, const std::string& rel, const std::string& action,
        const std::vector<mm2::api::order_contents>& list, std::error_code ec)
    {
        ImGui::Columns(2, ("orderbook_columns_" + action).c_str());

        gui_coin_name_img(gui, action == "Buy" ? rel : base);
        ImGui::SameLine();
        ImGui::Text("%s", gui.get_text("orderbook_table_x_sellers_volume_list_title").c_str());
        ImGui::NextColumn();
        gui_amount_per_coin(gui, base, rel);

        if (!list.empty())
        {
            ImGui::Separator();

            if (!ec)
            {
                for (const auto& content: list)
                {
                    ImGui::NextColumn();
                    ImGui::Text("%s", content.maxvolume.c_str());
                    ImGui::NextColumn();
                    ImGui::Text("%s", content.price.c_str());
                }
            }
            else
                DLOG_F(WARNING, "{}", ec.message());
        }

        ImGui::Columns(1);
    }

    void
    gui_buy_sell_coin(
        const atomic_dex::gui& gui, atomic_dex::mm2& mm2, atomic_dex::gui_variables& gui_vars, const std::string& base, const std::string& rel,
        const std::string& action)
    {
        auto& vars        = gui_vars.trade_page;
        auto& sell_answer = vars.sell_request_answer;
        auto& buy_answer  = vars.buy_request_answer;

        auto action_localized = action == "Buy" ? gui.get_text("buy_sell_coin_action_buy") : gui.get_text("buy_sell_coin_action_sell");
        ImGui::Text("%s", action_localized.c_str());
        ImGui::SameLine();

        gui_coin_name_img(gui, base, "", true);

        ImGui::SameLine();

        std::error_code ec;
        ImGui::Text("(%s)", mm2.my_balance(base, ec).c_str());

        auto& coin_vars    = vars.trade_sell_coin[base];
        auto& price_input  = action == "Buy" ? coin_vars.price_input_buy : coin_vars.price_input_sell;
        auto& amount_input = action == "Buy" ? coin_vars.amount_input_buy : coin_vars.amount_input_sell;
        auto& error_text   = action == "Buy" ? coin_vars.buy_error_text : coin_vars.sell_error_text;

        ImGui::SetNextItemWidth(160.0f);
        ImGui::InputDouble(
            (gui.get_text("buy_sell_coin_volume") + "##trade_sell_volume" + action).c_str(), &amount_input, input_slow_step_crypto, input_fast_step_crypto,
            input_format_crypto);

        ImGui::SetNextItemWidth(160.0f);
        ImGui::InputDouble(
            (gui.get_text("buy_sell_coin_price") + "##trade_sell_price" + action).c_str(), &price_input, input_slow_step_crypto, input_fast_step_crypto,
            input_format_crypto);

        std::string                             total;
        std::string                             current_price  = double_to_str(price_input);
        std::string                             current_amount = double_to_str(amount_input);
        boost::multiprecision::cpp_dec_float_50 current_price_f{};
        boost::multiprecision::cpp_dec_float_50 current_amount_f{};
        boost::multiprecision::cpp_dec_float_50 total_amount;
        bool                                    fields_are_filled = not current_price.empty() && not current_amount.empty();

        if (fields_are_filled)
        {
            current_price_f.assign(current_price);
            current_amount_f.assign(current_amount);
            total_amount = current_price_f * current_amount_f;
            total        = total_amount.convert_to<std::string>();
        }

        bool has_funds =
            current_amount.empty() || mm2.do_i_have_enough_funds(action == "Sell" ? base : rel, action == "Sell" ? current_amount_f : total_amount);
        bool enable = fields_are_filled && has_funds;

        if (!has_funds)
        {
            std::error_code ec;

            ImGui::TextColored(
                error_color, "%s %s %s", gui.get_text("buy_sell_coin_not_enough_funds_you_have").c_str(),
                mm2.my_balance_with_locked_funds(action == "Sell" ? base : rel, ec).c_str(), (action == "Sell" ? base : rel).c_str());
        }

        if (not enable)
        {
            gui_disable_items();
        }
        else
        {
            if (fields_are_filled)
                ImGui::TextColored(
                    bright_color, "%s %s %s", gui.get_text("buy_sell_coin_youll_receive").c_str(),
                    double_to_str(action == "Buy" ? current_amount_f : total_amount).c_str(), (action == "Sell" ? rel : base).c_str());
        }

        if (ImGui::Button((action_localized + "##buy_sell_coin_submit_button").c_str()))
        {
            atomic_dex::spawn(
                [&mm2, &sell_answer, &buy_answer, &error_text, action, base, rel, current_price, current_amount, current_amount_f, total_amount]() {
                    std::error_code ec;

                    if (action == "Sell")
                    {
                        atomic_dex::t_sell_request request{.base = base, .rel = rel, .price = current_price, .volume = current_amount};
                        sell_answer = mm2.place_sell_order(std::move(request), current_amount_f, ec);
                    }
                    else
                    {
                        atomic_dex::t_buy_request request{.base = base, .rel = rel, .price = current_price, .volume = current_amount};
                        buy_answer = mm2.place_buy_order(std::move(request), total_amount, ec);
                    }

                    mm2.process_orders();

                    if (ec)
                    {
                        LOG_F(ERROR, "{}", ec.message());
                        error_text = ec.message();
                    }
                    else
                    {
                        error_text = "";
                    }
                });
        }

        if (not enable)
            gui_enable_items();


        auto raw_result      = action == "Sell" ? sell_answer.raw_result : buy_answer.raw_result;
        auto rpc_result_code = action == "Sell" ? sell_answer.rpc_result_code : buy_answer.rpc_result_code;

        if (!error_text.empty())
        {
            ImGui::TextWrapped("%s", error_text.c_str());
        }
        else if (rpc_result_code == -1)
        {
            ImGui::Separator();
            ImGui::Text("%s", gui.get_text("buy_sell_coin_error_failed_to_sell").c_str());

            ImGui::Separator();
            ImGui::Text("%s", gui.get_text("buy_sell_coin_error_code").c_str());
            ImGui::TextColored(error_color, "%d", rpc_result_code);

            ImGui::Separator();
            ImGui::Text("%s", gui.get_text("buy_sell_coin_error_details").c_str());
            ImGui::TextColored(error_color, "%s", raw_result.c_str());
        }
        else if (not raw_result.empty())
        {
            ImGui::Separator();
            ImGui::TextColored(
                bright_color, "%s",
                action == "Buy" ? gui.get_text("buy_sell_coin_result_buy_order_placed").c_str()
                                : gui.get_text("buy_sell_coin_result_sell_order_placed").c_str());
            ImGui::TextColored(bright_color, "%s", gui.get_text("buy_sell_coin_order_complete_info").c_str());
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
        if (evt.key == ag::input::r && evt.control)
        {
            reload_code();
        }
    }

    gui::gui(entt::registry& registry, mm2& mm2_system, coinpaprika_provider& paprika_system) :
        system(registry), mm2_system_(mm2_system), paprika_system_(paprika_system)
    {
        const auto p = antara::gaming::core::assets_real_path() / "textures";
        for (auto& directory_entry: fs::directory_iterator(p))
        {
            antara::gaming::sdl::opengl_image img{};
            const auto                        res = load_image(directory_entry, img);
            if (!res)
                continue;
            icons_.insert_or_assign(boost::algorithm::to_upper_copy(directory_entry.path().stem().string()), img);
        }

        init_live_coding();
        style::apply();
        this->dispatcher_.sink<ag::event::key_pressed>().connect<&gui::on_key_pressed>(*this);

        loguru::add_callback("console_logger", log_to_console, &console_log_vars_, loguru::Verbosity_INFO);

        // Initialize the wallet
        {
            gui_vars_.startup_page.seed_exists = gui_vars_.wallet_data.seed_exists();
            if (gui_vars_.startup_page.seed_exists)
                gui_vars_.startup_page.current_page = gui_vars_.startup_page.LOGIN;
        }

        // Load languages
        load_languages();
    }

    void
    gui::log_to_console(void* user_data, const loguru::Message& message)
    {
        // Add the message
        auto vars = reinterpret_cast<console_log_vars*>(user_data);
        vars->buffer.push_back(fmt::format("{0}{1}{2}{3}", message.preamble, message.indentation, message.prefix, message.message));
        vars->str = boost::algorithm::join(vars->buffer, "\n");
    }

    void
    gui::update() noexcept
    {
        auto& gui = *this;

        update_live_coding();

        //! Menu bar
        auto& canvas = entity_registry_.ctx<ag::graphics::canvas_2d>();
        auto [x, y]  = canvas.window.size;

        ImGui::SetNextWindowSize(ImVec2(x, y), ImGuiCond_FirstUseEver);
        bool active = true;
        ImGui::Begin(gui.get_text("main_window_title").c_str(), &active, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_MenuBar);
        gui_vars_.main_window_size = ImGui::GetWindowSize();
        if (not active && mm2_system_.is_mm2_running())
        {
            this->dispatcher_.trigger<ag::event::quit_game>(0);
        }
        if (!mm2_system_.is_mm2_running())
        {
            ImGui::Text("%s", gui.get_text("first_launch_loading_text").c_str());
            const float  radius = 30.0f;
            const ImVec2 position((ImGui::GetWindowSize().x) * 0.5f - radius, (ImGui::GetWindowSize().y) * 0.5f - radius);
            ImGui::SetCursorPos(position);
            widgets::loading_indicator_circle("foo", radius, ImVec4(bright_color), ImVec4(dark_color), 9, 1.5f);
        }
        else
        {
            if (!gui_vars_.startup_page.login_page.logged_in)
            {
                gui_startup_page(dispatcher_, *this, gui_vars_);
            }
            else
            {
                gui_menubar(*this, gui_vars_);

                if (ImGui::BeginTabBar("##Tabs", ImGuiTabBarFlags_None))
                {
                    auto& vars              = gui_vars_.main_tabs_page;
                    auto& in_exchange       = vars.in_exchange;
                    auto& in_exchange_prev  = vars.in_exchange_prev;
                    auto& trigger_trade_tab = vars.trigger_trade_tab;

                    if (ImGui::BeginTabItem(gui.get_text("main_tabs_portfolio").c_str()))
                    {
                        gui_disable_viewport();
                        gui_portfolio(*this, mm2_system_, paprika_system_, gui_vars_);
                        ImGui::EndTabItem();
                    }

                    if (ImGui::BeginTabItem(gui.get_text("main_tabs_exchange").c_str()))
                    {
                        in_exchange = true;
                        if (ImGui::BeginTabBar("##ExchangeTabs", ImGuiTabBarFlags_None))
                        {
                            if (ImGui::BeginTabItem(
                                    gui.get_text("exchange_page_tabs_trade").c_str(), nullptr, trigger_trade_tab ? ImGuiTabItemFlags_SetSelected : 0))
                            {
                                trigger_trade_tab = false;

                                auto& vars         = gui_vars_.trade_page;
                                auto& current_base = vars.current_base;
                                auto& current_rel  = vars.current_rel;
                                auto& locked_base  = vars.locked_base;
                                auto& locked_rel   = vars.locked_rel;

                                const float remaining_width = ImGui::GetContentRegionAvail().x - ImGui::GetStyle().ItemSpacing.x;

                                ImGui::Text("%s", gui.get_text("exchange_page_trade_tab_select_pairs_info").c_str());

                                ImGui::SetNextItemWidth(remaining_width / 6);
                                if (ImGui::BeginCombo("##left", current_base.c_str()))
                                {
                                    auto coins = mm2_system_.get_enabled_coins();
                                    for (auto&& current: coins)
                                    {
                                        if (current.ticker == current_rel)
                                            continue;
                                        const bool is_selected = current.ticker == current_base;
                                        if (ImGui::Selectable(current.ticker.c_str(), is_selected))
                                        {
                                            current_base = current.ticker;
                                        }
                                        if (is_selected)
                                        {
                                            ImGui::SetItemDefaultFocus();
                                        }
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
                                        if (current.ticker == current_base)
                                            continue;
                                        const bool is_selected = current.ticker == current_rel;
                                        if (ImGui::Selectable(current.ticker.c_str(), is_selected))
                                        {
                                            current_rel = current.ticker;
                                        }
                                        if (is_selected)
                                        {
                                            ImGui::SetItemDefaultFocus();
                                        }
                                    }

                                    ImGui::EndCombo();
                                }
                                ImGui::SameLine();

                                bool coins_are_selected = not current_base.empty() && not current_rel.empty();

                                if (!coins_are_selected)
                                    gui_disable_items();

                                bool load_orderbook = false;
                                if (ImGui::Button(gui.get_text("exchange_page_trade_tab_load_button").c_str()) && not current_base.empty() &&
                                    not current_rel.empty())
                                {
                                    load_orderbook = true;
                                }

                                ImGui::SameLine();
                                if (ImGui::Button(gui.get_text("exchange_page_trade_tab_swap_button").c_str()) && not current_base.empty() &&
                                    not current_rel.empty())
                                {
                                    auto tmp       = current_base;
                                    current_base   = current_rel;
                                    current_rel    = tmp;
                                    load_orderbook = true;
                                }

                                if (!coins_are_selected)
                                    gui_enable_items();

                                if (load_orderbook)
                                {
                                    locked_base = current_base;
                                    locked_rel  = current_rel;
                                    this->dispatcher_.trigger<orderbook_refresh>(current_base, current_rel);
                                }

                                if (not locked_base.empty() && not locked_rel.empty())
                                {
                                    ImGui::BeginChild("Sell_Window", ImVec2(275, 0), true);
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
                                        auto            book = mm2_system_.get_current_orderbook(ec);

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


                            if (ImGui::BeginTabItem(gui.get_text("exchange_page_tabs_orders").c_str()))
                            {
                                auto& orders_vars  = gui_vars_.orders_page;
                                auto& current_base = orders_vars.current_base;

                                if (ImGui::BeginCombo("##left", current_base.c_str()))
                                {
                                    auto coins = mm2_system_.get_enabled_coins();
                                    for (auto&& current: coins)
                                    {
                                        const bool is_selected = current.ticker == current_base;
                                        if (ImGui::Selectable(current.ticker.c_str(), is_selected))
                                        {
                                            current_base = current.ticker;
                                        }
                                        if (is_selected)
                                        {
                                            ImGui::SetItemDefaultFocus();
                                        }
                                    }
                                    ImGui::EndCombo();
                                }

                                if (current_base.empty())
                                    ImGui::Text("%s", gui.get_text("exchange_page_trade_tab_select_a_coin").c_str());

                                if (!current_base.empty())
                                {
                                    std::error_code ec;

                                    auto orders = mm2_system_.get_orders(current_base, ec);

                                    if (!orders.maker_orders.empty() || !orders.taker_orders.empty())
                                    {
                                        if (ImGui::Button((gui.get_text("exchange_page_trade_tab_cancel_all_orders_button") + "##cancel_all_orders").c_str()))
                                        {
                                            atomic_dex::spawn([this, current_base]() {
                                                ::mm2::api::cancel_data cd;
                                                cd.ticker = current_base;
                                                ::mm2::api::rpc_cancel_all_orders({{"Coin", cd}});
                                                mm2_system_.process_orders();
                                            });
                                        }

                                        ImGui::Separator();
                                    }
                                    else
                                    {
                                        ImGui::Text("%s", gui.get_text("exchange_page_trade_tab_no_orders_text").c_str());

                                        if (ImGui::Button(
                                                (gui.get_text("exchange_page_trade_tab_create_an_order_button") + "##no_orders_create_an_order").c_str()))
                                        {
                                            trigger_trade_tab = true;
                                        }
                                    }
                                    // Maker
                                    if (!orders.maker_orders.empty())
                                    {
                                        ImGui::TextColored(
                                            bright_color, "%s (%lu)", gui.get_text("exchange_page_trade_tab_maker_orders").c_str(), orders.maker_orders.size());
                                        gui_orders_list(*this, mm2_system_, orders.maker_orders);

                                        if (!orders.taker_orders.empty())
                                            ImGui::Separator();
                                    }

                                    // Trader
                                    if (!orders.taker_orders.empty())
                                    {
                                        ImGui::TextColored(
                                            bright_color, "%s (%lu)", gui.get_text("exchange_page_trade_tab_taker_orders").c_str(), orders.taker_orders.size());
                                        gui_orders_list(*this, mm2_system_, orders.taker_orders);
                                    }
                                }


                                ImGui::EndTabItem();
                            }

                            if (ImGui::BeginTabItem(gui.get_text("exchange_page_tabs_history").c_str()))
                            {
                                ImGui::Text("%s", gui.get_text("work_in_progress").c_str());
                                ImGui::EndTabItem();
                            }

                            ImGui::EndTabBar();
                        }
                        ImGui::EndTabItem();
                    }

                    // If entered exchange,
                    if (!in_exchange_prev && in_exchange)
                    {
                        this->dispatcher_.trigger<gui_enter_trading>();
                    }
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


        if (gui_vars_.console.is_open)
            gui_logs_console(*this, gui_vars_);
    }
} // namespace atomic_dex
