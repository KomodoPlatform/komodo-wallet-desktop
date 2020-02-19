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
#include "atomic.dex.gui.v2.hpp"
#include "atomic.dex.gui.style.hpp"
#include "atomic.dex.gui.widgets.hpp"

namespace
{
    atomic_dex::e_gui_state
    guess_initial_state()
    {
        using namespace atomic_dex;
        return fs::exists(ag::core::assets_real_path() / "config/encrypted.seed") ? e_gui_state::credential_view : e_gui_state::first_run_view;
    }
} // namespace

namespace atomic_dex
{
    gui_v2::gui_v2(entt::registry& registry, atomic_dex::mm2& mm2_system, atomic_dex::coinpaprika_provider& paprika_system) :
        system(registry), m_mm2_instance(mm2_system), m_paprika_system(paprika_system), m_current_state(guess_initial_state())
    {
        style::apply();
    }

    void
    gui_v2::update() noexcept
    {
        auto& canvas = entity_registry_.ctx<ag::graphics::canvas_2d>();
        auto [x, y]  = canvas.window.size;

        ImGui::SetNextWindowSize(ImVec2(x, y), ImGuiCond_FirstUseEver);
        bool active = true;
        if (im_scoped_window("AtomicDextop", &active, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_MenuBar))
        {
            if (not active)
            {
                this->dispatcher_.trigger<ag::event::quit_game>(0);
            }

            switch (m_current_state)
            {
            case e_gui_state::first_run_view:
                first_run_view();
                break;
            case e_gui_state::credential_view:
                login_view();
                break;
            case e_gui_state::waiting_view:
                waiting_view();
                break;
            case e_gui_state::portoflio_view:
                portfolio_view();
                break;
            case e_gui_state::trading_view:
                trading_view();
                break;
            }
        }
    }
} // namespace atomic_dex
