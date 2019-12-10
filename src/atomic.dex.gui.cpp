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

#include <filesystem>
#include <imgui.h>
#include <antara/gaming/graphics/component.canvas.hpp>
#include <antara/gaming/event/quit.game.hpp>
#include <antara/gaming/event/key.pressed.hpp>
#include <IconsFontAwesome5.h>
#include "atomic.dex.gui.hpp"
#include "atomic.dex.gui.widgets.hpp"
#include "atomic.dex.mm2.hpp"

namespace fs = std::filesystem;
// Helpers
namespace {
    ImVec4 bright_color{0, 149.f / 255.f, 143.f / 255.f, 1};
    ImVec4 dark_color{25.f / 255.f, 40.f / 255.f, 56.f / 255.f, 1};

    std::string usd_str(const std::string &amt) {
        return amt + " USD";
    }
}

// GUI Draw
namespace {
    void gui_menubar() noexcept {
        if (ImGui::BeginMenuBar()) {
            if (ImGui::MenuItem("Open", "Ctrl+O")) { /* Do stuff */ }
            if (ImGui::MenuItem("Settings", "Ctrl+O")) { /* Do stuff */ }
            ImGui::EndMenuBar();
        }
    }

    void gui_portfolio_coins_list(atomic_dex::mm2 &mm2, atomic_dex::gui_variables& gui_vars) noexcept {
        ImGui::BeginChild("left pane", ImVec2(180, 0), true);
        int i = 0;
        auto assets_contents = mm2.get_enabled_coins();
        for (auto it = assets_contents.begin(); it != assets_contents.end(); ++it, ++i) {
            auto &asset = *it;
            if (gui_vars.curr_asset_code == "") gui_vars.curr_asset_code = asset.ticker;
//            ImGui::Image(icons.at(asset.ticker));
            //ImGui::SameLine();
            if (ImGui::Selectable(asset.name.c_str(), asset.ticker == gui_vars.curr_asset_code)) {
                gui_vars.curr_asset_code = asset.ticker;
            }
        }
        ImGui::EndChild();
    }

    void gui_transaction_details_modal(bool open_modal) {
        if(open_modal) ImGui::OpenPopup("Transaction Details");

        if (ImGui::BeginPopupModal("Transaction Details", NULL, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoMove)) {
            if(ImGui::Button("Cancel", ImVec2(120, 0))) {
                ImGui::CloseCurrentPopup();
            }

            ImGui::EndPopup();
        }
    }

    void gui_portfolio_coin_details(atomic_dex::mm2 &mm2, atomic_dex::coinpaprika_provider &paprika_system, atomic_dex::gui_variables& gui_vars) noexcept {
        // Right
        const auto curr_asset = mm2.get_coin_info(gui_vars.curr_asset_code);
        ImGui::BeginChild("item view", ImVec2(0, 0), true);
        {
            ImGui::TextWrapped("%s", curr_asset.name.c_str());
            ImGui::Separator();
            std::error_code ec;

            ImGui::Text(std::string(std::string(ICON_FA_BALANCE_SCALE) + " Balance: %s %s (%s USD)").c_str(),
                        mm2.my_balance(curr_asset.ticker, ec).c_str(),
                        curr_asset.ticker.c_str(),
                        paprika_system.get_price_in_fiat("USD", curr_asset.ticker, ec).c_str());
            ImGui::Separator();
            if (ImGui::BeginTabBar("##Tabs", ImGuiTabBarFlags_None)) {
                if (ImGui::BeginTabItem("Transactions")) {
                    std::error_code ec;
                    auto tx_history = mm2.get_tx_history(curr_asset.ticker, ec);
                    if (tx_history.size() > 0) {
                        for (std::size_t i = 0; i < tx_history.size(); ++i) {
                            bool open_modal = false;
                            ImGui::BeginChild("tx details");
                            {
                                auto &tx = tx_history[i];
                                ImGui::Text("%s", tx.am_i_sender ? "Sent" : "Received");
                                ImGui::SameLine(300);
                                ImGui::TextColored(
                                        ImVec4(tx.am_i_sender ? ImVec4(1, 52.f / 255.f, 0, 1.f) : ImVec4(80.f / 255.f, 1,
                                                                                                         118.f / 255.f,
                                                                                                         1.f)),
                                        "%s%s %s", tx.am_i_sender ? "-" : "+", tx.my_balance_change.c_str(),
                                        curr_asset.ticker.c_str());
                                ImGui::TextColored(ImVec4(128.f / 255.f, 128.f / 255.f, 128.f / 255.f, 1.f), "%s",
                                                   tx.am_i_sender ? tx.to[0].c_str() : tx.from[0].c_str());
                                ImGui::SameLine(300);
                                ImGui::TextColored(ImVec4(128.f / 255.f, 128.f / 255.f, 128.f / 255.f, 1.f), "%s",
                                                   usd_str(paprika_system.get_price_in_fiat_from_tx("USD",
                                                                                                    curr_asset.ticker, tx,
                                                                                                    ec)).c_str());
                            }
                            ImGui::EndChild();
                            if(ImGui::IsItemClicked()) {
                                open_modal = true;
                            }

                            // Transaction Details modal
                            gui_transaction_details_modal(open_modal);

                            if (i != tx_history.size() - 1) ImGui::Separator();
                        }
                    } else ImGui::Text("No transactions");

                    ImGui::EndTabItem();
                }

                if (ImGui::BeginTabItem("Receive")) {
                    ImGui::Text("Work in progress, will receive coins here");
                    ImGui::EndTabItem();
                }

                if (ImGui::BeginTabItem("Send")) {
                    ImGui::Text("Work in progress, will send coins here");
                    if (ImGui::Button("Send")) {

                    }
                    ImGui::EndTabItem();
                }

                ImGui::EndTabBar();
            }
        }
        ImGui::EndChild();
    }

    void gui_enable_coins(atomic_dex::mm2 &mm2, atomic_dex::gui_variables& gui_vars) {
        if (ImGui::Button("Enable a coin"))
            ImGui::OpenPopup("Enable coins");
        if (ImGui::BeginPopupModal("Enable coins", NULL, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoMove )) {
            auto enableable_coins = mm2.get_enableable_coins();
            ImGui::Text(enableable_coins.empty() ? "All coins are already enabled!" : "Select the coins you want to add to your portfolio.");

            if(!enableable_coins.empty()) ImGui::Separator();

            auto& select_list = gui_vars.enableable_coins_select_list;
            // Extend the size of selectables list if the new list is bigger
            if(enableable_coins.size() > select_list.size())
                select_list.resize(enableable_coins.size(), false);

            // Create the list
            for(std::size_t i = 0; i < enableable_coins.size(); ++i) {
                auto& coin = enableable_coins[i];

                if(ImGui::Selectable((coin.name + " (" + coin.ticker + ")").c_str(), select_list[i], ImGuiSelectableFlags_DontClosePopups))
                    select_list[i] = !select_list[i];
            }

            bool close = false;
            if(enableable_coins.empty()) {
                if(ImGui::Button("Okay")) close = true;
            }
            else {
                if (ImGui::Button("Enable", ImVec2(120, 0))) {
                    // Enable selected coins
                    for(std::size_t i = 0; i < enableable_coins.size(); ++i) {
                        if(select_list[i])
                            mm2.enable_coin(enableable_coins[i].ticker);
                    }
                    close = true;
                }

                ImGui::SameLine();

                if(ImGui::Button("Cancel", ImVec2(120, 0))) close = true;
            }

            if(close) {
                // Reset the list
                std::fill(select_list.begin(), select_list.end(), false);
                ImGui::CloseCurrentPopup();
            }

            ImGui::EndPopup();
        }
    }

    void gui_portfolio(atomic_dex::mm2 &mm2, atomic_dex::coinpaprika_provider &paprika_system, atomic_dex::gui_variables& gui_vars) noexcept {
        std::error_code ec;
        ImGui::Text("Total Balance: %s", usd_str(paprika_system.get_price_in_fiat_all("USD", ec)).c_str());

        gui_enable_coins(mm2, gui_vars);

        // Left
        gui_portfolio_coins_list(mm2, gui_vars);

        // Right
        ImGui::SameLine();
        gui_portfolio_coin_details(mm2, paprika_system, gui_vars);
    }
}

namespace atomic_dex {
#if defined(ENABLE_CODE_RELOAD_UNIX)
    //! Platform dependent code
    class AtomicDexHotCodeListener : public jet::ILiveListener
    {
    public:
        void onLog(jet::LogSeverity severity, const std::string &message) override
        {
            std::string severityString;
            auto verbosity = loguru::Verbosity_INFO;
            switch (severity) {
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

    void gui::reload_code() {
        DVLOG_F(loguru::Verbosity_INFO, "reloading code");
#if defined(ENABLE_CODE_RELOAD_UNIX)
        live_->tryReload();
#endif
    }

    void gui::init_live_coding() {
#if defined(ENABLE_CODE_RELOAD_UNIX)
        live_ = jet::make_unique<jet::Live>(jet::make_unique<AtomicDexHotCodeListener>());
        while (!live_->isInitialized()) {
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
            live_->update();
        }
        live_->update();
#endif
    }

    void gui::update_live_coding() {
#if defined(ENABLE_CODE_RELOAD_UNIX)
        live_->update();
#endif
    }
}

namespace atomic_dex {
    void gui::on_key_pressed(const ag::event::key_pressed &evt) noexcept {
        if (evt.key == ag::input::r && evt.control) {
            reload_code();
        }
    }

    gui::gui(entt::registry &registry, atomic_dex::mm2 &mm2_system,
             atomic_dex::coinpaprika_provider &paprika_system) noexcept : system(registry),
                                                                          mm2_system_(mm2_system),
                                                                          paprika_system_(paprika_system) {
        init_live_coding();
        atomic_dex::style::apply();
        this->dispatcher_.sink<ag::event::key_pressed>().connect<&gui::on_key_pressed>(*this);


    }

    void gui::update() noexcept {
        update_live_coding();

        //! Menu bar
        auto &canvas = entity_registry_.ctx<ag::graphics::canvas_2d>();
        auto[x, y] = canvas.window.size;

        ImGui::SetNextWindowSize(ImVec2(x, y), ImGuiCond_Once);
        bool active = true;
        ImGui::Begin("atomicDEX", &active, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_MenuBar | ImGuiWindowFlags_NoResize);
        if (not active && mm2_system_.is_mm2_running()) { this->dispatcher_.trigger<ag::event::quit_game>(0); }
        ImGuiIO &io = ImGui::GetIO();
        io.ConfigViewportsNoAutoMerge = false;
        io.ConfigViewportsNoDefaultParent = false;
        if (!mm2_system_.is_mm2_running()) {
            ImGui::Text("Loading, please wait...");
            const float radius = 30.0f;
            ImVec2 position((ImGui::GetWindowSize().x) * 0.5f - radius,
                            (ImGui::GetWindowSize().y) * 0.5f - radius);
            ImGui::SetCursorPos(position);
            atomic_dex::widgets::LoadingIndicatorCircle("foo", radius, ImVec4(bright_color), ImVec4(dark_color), 9,
                                                        1.5f);
        } else {
            gui_menubar();

            if (ImGui::BeginTabBar("##Tabs", ImGuiTabBarFlags_None)) {
                static bool in_trade_prev = false;
                bool in_trade = false;

                if (ImGui::BeginTabItem("Portfolio")) {
                    gui_portfolio(mm2_system_, paprika_system_, gui_vars_);
                    ImGui::EndTabItem();
                }
                if (ImGui::BeginTabItem("Trade")) {
                    in_trade = true;

                    ImGui::Text("Work in progress");
                    ImGui::EndTabItem();
                }

                // If entered trade,
                if(!in_trade_prev && in_trade) {
                    this->dispatcher_.trigger<atomic_dex::gui_enter_trading>();
                }
                else if(in_trade_prev && !in_trade){
                    this->dispatcher_.trigger<atomic_dex::gui_leave_trading>();
                }
                in_trade_prev = in_trade;

                ImGui::EndTabBar();
            }
        }

        ImGui::End();
    }
}
