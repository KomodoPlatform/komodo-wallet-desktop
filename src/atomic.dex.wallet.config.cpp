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

#include "atomic.dex.wallet.config.hpp"

namespace atomic_dex
{
    void
    from_json(const nlohmann::json& j, wallet_cfg& cfg)
    {
        j.at("name").get_to(cfg.name);
        if (j.contains("addressbook"))
        {
            for (const auto& [key, value]: j.at("addressbook").items())
            {
                wallet_cfg::t_address_registry registry;
                for (const auto& [cur_address_name, cur_address_value]: value.items()) { registry.emplace(cur_address_name, cur_address_value); }
                cfg.addressbook_registry[key] = registry;
            }
        }

        if (j.contains("categories"))
        {
            for (const auto& [category_name, members]: j.at("categories").items())
            {
                cfg.categories_addressbook_registry[category_name] = members.get<std::vector<std::string>>();
            }
        }
    }

    void
    to_json(nlohmann::json& j, const wallet_cfg& cfg)
    {
        j["name"] = cfg.name;
        j["addressbook"] = cfg.addressbook_registry;
        j["categories"] = cfg.categories_addressbook_registry;
    }
} // namespace atomic_dex