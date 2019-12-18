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
    ImVec4 success_color(128.f / 255.f, 128.f / 255.f, 128.f / 255.f, 1.f);
    ImVec4 value_color(128.f / 255.f, 128.f / 255.f, 128.f / 255.f, 1.f);
    ImVec4 bright_color{0, 149.f / 255.f, 143.f / 255.f, 1};
    ImVec4 dark_color{25.f / 255.f, 40.f / 255.f, 56.f / 255.f, 1};
    ImVec4 error_color{255.f / 255.f, 20.f / 255.f, 20.f / 255.f, 1};

    std::string
    usd_str(const std::string& amt)
    {
        return amt + " USD";
    }
} // namespace

// Input filters
namespace
{
    auto crypto_amount_filter = [](ImGuiInputTextCallbackData* data) {
      std::string str_data = "";
      if (data->UserData != nullptr) { str_data = static_cast<char*>(data->UserData); }
      auto c = data->EventChar;
      auto n = std::count(begin(str_data), end(str_data), '.');
      if (n == 1 && c == '.') { return 1; }
      int valid = !(std::isdigit(c) || c == '.');

      return valid;
    };

    auto crypto_address_filter = [](ImGuiInputTextCallbackData* data) {
      std::string str_data = "";
      if (data->UserData != nullptr) { str_data = static_cast<char*>(data->UserData); }
      auto c = data->EventChar;

      int valid = str_data.length() < 40 &&
          ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z'));

      return valid ? 0 : 1;
    };
}

// GUI Draw
namespace
{
    void
    gui_coin_name_img(const atomic_dex::gui& gui, const atomic_dex::coin_config& asset)
    {
        const auto& icons = gui.get_icons();
        const auto& img = icons.at(asset.ticker);

        auto orig_text_pos = ImGui::GetCursorPos();
        const float custom_img_size = img.height * 0.8f;
        ImGui::SetCursorPos({ImGui::GetCursorPos().x, ImGui::GetCursorPos().y - (custom_img_size - ImGui::GetFont()->FontSize * 1.15f) * 0.5f});
        ImGui::Image(reinterpret_cast<void*>(static_cast<intptr_t>(img.id)), ImVec2{custom_img_size, custom_img_size});
        auto pos_after_img = ImGui::GetCursorPos();
        ImGui::SameLine();
        ImGui::SetCursorPos(orig_text_pos);
        ImGui::SetCursorPosX(ImGui::GetCursorPos().x + custom_img_size + 5.f);
        ImGui::TextWrapped("%s", asset.name.c_str());
        ImGui::SetCursorPos(pos_after_img);
    }

    void
    gui_menubar([[maybe_unused]] atomic_dex::gui& system) noexcept
    {
        if (ImGui::BeginMenuBar())
        {
            if (ImGui::MenuItem("Open", "Ctrl+O"))
            { /* Do stuff */
            }
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
        int  i               = 0;
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
    gui_transaction_details_modal(
        atomic_dex::coinpaprika_provider& paprika_system, bool open_modal, const atomic_dex::coin_config& curr_asset, const atomic_dex::tx_infos& tx,
        atomic_dex::gui_variables& gui_vars)
    {
        ImGui::PushID(tx.tx_hash.c_str());

        if (open_modal) ImGui::OpenPopup("Transaction Details");

        bool open = true;

        ImGui::SetNextWindowSizeConstraints({0, 0}, {gui_vars.main_window_size.x - 50, gui_vars.main_window_size.y - 50});
        if (ImGui::BeginPopupModal("Transaction Details", &open, ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoMove))
        {
            std::error_code ec;

            ImGui::Separator();

            ImGui::Text("%s", tx.am_i_sender ? "Sent" : "Received");
            ImGui::TextColored(
                ImVec4(tx.am_i_sender ? ImVec4(1, 52.f / 255.f, 0, 1.f) : ImVec4(80.f / 255.f, 1, 118.f / 255.f, 1.f)), "%s%s %s", tx.am_i_sender ? "" : "+",
                tx.my_balance_change.c_str(), curr_asset.ticker.c_str());
            ImGui::SameLine(300);
            ImGui::TextColored(value_color, "%s", usd_str(paprika_system.get_price_in_fiat_from_tx("USD", curr_asset.ticker, tx, ec)).c_str());

            ImGui::Separator();

            ImGui::Text("Date");
            ImGui::TextColored(value_color, "%s", tx.date.c_str());

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

            ImGui::Text(
                std::string(std::string(reinterpret_cast<const char*>(ICON_FA_BALANCE_SCALE)) + " Balance: %s %s (%s USD)").c_str(),
                mm2.my_balance(curr_asset.ticker, ec).c_str(), curr_asset.ticker.c_str(),
                paprika_system.get_price_in_fiat("USD", curr_asset.ticker, ec).c_str());
            ImGui::Separator();
            if (ImGui::BeginTabBar("##Tabs", ImGuiTabBarFlags_None))
            {
                if (ImGui::BeginTabItem("Transactions"))
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
                                ImGui::Text("%s", tx.date.c_str());
                                ImGui::SameLine(300);
                                ImGui::TextColored(
                                    ImVec4(tx.am_i_sender ? ImVec4(1, 52.f / 255.f, 0, 1.f) : ImVec4(80.f / 255.f, 1, 118.f / 255.f, 1.f)), "%s%s %s",
                                    tx.am_i_sender ? "" : "+", tx.my_balance_change.c_str(), curr_asset.ticker.c_str());
                                ImGui::TextColored(value_color, "%s", tx.am_i_sender ? tx.to[0].c_str() : tx.from[0].c_str());
                                ImGui::SameLine(300);
                                ImGui::TextColored(
                                    value_color, "%s", usd_str(paprika_system.get_price_in_fiat_from_tx("USD", curr_asset.ticker, tx, error_code)).c_str());
                            }
                            ImGui::EndGroup();
                            if (ImGui::IsItemClicked()) { open_modal = true; }

                            // Transaction Details modal
                            gui_transaction_details_modal(paprika_system, open_modal, curr_asset, tx, gui_vars);

                            if (i != tx_history.size() - 1) ImGui::Separator();
                        }
                    }
                    else
                        ImGui::Text("No transactions");

                    ImGui::EndTabItem();
                }

                if (ImGui::BeginTabItem("Receive"))
                {
                    static char address_read_only[100];

                    std::error_code ec;
                    auto addr = mm2.address(curr_asset.ticker, ec);
                    copy_str(addr, address_read_only, 100);

                    ImGui::Text("Share the address below to receive coins");

                    ImGui::PushItemWidth(addr.length() * ImGui::GetFont()->FontSize * 0.5f);
                    ImGui::InputText("##receive_address", address_read_only, addr.length(), ImGuiInputTextFlags_ReadOnly | ImGuiInputTextFlags_AutoSelectAll);
                    ImGui::PopItemWidth();

                    ImGui::EndTabItem();
                }

                if (ImGui::BeginTabItem("Send"))
                {
                    auto& vars = gui_vars.send_coin[curr_asset.ticker];
                    auto& answer = vars.answer;
                    auto& address_input = vars.address_input;
                    auto& amount_input = vars.amount_input;

                    bool has_error = answer.rpc_result_code != 200;
                    if(has_error || !answer.result.has_value()) {
                        ImGui::PushID("Amount");
                        ImGui::InputText("Amount", amount_input.data(), amount_input.size(), ImGuiInputTextFlags_CallbackCharFilter, crypto_amount_filter, amount_input.data());
                        ImGui::PopID();
                        ImGui::SameLine();
                        ImGui::PushID("MAX");

                        auto balance = mm2.my_balance(curr_asset.ticker, ec);

                        if (ImGui::Button("MAX")) {
                            copy_str(balance, amount_input.data(), amount_input.size());
                        }
                        ImGui::PopID();

                        ImGui::PushID("Address");
                        ImGui::InputText("Address", address_input.data(), address_input.size(), ImGuiInputTextFlags_CallbackCharFilter, crypto_address_filter, address_input.data());
                        ImGui::PopID();

                        ImGui::PushID("Send");
                        if (ImGui::Button("Send")) {
                            mm2::api::withdraw_request request{curr_asset.ticker, address_input.data(), amount_input.data(), strcmp(amount_input.data(), balance.c_str()) == 0};
                            answer = mm2::api::rpc_withdraw(std::move(request));
                        }
                        ImGui::PopID();

                        if(answer.result.has_value()) {
                            ImGui::TextColored(error_color, "Will send %s", answer.result.value().total_amount.c_str());
                        }
                        else {
                            ImGui::TextColored(error_color, "No result");
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
                        ImGui::TextColored(bright_color, "%s", result.total_amount.c_str());

                        ImGui::Separator();
                        ImGui::Text("To address");
                        for (auto& addr: result.to) ImGui::TextColored(value_color, "%s", addr.c_str());

                        ImGui::Separator();
                        ImGui::Text("Fee");
                        ImGui::TextColored(value_color, "%s", result.fee_details.normal_fees.value().amount.c_str());


                        ImGui::PushID("Cancel");
                        if (ImGui::Button("Cancel")) {
                            answer = {};
                        }
                        ImGui::PopID();

                        ImGui::PushID("Confirm");
                        if (ImGui::Button("Confirm")) {
                            // TODO: Broadcast withdraw
                        }
                        ImGui::PopID();
                    }

                    ImGui::EndTabItem();
                }

                ImGui::EndTabBar();
            }
        }
        ImGui::EndChild();
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
            gui_menubar(*this);

            if (ImGui::BeginTabBar("##Tabs", ImGuiTabBarFlags_None))
            {
                static bool in_trade_prev = false;
                bool        in_trade      = false;

                if (ImGui::BeginTabItem("Portfolio"))
                {
                    ImGuiIO& io                       = ImGui::GetIO();
                    io.ConfigViewportsNoAutoMerge     = false;
                    io.ConfigViewportsNoDefaultParent = false;
                    gui_portfolio(*this, mm2_system_, paprika_system_, gui_vars_);
                    ImGui::EndTabItem();
                }
                if (ImGui::BeginTabItem("Trade"))
                {
                    in_trade = true;

                    // ImGui::Text("Work in progress");

                    //! TODO: REMOVE THIS TMP !!!! (for testing trading part)
                    static std::string current_base = "";
                    static std::string current_rel  = "";
                    static std::string locked_base  = "";
                    static std::string locked_rel   = "";

                    const float remaining_width = ImGui::GetContentRegionAvail().x - ImGui::GetStyle().ItemSpacing.x;

                    ImGui::Text("Choose Base coin");
                    ImGui::SameLine();
                    ImGui::SetCursorPosX(ImGui::GetCursorPosX() + remaining_width / 6);
                    ImGui::Text("Choose Rel coin");
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
                    if (ImGui::Button("Load") && not current_base.empty() && not current_rel.empty())
                    {
                        locked_base = current_base;
                        locked_rel  = current_rel;
                        this->dispatcher_.trigger<orderbook_refresh>(current_base, current_rel);
                    }

                    if (not locked_base.empty() && not locked_rel.empty())
                    {
                        ImGui::BeginChild(
                            "Orderbook Window", ImVec2(0, 400), true, ImGuiWindowFlags_AlwaysVerticalScrollbar | ImGuiWindowFlags_AlwaysHorizontalScrollbar);
                        {
                            ImGui::Text("Ask Orderbook:");
                            ImGui::Columns(4, "orderbook_columns_asks");
                            ImGui::Separator();
                            ImGui::Text("Buy Coin");
                            ImGui::NextColumn();
                            ImGui::Text("Sell Coin");
                            ImGui::NextColumn();
                            ImGui::Text("%s", (locked_base + " Volume").c_str());
                            ImGui::NextColumn();
                            ImGui::Text("%s", (locked_rel + " price per " + locked_base).c_str());
                            ImGui::NextColumn();
                            ImGui::Separator();

                            std::error_code ec;
                            auto            book = mm2_system_.get_current_orderbook(ec);
                            if (!ec)
                            {
                                // auto rng = ranges::views::concat(book.asks, book.bids);
                                for (const ::mm2::api::order_contents& content: book.asks)
                                {
                                    ImGui::Text("%s", locked_base.c_str());
                                    ImGui::NextColumn();
                                    ImGui::Text("%s", locked_rel.c_str());
                                    ImGui::NextColumn();
                                    ImGui::Text("%s", content.maxvolume.c_str());
                                    ImGui::NextColumn();
                                    ImGui::Text("%s", content.price.c_str());
                                    ImGui::NextColumn();
                                }
                            }
                            else
                            {
                                DLOG_F(WARNING, "{}", ec.message());
                            }

                            ImGui::Columns(1);
                            ImGui::NewLine();
                            ImGui::Text("Bids Orderbook:");
                            ImGui::Columns(4, "orderbook_columns_bids");
                            ImGui::Separator();
                            ImGui::Text("Buy Coin");
                            ImGui::NextColumn();
                            ImGui::Text("Sell Coin");
                            ImGui::NextColumn();
                            ImGui::Text("%s", (locked_rel + " Volume").c_str());
                            ImGui::NextColumn();
                            ImGui::Text("%s", (locked_rel + " price per " + locked_base).c_str());
                            ImGui::NextColumn();
                            ImGui::Separator();

                            if (!ec)
                            {
                                for (const ::mm2::api::order_contents& content: book.bids)
                                {
                                    ImGui::Text("%s", locked_rel.c_str());
                                    ImGui::NextColumn();
                                    ImGui::Text("%s", locked_base.c_str());
                                    ImGui::NextColumn();
                                    ImGui::Text("%s", content.maxvolume.c_str());
                                    ImGui::NextColumn();
                                    ImGui::Text("%s", content.price.c_str());
                                    ImGui::NextColumn();
                                }
                            }
                            else
                            {
                                DLOG_F(WARNING, "{}", ec.message());
                            }


                            ImGui::Columns(1);
                        }
                        ImGui::EndChild();


                        ImGui::BeginChild("Buy/Sell Window", ImVec2(500, 500), true);
                        {
                            ImGui::Text("Buy %s", locked_base.c_str());

                            ImGui::Text("Price: ");
                            ImGui::SameLine();
                            ImGui::SetNextItemWidth(200.f);

                            static char price_buf[20];
                            ImGui::InputText("##price", price_buf, IM_ARRAYSIZE(price_buf), ImGuiInputTextFlags_CallbackCharFilter, crypto_amount_filter, price_buf);

                            ImGui::Text("Amount: ");
                            ImGui::SameLine();
                            ImGui::SetNextItemWidth(200.f);
                            static char amount_buf[20];
                            ImGui::InputText("##amount", amount_buf, IM_ARRAYSIZE(amount_buf), ImGuiInputTextFlags_CallbackCharFilter, crypto_amount_filter, amount_buf);
                            ImGui::Text("Total: ");
                            std::string total          = "";
                            std::string current_price  = price_buf;
                            std::string current_amount = amount_buf;
                            t_float_50  total_balance;
                            if (not current_price.empty() && not current_amount.empty())
                            {
                                boost::multiprecision::cpp_dec_float_50 current_price_f(current_price);
                                boost::multiprecision::cpp_dec_float_50 current_amount_f(current_amount);
                                total_balance = current_price_f * current_amount_f;
                                total         = total_balance.convert_to<std::string>();
                            }
                            ImGui::SameLine();
                            ImGui::InputText("##total", total.data(), total.size(), ImGuiInputTextFlags_ReadOnly);
                            std::string button_text = "BUY " + locked_base;

                            bool enable = mm2_system_.do_i_have_enough_funds(locked_rel, total_balance);

                            if (not enable)
                            {
                                std::error_code ec;
                                ImGui::TextColored(error_color, "You don't have enough funds, you have %s %s",
                                    mm2_system_.my_balance_with_locked_funds(locked_rel, ec).c_str(), locked_rel.c_str());
                                ImGui::PushItemFlag(ImGuiItemFlags_Disabled, true);
                                ImGui::PushStyleVar(ImGuiStyleVar_Alpha, ImGui::GetStyle().Alpha * 0.5f);
                            }
                            if (ImGui::Button(button_text.c_str()))
                            {
                                t_buy_request   request{.base = locked_base, .rel = locked_rel, .price = current_price, .volume = current_amount};
                                std::error_code ec;
                                mm2_system_.place_buy_order(std::move(request), total_balance, ec);
                                if (ec) { LOG_F(ERROR, "{}", ec.message()); }
                            }
                            if (not enable)
                            {
                                ImGui::PopItemFlag();
                                ImGui::PopStyleVar();
                            }
                        }
                        ImGui::EndChild();

                        ImGui::SameLine();
                        ImGui::BeginChild("Sell Window", ImVec2(500, 500), true);
                        {
                            ImGui::Text("Sell %s", locked_base.c_str());

                            ImGui::Text("Price: ");
                            ImGui::SameLine();
                            ImGui::SetNextItemWidth(200.f);

                            static char price_buf[20];
                            ImGui::InputText("##price", price_buf, IM_ARRAYSIZE(price_buf), ImGuiInputTextFlags_CallbackCharFilter, crypto_amount_filter, price_buf);

                            ImGui::Text("Amount: ");
                            ImGui::SameLine();
                            ImGui::SetNextItemWidth(200.f);
                            static char amount_buf[20];
                            ImGui::InputText("##amount", amount_buf, IM_ARRAYSIZE(amount_buf), ImGuiInputTextFlags_CallbackCharFilter, crypto_amount_filter, amount_buf);
                            ImGui::Text("Total: ");
                            std::string total          = "";
                            std::string current_price  = price_buf;
                            std::string current_amount = amount_buf;
                            t_float_50  total_balance  = 0;
                            if (not current_price.empty() && not current_amount.empty())
                            {
                                boost::multiprecision::cpp_dec_float_50 current_price_f(current_price);
                                boost::multiprecision::cpp_dec_float_50 current_amount_f(current_amount);
                                total_balance = current_price_f * current_amount_f;
                                total         = total_balance.convert_to<std::string>();
                            }
                            ImGui::SameLine();
                            ImGui::InputText("##total", total.data(), total.size(), ImGuiInputTextFlags_ReadOnly);
                            std::string button_text = "SELL " + locked_base;

                            bool enable = mm2_system_.do_i_have_enough_funds(locked_base, total_balance);

                            if (not enable)
                            {
                                std::error_code ec;
                                ImGui::TextColored(error_color, "You don't have enough funds, you have %s %s",
                                    mm2_system_.my_balance_with_locked_funds(locked_base, ec).c_str(), locked_base.c_str());
                                ImGui::PushItemFlag(ImGuiItemFlags_Disabled, true);
                                ImGui::PushStyleVar(ImGuiStyleVar_Alpha, ImGui::GetStyle().Alpha * 0.5f);
                            }
                            if (ImGui::Button(button_text.c_str())) {}
                            if (not enable)
                            {
                                ImGui::PopItemFlag();
                                ImGui::PopStyleVar();
                            }
                        }
                        ImGui::EndChild();
                    }


                    ImGui::EndTabItem();
                }

                // If entered trade,
                if (!in_trade_prev && in_trade) { this->dispatcher_.trigger<gui_enter_trading>(); }
                else if (in_trade_prev && !in_trade)
                {
                    this->dispatcher_.trigger<gui_leave_trading>();
                }
                in_trade_prev = in_trade;

                ImGui::EndTabBar();
            }
        }

        ImGui::End();
    }
} // namespace atomic_dex
