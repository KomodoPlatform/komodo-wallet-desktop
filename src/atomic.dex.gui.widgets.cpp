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

#include <antara/gaming/timer/time.step.hpp>
#include "atomic.dex.gui.widgets.hpp"

namespace atomic_dex {
    void widgets::LoadingIndicatorCircle(const char *label, const float indicator_radius, const ImVec4 &main_color,
                                         const ImVec4 &backdrop_color, const int circle_count, const float speed) {
        ImGuiWindow *window = ImGui::GetCurrentWindow();
        if (window->SkipItems) {
            return;
        }

        const ImGuiID id = window->GetID(label);

        const ImVec2 pos = window->DC.CursorPos;
        const float circle_radius = indicator_radius / 10.0f;
        const ImRect bb(pos, ImVec2(pos.x + indicator_radius * 2.0f,
                                    pos.y + indicator_radius * 2.0f));
        auto &style = ImGui::GetStyle();
        ImGui::ItemSize(bb, style.FramePadding.y);
        if (!ImGui::ItemAdd(bb, id)) {
            return;
        }

        const float t = ImGui::GetCurrentContext()->Time;
        const auto degree_offset = 2.0f * IM_PI / circle_count;
        for (int i = 0; i < circle_count; ++i) {
            const auto x = indicator_radius * std::sin(degree_offset * i);
            const auto y = indicator_radius * std::cos(degree_offset * i);
            const auto growth = std::max(0.0f, std::sin(t * speed - i * degree_offset));
            ImVec4 color;
            color.x = main_color.x * growth + backdrop_color.x * (1.0f - growth);
            color.y = main_color.y * growth + backdrop_color.y * (1.0f - growth);
            color.z = main_color.z * growth + backdrop_color.z * (1.0f - growth);
            color.w = 1.0f;
            window->DrawList->AddCircleFilled(ImVec2(pos.x + indicator_radius + x,
                                                     pos.y + indicator_radius - y),
                                              circle_radius + growth * circle_radius,
                                              ImGui::GetColorU32(color));
        }
    }
}