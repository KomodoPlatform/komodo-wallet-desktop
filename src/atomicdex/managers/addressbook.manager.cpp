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

namespace atomic_dex
{
    addressbook_manager::addressbook_manager(wallet_cfg& wallet_configuration) noexcept :
        wallet_configuration(wallet_configuration)
    { }
    
    void addressbook_manager::add_contact(const std::string& name, const std::vector<addressbook_contact_wallet_info>& wallets_info)
    {
        add_contact(name, wallets_info, {});
    }
    
    void addressbook_manager::add_contact(
        const std::string& name, const std::vector<addressbook_contact_wallet_info>& wallets_info, const std::vector<std::string>& categories)
    {
        wallet_configuration.addressbook_contacts.push_back(
            addressbook_contact{.name = name, .wallets_info = wallets_info, .categories = categories});
    }
    
    void addressbook_manager::remove_contact(const std::string& name)
    {
        auto& contacts = wallet_configuration.addressbook_contacts;
        
        contacts.erase(std::remove_if(contacts.begin(),
                                      contacts.end(),
                                      [name](const auto& contact) { return contact.name == name; }),
                       contacts.end());
    }
    
    void addressbook_manager::remove_all_contacts()
    {
        wallet_configuration.addressbook_contacts.clear();
    }
    
    void addressbook_manager::set_contact_wallet_info(
        const std::string& name, const std::string& type, const std::string& key, const std::string& address)
    {
        auto& wallet_info = get_or_create_contact_wallet_info(name, type);
        
        wallet_info.addresses[key] = address;
    }
    
    void addressbook_manager::remove_contact_wallet_info(const std::string& name, const std::string& type)
    {
        auto& wallets_info = get_contact(name).wallets_info;
        
        wallets_info.erase(std::remove_if(wallets_info.begin(),
                                          wallets_info.end(),
                                          [type](const auto& wallet_info) { return wallet_info.type == type; }),
                           wallets_info.end());
    }
    
    bool addressbook_manager::add_contact_category(const std::string& name, const std::string& category)
    {
        auto& categories = get_contact(name).categories;
        
        if (std::find(categories.begin(), categories.end(), category) != categories.end())
        {
            return false;
        }
        categories.push_back(category);
        return true;
    }
    
    void addressbook_manager::remove_contact_category(const std::string& name, const std::string& category)
    {
        auto& categories = get_contact(name).categories;
        
        categories.erase(std::remove(categories.begin(), categories.end(), category), categories.end());
    }
    
    const addressbook_contact& addressbook_manager::get_contact(const std::string& name) const noexcept
    {
        auto contacts = wallet_configuration.addressbook_contacts;
    
        return *std::find_if(contacts.begin(), contacts.end(), [name](const auto& contact) { return contact.name == name; });
    }
    
    addressbook_contact& addressbook_manager::get_contact(const std::string& name) noexcept
    {
        return const_cast<addressbook_contact&>(std::as_const(*this).get_contact(name));
    }
    
    addressbook_contact_wallet_info& addressbook_manager::get_contact_wallet_info(const std::string& name, const std::string& type)
    {
        auto& wallets_info = get_contact(name).wallets_info;
        
        return *std::find_if(wallets_info.begin(), wallets_info.end(), [type](const auto& wallet_info) { return wallet_info.type == type; });
    }
    
    const std::vector<addressbook_contact>& addressbook_manager::get_contacts() const noexcept
    {
        return this->wallet_configuration.addressbook_contacts;
    }
    
    addressbook_contact_wallet_info& addressbook_manager::get_or_create_contact_wallet_info(const std::string& name, const std::string& type)
    {
        if (!has_wallet_info(name, type))
        {
            auto& wallets_info = get_contact(name).wallets_info;
            
            wallets_info.push_back(addressbook_contact_wallet_info{.type = type});
        }
        return get_contact_wallet_info(name, type);
    }
    
    bool addressbook_manager::has_contact(const std::string& name) const noexcept
    {
        auto& contacts = wallet_configuration.addressbook_contacts;
        
        return std::find_if(contacts.begin(), contacts.end(), [name](const auto& contact) { return contact.name == name; }) != contacts.end();
    }
    
    bool addressbook_manager::has_wallet_info(const std::string& name, const std::string& type) const noexcept
    {
        const auto& wallets_info = get_contact(name).wallets_info;
        
        return std::find_if(wallets_info.begin(), wallets_info.end(),
                            [type](const auto& wallet_info) { return wallet_info.type == type; }) != wallets_info.end();
    }
}