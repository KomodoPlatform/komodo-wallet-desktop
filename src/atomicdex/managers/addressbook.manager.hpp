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

//! Deps
#include <antara/gaming/ecs/system.manager.hpp>

//! Project Headers
#include "atomicdex/config/addressbook.cfg.hpp"
#include "qt.wallet.manager.hpp"

namespace ag = antara::gaming;

namespace atomic_dex
{
    class addressbook_manager final : public ag::ecs::pre_update_system<addressbook_manager>
    {
        const ag::ecs::system_manager& m_system_manager;
        nlohmann::json                 m_data;
        
      public:
        /// \defgroup Constructors
        /// {@
        
        addressbook_manager(entt::registry& entity_registry, const ag::ecs::system_manager& system_manager) noexcept;
        ~addressbook_manager() noexcept final = default;
        
        /// @} End of Constructors section.
    
        /// \brief pre_update_system implementation.
        void update() noexcept final;
        
        /// \defgroup Modifiers
        /// {@
    
        /// \brief Creates a new contact.
        /// \param name         The name of the contact.
        /// \param wallets_info The address information list of the contact.
        void add_contact(const std::string& name);

        /// \brief   Removes a contact.
        /// \warning If the contact does not exist yet, the behavior is undefined.
        /// \param   name The name of the targeted contact.
        void remove_contact(const std::string& name);
    
        /// \brief Removes every contact.
        void remove_all_contacts();
        
        /// \brief   Changes the name of a contact.
        /// \warning If the contact does not exist, the behavior is undefined.
        /// \param   name     Current name of the contact.
        /// \param   new_name New name to use.
        void change_contact_name(const std::string& name, const std::string& new_name);
    
        /// \brief   Sets or creates wallet information for a contact.
        /// \warning If the contact does not exist yet, the behavior is undefined.
        /// \param   name    The name of the contact.
        /// \param   type    The type of wallet. (e.g. BTC, erc-20)
        /// \param   key     A key for the address.
        /// \param   address An address for the wallet.
        void set_contact_wallet_info(const std::string& name,
                                     const std::string& type,
                                     const std::string& key,
                                     const std::string& address);
    
        /// \brief   Removes wallet information from a contact.
        /// \warning If the contact does not exist yet, the behavior is undefined.
        /// \param   contact_name The name of the contact.
        /// \param   type         The type of wallet.
        void remove_contact_wallet_info(const std::string& name, const std::string& type);
    
        /// \brief   Removes wallet information from a contact.
        /// \warning If the contact does not exist yet, the behavior is undefined.
        /// \param   name The name of the contact.
        /// \param   type The type of wallet.
        /// \param   key  The key to remove.
        void remove_contact_wallet_info(const std::string& name, const std::string& type, const std::string& key);
    
        /// \brief   Adds a contact to a category.
        /// \warning If the contact does not exist yet, the behavior is undefined.
        /// \param   name     The name of the contact.
        /// \param   category The name of the category. (e.g. "Employer")
        /// \return  False if this category is already associated to the given contact, true otherwise.
        bool add_contact_category(const std::string& name, const std::string& category);
    
        /// \brief   Removes a contact from a category.
        /// \warning If the contact does not exist yet, the behavior is undefined.
        /// \param   name     The name of the contact.
        /// \param   category The name of the category. (e.g. "Friend")
        void remove_contact_category(const std::string& name, const std::string& category);
        
        /// @} End of Modifiers section.
        
        /// \defgroup Accessors.
        /// {@
        
        /// \brief   Gets a contact from its name.
        /// \warning If the contact does not exist yet, the behavior is undefined.
        /// \param   name Name of the contact.
        [[nodiscard]]
        const nlohmann::json& get_contact(const std::string& name) const;
        
        /// \brief   Gets a contact from its name.
        /// \warning If the contact does not exist yet, the behavior is undefined.
        /// \param   name Name of the contact.
        [[nodiscard]]
        nlohmann::json& get_contact(const std::string& name);

        [[nodiscard]]
        /// \brief  Gets the existing contacts.
        const nlohmann::json& get_contacts() const noexcept;
    
        [[nodiscard]]
        const nlohmann::json& get_wallets_info(const std::string& name) const;
        
        [[nodiscard]]
        nlohmann::json& get_wallets_info(const std::string& name);
    
        [[nodiscard]]
        const nlohmann::json& get_wallet_info(const std::string& name, const std::string& type) const;
        
        [[nodiscard]]
        nlohmann::json& get_wallet_info(const std::string& name, const std::string& type);
        
        [[nodiscard]]
        const nlohmann::json& get_categories(const std::string& name) const;
        
        [[nodiscard]]
        nlohmann::json& get_categories(const std::string& name);
        
        /// @} End of Accessors section.
        
        /// \defgroup Lookup
        /// {@
        
        /// \brief  Tells if a contact exists.
        /// \param  name Name of the contact.
        /// \return True if the contact exists, false otherwise.
        [[nodiscard]]
        bool has_contact(const std::string& name) const noexcept;
        
        /// \brief   Tells if a contact name possesses wallet information.
        /// \warning If the contact does not exist yet, the behavior is undefined.
        /// \param   name Name of the contact.
        /// \param   type Type of wallet.
        /// \return  True if the contact possesses the wallet, false otherwise.
        [[nodiscard]]
        bool has_wallet_info(const std::string& name, const std::string& type) const noexcept;
        
        /// \brief   Tells if a contact belong to a category.
        /// \warning If the contact does not exist yet, the behavior is undefined.
        /// \param   name     Contact name.
        /// \param   category A category.
        /// \return  True if the contact belongs to the category, false otherwise.
        [[nodiscard]]
        bool has_category(const std::string& name, const std::string& category) const noexcept;
        
        /// @} End of Lookup section.
        
        /// \defgroup Misc
        /// {@
        
        /// \brief Loads the address book configuration.
        void load_configuration();
        
        /// \brief Saves the current state of the addressbook inside the configuration file.
        void save_configuration() const;
        
        /// @} End of Misc section.
    };
}

REFL_AUTO(type(atomic_dex::addressbook_manager))