/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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
#include <utility>
#include <stdexcept> //> std::invalid_argument.

//! Project Headers.
#include "addressbook.manager.hpp"

//! Constructors
namespace atomic_dex
{
    addressbook_manager::addressbook_manager(entt::registry& entity_registry, const ag::ecs::system_manager& system_manager)  :
        system(entity_registry), m_system_manager(system_manager), m_data(nlohmann::json::array())
    {}
}

//! Element access
namespace atomic_dex
{
    const nlohmann::json& addressbook_manager::at(std::size_t pos) const
    {
        return m_data.at(pos);
    }
    
    nlohmann::json& addressbook_manager::at(std::size_t pos)
    {
        return m_data.at(pos);
    }
    
    const nlohmann::json& addressbook_manager::data() const 
    {
        return m_data;
    }
    
    nlohmann::json& addressbook_manager::data() 
    {
        return m_data;
    }
    
    const nlohmann::json& addressbook_manager::get_contacts() const 
    {
        return data();
    }
    
    nlohmann::json& addressbook_manager::get_contacts() 
    {
        return data();
    }
    
    const nlohmann::json& addressbook_manager::get_contact(const std::string& name) const
    {
        for (auto it = m_data.begin(); it != m_data.end(); ++it)
        {
            if (it.value().at("name") == name)
            {
                return it.value();
            }
        }
        throw std::invalid_argument("(addressbook_manager::get_contact) given contact name does not exist");
    }
    
    nlohmann::json& addressbook_manager::get_contact(const std::string& name)
    {
        return const_cast<nlohmann::json&>(std::as_const(*this).get_contact(name));
    }
    
    const nlohmann::json& addressbook_manager::get_wallets_info(const std::string& name) const
    {
        return get_contact(name).at("wallets_info");
    }
    
    nlohmann::json& addressbook_manager::get_wallets_info(const std::string& name)
    {
        return const_cast<nlohmann::json&>(std::as_const(*this).get_wallets_info(name));
    }
    
    const nlohmann::json& addressbook_manager::get_wallet_info(const std::string& name, const std::string& type) const
    {
        for (const auto& wallet_info : get_wallets_info(name))
        {
            if (wallet_info.at("type").get<std::string>() == type)
            {
                return wallet_info;
            }
        }
        throw std::invalid_argument("(addressbook_manager::get_wallet_info) given wallet info type does not exist");
    }
    
    nlohmann::json& addressbook_manager::get_wallet_info(const std::string& name, const std::string& type)
    {
        return const_cast<nlohmann::json&>(std::as_const(*this).get_wallet_info(name, type));
    }
    
    const nlohmann::json& addressbook_manager::get_wallet_info_address(const std::string& name, const std::string& type, const std::string& key) const
    {
        return get_wallet_info(name, type).at("addresses").at(key);
    }
    
    nlohmann::json& addressbook_manager::get_wallet_info_address(const std::string& name, const std::string& type, const std::string& key)
    {
        return const_cast<nlohmann::json&>(std::as_const(*this).get_wallet_info_address(name, type, key));
    }
    
    const nlohmann::json& addressbook_manager::get_categories(const std::string& name) const
    {
        return get_contact(name).at("categories");
    }
    
    nlohmann::json& addressbook_manager::get_categories(const std::string& name)
    {
        return const_cast<nlohmann::json&>(std::as_const(*this).get_categories(name));
    }
}

//! Modifiers
namespace atomic_dex
{
    void addressbook_manager::add_contact(const std::string& name)
    {
        nlohmann::json contact = nlohmann::json::object();
    
        contact["name"] = name;
        contact["categories"] = nlohmann::json::array();
        contact["wallets_info"] = nlohmann::json::array();
        if (!m_data.is_array())
        {
            m_data = nlohmann::json::array();
        }
        m_data.push_back(std::move(contact));
    }

    void addressbook_manager::remove_contact(const std::string& name)
    {
        for (auto it = m_data.begin(); it != m_data.end(); ++it)
        {
            if (it.value().at("name") == name)
            {
                m_data.erase(it);
                return;
            }
        }
    }
    
    void addressbook_manager::remove_all_contacts()
    {
        m_data.clear();
    }
    
    void addressbook_manager::change_contact_name(const std::string& name, const std::string& new_name)
    {
        auto& contact = get_contact(name);
        
        contact.at("name") = new_name;
    }
    
    void addressbook_manager::set_contact_wallet_info(
        const std::string& name, const std::string& type, const std::string& key, const std::string& address)
    {
        auto& wallets_info = get_wallets_info(name);
        if (!has_wallet_info(name, type))
        {
            wallets_info.push_back({{"type", type}});
        }
        auto& wallet_info = get_wallet_info(name, type);
    
        wallet_info["addresses"][key] = address;
    }
    
    void addressbook_manager::remove_contact_wallet_info(const std::string& name, const std::string& type)
    {
        auto& wallets_info = get_wallets_info(name);

        wallets_info.erase(std::remove_if(begin(wallets_info), end(wallets_info), [type](const auto& wallet_info)
        {
            return wallet_info.at("type") == type;
        }));
    }
    
    void addressbook_manager::remove_contact_wallet_info(const std::string& name, const std::string& type, const std::string& key)
    {
        auto& wallet_info = get_wallet_info(name, type);
        
        wallet_info.at("addresses").erase(key);
        if (wallet_info.at("addresses").empty())
        {
            remove_contact_wallet_info(name, type);
        }
    }
    
    void addressbook_manager::remove_every_wallet_info(const std::string& name)
    {
        auto& contact = get_contact(name);
        
        contact.at("wallets_info") = nlohmann::json::array();
    }
    
    bool addressbook_manager::add_contact_category(const std::string& name, const std::string& category)
    {
        auto& categories = get_categories(name);
        
        if (has_category(name, category))
        {
            return false;
        }
        categories.push_back(category);
        return true;
    }
    
    void addressbook_manager::remove_contact_category(const std::string& name, const std::string& category)
    {
        auto& categories = get_categories(name);
        
        for (auto i = 0U; i < categories.size(); i++)
        {
            if (categories[i].get<std::string>() == category)
            {
                categories.erase(i);
                return;
            }
        }
    }
    
    void addressbook_manager::reset_contact_categories(const std::string& name)
    {
        auto& contact = get_contact(name);
    
        contact["categories"] = nlohmann::json::array();
    }
}

//! Lookup
namespace atomic_dex
{
    std::size_t addressbook_manager::nb_contacts() const 
    {
        return get_contacts().size();
    }
    
    bool addressbook_manager::has_contact(const std::string& name) const 
    {
        for (auto it = m_data.begin(); it != m_data.end(); ++it)
        {
            if (it.value().at("name") == name)
            {
                return true;
            }
        }
        return false;
    }
    
    bool addressbook_manager::has_wallet_info(const std::string& name, const std::string& type) const
    {
        const auto& wallets_info = get_wallets_info(name);
        const auto it = std::find_if(begin(wallets_info), end(wallets_info), [type](const auto& elem)
        {
            return elem.at("type") == type;
        });
        return it != wallets_info.end();
    }
    
    bool addressbook_manager::has_wallet_info(const std::string& name, const std::string& type, const std::string& key) const
    {
        if (has_wallet_info(name, type))
        {
            const auto& wallet_info = get_wallet_info(name, type);

            return wallet_info.at("addresses").contains(key);
        }
        return false;
    }
    
    bool addressbook_manager::has_category(const std::string& name, const std::string& category) const 
    {
        const auto& categories = get_categories(name);
        
        for (auto it = categories.begin(); it != categories.end(); ++it)
        {
            if (it.value().get<std::string>() == category)
            {
                return true;
            }
        }
        return false;
    }
}

//! Misc
namespace atomic_dex
{
    void addressbook_manager::update() 
    { }
    
    void addressbook_manager::load_configuration()
    {
        m_data = load_addressbook_cfg(m_system_manager.get_system<qt_wallet_manager>().get_wallet_default_name().toStdString());
    }
    
    void addressbook_manager::save_configuration() const
    {
        update_addressbook_cfg(m_data, m_system_manager.get_system<qt_wallet_manager>().get_wallet_default_name().toStdString());
    }
}