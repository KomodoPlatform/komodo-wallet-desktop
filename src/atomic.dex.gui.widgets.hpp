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

namespace atomic_dex::widgets
{
    void
    loading_indicator_circle(const char* label, float indicator_radius, const ImVec4& main_color, const ImVec4& backdrop_color, int circle_count, float speed);
} // namespace atomic_dex::widgets

class im_scoped_window
{
    bool m_visible;

  public:
    template <typename... Args>
    im_scoped_window(Args&&... args) : m_visible(ImGui::Begin(std::forward<Args>(args)...))
    {
    }

    ~im_scoped_window() { ImGui::End(); }

    explicit operator bool() { return m_visible; }
};