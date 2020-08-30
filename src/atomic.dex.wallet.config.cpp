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

//! PCH
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.wallet.config.hpp"

namespace atomic_dex
{
    void
    from_json(const nlohmann::json& j, wallet_cfg& cfg)
    {
        j.at("name").get_to(cfg.name);
        if (j.contains("protection_pass"))
        {
            j.at("protection_pass").get_to(cfg.protection_pass);
        }
        if (j.contains("addressbook"))
        {
            for (const auto& cur: j.at("addressbook"))
            {
                contact current_contact;
                cur.at("name").get_to(current_contact.name);
                for (const auto& cur_addr: cur.at("addresses"))
                {
                    contact_contents contents;
                    cur_addr.at("type").get_to(contents.type);
                    cur_addr.at("address").get_to(contents.address);
                    current_contact.contents.emplace_back(std::move(contents));
                }
                cfg.address_book.emplace_back(std::move(current_contact));
            }
        }
    }

    void
    to_json(nlohmann::json& j, const contact_contents& cfg)
    {
        j["type"]    = cfg.type;
        j["address"] = cfg.address;
    }

    void
    to_json(nlohmann::json& j, const contact& cfg)
    {
        j["name"]      = cfg.name;
        j["addresses"] = cfg.contents;
    }

    void
    to_json(nlohmann::json& j, const wallet_cfg& cfg)
    {
        j["name"]            = cfg.name;
        j["protection_pass"] = cfg.protection_pass;
        j["addressbook"]     = cfg.address_book;
    }
} // namespace atomic_dex