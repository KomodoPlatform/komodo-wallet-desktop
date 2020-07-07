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

#include "atomic.dex.pch.hpp"

namespace atomic_dex
{
    struct cfg
    {
        std::string              current_lang{"en"};
        std::string              current_fiat{"USD"};
        std::vector<std::string> available_lang;
        std::vector<std::string> available_fiat;
    };

    void from_json(const nlohmann::json& j, cfg& config);
    void change_lang(cfg& config, const std::string& new_lang);
    void change_fiat(cfg& config, const std::string& new_fiat);
    cfg  load_cfg();
} // namespace atomic_dex