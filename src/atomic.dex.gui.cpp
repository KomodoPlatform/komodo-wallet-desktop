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

#include <imgui.h>
#include <antara/gaming/graphics/component.canvas.hpp>
#include <antara/gaming/event/quit.game.hpp>
#include "atomic.dex.gui.hpp"

namespace {
    void gui_menubar() noexcept {
        if (ImGui::BeginMenuBar()) {
            ImGui::EndMenuBar();
        }
    }
}

namespace atomic_dex {
    gui::gui(entt::registry &registry) noexcept : system(registry) {}

    void gui::update() noexcept {
        //! Menu bar
        auto &canvas = entity_registry_.ctx<ag::graphics::canvas_2d>();
        auto[x, y] = canvas.canvas.size;
        auto[pos_x, pos_y] = canvas.canvas.position;

        ImGui::SetNextWindowSize(ImVec2(x, y));
        ImGui::SetNextWindowPos(ImVec2(pos_x, pos_y));
        ImGui::SetNextWindowFocus();
        bool active = true;
        ImGui::Begin("Atomic Dex", &active, ImGuiWindowFlags_MenuBar | ImGuiWindowFlags_NoCollapse);
        if (not active) { this->dispatcher_.trigger<ag::event::quit_game>(0); }
        gui_menubar();
        ImGui::End();
    }
}
