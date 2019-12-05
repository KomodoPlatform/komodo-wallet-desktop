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

#include <algorithm>
#include <cmath>
#include <imgui.h>
#include <imgui_internal.h>

namespace atomic_dex::widgets {

    void LoadingIndicatorCircle(const char *label, const float indicator_radius,
                                const ImVec4 &main_color, const ImVec4 &backdrop_color,
                                const int circle_count, const float speed);
}