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
    struct wallet_cfg
    {
        std::string name;
        using t_address_registry = std::unordered_map<std::string, std::string>;
        using t_addressbook_name = std::string;
        using t_category         = std::string;
        using t_names            = std::vector<std::string>;
        std::unordered_map<t_addressbook_name, t_address_registry> addressbook_registry;
        std::unordered_map<t_category, std::vector<std::string>>   categories_addressbook_registry;
    };

    void from_json(const nlohmann::json& j, wallet_cfg& cfg);
    void to_json(nlohmann::json& j, const wallet_cfg& cfg);
} // namespace atomic_dex
