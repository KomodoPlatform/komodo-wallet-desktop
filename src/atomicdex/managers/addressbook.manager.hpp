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

//! Project Headers
#include "atomicdex/config/wallet.cfg.hpp"

namespace atomic_dex
{
    class addressbook_manager
    {
        wallet_cfg& wallet_configuration;
        
      public:
        /// \defgroup Constructors
        /// {@
        
        explicit addressbook_manager(wallet_cfg& wallet_configuration) noexcept;
        ~addressbook_manager() = default;
        
        /// @} End of Constructors section.
        
        /// \defgroup Modifiers
        /// {@
    
        /// \brief Creates a new contact.
        /// \param name         The name of the contact.
        /// \param wallets_info The address information list of the contact.
        void add_contact(const std::string& name, const std::vector<addressbook_contact_wallet_info>& wallets_info);
    
        /// \brief Creates a new contact.
        /// \param name         The name of the contact.
        /// \param wallets_info The address information list of the contact.
        /// \param categories   The categories of the contact.
        void add_contact(const std::string& name,
                         const std::vector<addressbook_contact_wallet_info>& wallets_info,
                         const std::vector<std::string>& categories);
    
        /// \brief   Removes a contact.
        /// \warning If the contact does not exist yet, the behavior is undefined.
        /// \param   name The name of the targeted contact.
        void remove_contact(const std::string& name);
    
        /// \brief Removes every contact.
        void remove_all_contacts();
    
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
        /// \return  A const reference to an addressbook_contact.
        [[nodiscard]]
        const addressbook_contact& get_contact(const std::string& name) const noexcept;
        
        /// \brief   Gets a contact from its name.
        /// \warning If the contact does not exist yet, the behavior is undefined.
        /// \param   name Name of the contact.
        /// \return  A reference to an addressbook_contact.
        [[nodiscard]]
        addressbook_contact& get_contact(const std::string& name) noexcept;
        
        [[nodiscard]]
        addressbook_contact_wallet_info& get_contact_wallet_info(const std::string& name, const std::string& type);
        
        [[nodiscard]]
        addressbook_contact_wallet_info& get_or_create_contact_wallet_info(const std::string& name, const std::string& type);
        
        [[nodiscard]]
        /// \brief  Gets the existings contacts.
        /// \return A reference to an std::vector of addressbook_contact objects.
        const std::vector<addressbook_contact>& get_contacts() const noexcept;
        
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
        
        /// @} End of Lookup section.
    };
}