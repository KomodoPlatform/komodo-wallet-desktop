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

//! STD
#include <algorithm>

//! Project Headers.
#include "addressbook.manager.hpp"

//! Constructors
namespace atomic_dex
{
    addressbook_manager::addressbook_manager(const std::string& wallet_name) noexcept :
        m_wallet_name(wallet_name), m_data(load_addressbook_cfg(m_wallet_name))
    {}
}

//! Modifiers
namespace atomic_dex
{
    void addressbook_manager::add_contact(const std::string& name)
    {
        m_data[name] = nlohmann::json::object();
        m_data.at(name)["categories"] = nlohmann::json::array();
        m_data.at(name)["wallets_info"] = nlohmann::json::object();
    }

    void addressbook_manager::remove_contact(const std::string& name)
    {
        m_data.erase(name);
    }
    
    void addressbook_manager::remove_all_contacts()
    {
        m_data.clear();
    }
    
    void addressbook_manager::change_contact_name(const std::string& name, const std::string& new_name)
    {
        m_data[new_name] = m_data.at(name);
        m_data.erase(name);
    }
    
    void addressbook_manager::set_contact_wallet_info(
        const std::string& name, const std::string& type, const std::string& key, const std::string& address)
    {
        auto& wallets_info = get_wallets_info(name);
        
        if (!wallets_info.contains(type))
        {
            wallets_info[type] = nlohmann::json::object();
        }
        wallets_info[type][key] = address;
    }
    
    void addressbook_manager::remove_contact_wallet_info(const std::string& name, const std::string& type)
    {
        auto& wallets_info = get_wallets_info(name);

        wallets_info.erase(type);
    }
    
    void addressbook_manager::remove_contact_wallet_info(const std::string& name, const std::string& type, const std::string& key)
    {
        auto& wallet_info = get_wallet_info(name, type);
        
        wallet_info.erase(key);
    }
    
    bool addressbook_manager::add_contact_category(const std::string& name, const std::string& category)
    {
        auto& categories = get_categories(name);
        
        if (categories.contains(category))
        {
            return false;
        }
        categories.push_back(category);
        return true;
    }
    
    void addressbook_manager::remove_contact_category(const std::string& name, const std::string& category)
    {
        auto& categories = get_categories(name);
        
        categories.erase(category);
    }
}

//! Accessors
namespace atomic_dex
{
    const nlohmann::json& addressbook_manager::get_contact(const std::string& name) const noexcept
    {
        return m_data.at(name);
    }
    
    nlohmann::json& addressbook_manager::get_contact(const std::string& name) noexcept
    {
        return const_cast<nlohmann::json&>(std::as_const(*this).get_contact(name));
    }
    
    const nlohmann::json& addressbook_manager::get_contacts() const noexcept
    {
        return m_data;
    }
    
    const nlohmann::json& addressbook_manager::get_wallets_info(const std::string& name) const
    {
        return m_data.at(name).at("wallets_info");
    }
    
    nlohmann::json& addressbook_manager::get_wallets_info(const std::string& name)
    {
        return const_cast<nlohmann::json&>(std::as_const(*this).get_wallets_info(name));
    }
    
    const nlohmann::json& addressbook_manager::get_wallet_info(const std::string& name, const std::string& type) const
    {
        return get_wallets_info(name).at(type);
    }
    
    nlohmann::json& addressbook_manager::get_wallet_info(const std::string& name, const std::string& type)
    {
        return const_cast<nlohmann::json&>(std::as_const(*this).get_wallet_info(name, type));
    }
    
    const nlohmann::json& addressbook_manager::get_categories(const std::string& name) const
    {
        return m_data.at(name).at("categories");
    }
    
    nlohmann::json& addressbook_manager::get_categories(const std::string& name)
    {
        return const_cast<nlohmann::json&>(std::as_const(*this).get_categories(name));
    }
}

//! Lookup
namespace atomic_dex
{
    bool addressbook_manager::has_contact(const std::string& name) const noexcept
    {
        return m_data.contains(name);
    }
    
    bool addressbook_manager::has_wallet_info(const std::string& name, const std::string& type) const noexcept
    {
        return get_wallets_info(name).contains(type);
    }
    
    bool addressbook_manager::has_category(const std::string& name, const std::string& category) const noexcept
    {
        return get_categories(name).contains(category);
    }
}

//! Misc
namespace atomic_dex
{
    void addressbook_manager::update_configuration() const
    {
        update_addressbook_cfg(m_data, m_wallet_name);
    }
}