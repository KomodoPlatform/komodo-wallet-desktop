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

//! QT
#include <QObject>

//! Deps
#include <antara/gaming/ecs/system.manager.hpp>

//! Project
#include "atomicdex/models/qt.addressbook.model.hpp"

namespace ag = antara::gaming;

namespace atomic_dex
{
    class addressbook_page final : public QObject, public ag::ecs::pre_update_system<addressbook_page>
    {
        /// \brief Tells QT this class uses signal/slots mechanisms and/or has GUI elements.
        Q_OBJECT
        
        /// \defgroup Properties
        /// {@
        
        ag::ecs::system_manager& m_system_manager;
        
        addressbook_model*       m_addressbook_model;
        
        /// @} End of Properties section.

    public:
        /// \defgroup Constructors
        /// {@
        
        explicit addressbook_page(entt::registry& registry,
                                  ag::ecs::system_manager& system_manager,
                                  addressbook_model* addressbook_model,
                                  QObject* parent = nullptr);
        ~addressbook_page() noexcept final = default;
        
        /// @} End of Constructors section.
    
        /// \brief pre_update_system implementation.
        void update() noexcept final;

        /// \defgroup QML API
        /// {@
        
        /// \brief Creates a new contact.
        /// \param contact_name The name of the contact.
        Q_INVOKABLE void add_contact(const QString& contact_name);
        Q_INVOKABLE void add_contact(QString contact_name, QVariantList addresses);
        
        /// \brief Creates a new contact.
        /// \param contact_name The name of the contact.
        /// \param addresses    The address information list of the contact.
        /// \param categories   The categories of the contact.
        Q_INVOKABLE void add_contact(QString contact_name, QVariantList addresses, QStringList categories);
        
        /// \brief Removes a contact.
        /// \param contact_name The name of the targeted contact.
        Q_INVOKABLE void remove_contact(QString contact_name);
        
        /// \brief Removes every contact.
        Q_INVOKABLE void remove_all_contacts();
        
        /// \brief Sets or creates wallet information for a contact.
        /// \param contact_name The name of the contact.
        /// \param type         The type of wallet. (e.g. BTC, erc-20)
        /// \param key          A key for the address.
        /// \param address      An address for the wallet.
        Q_INVOKABLE void set_contact_wallet_info(QString contact_name, QString type, QString key, QString address);
        
        /// \brief Removes wallet information for a contact.
        /// \param contact_name The name of the contact.
        /// \param type         The type of wallet.
        Q_INVOKABLE void remove_contact_wallet_info(QString contact_name, QString type);
    
        /// \brief Removes wallet information for a contact.
        /// \param contact_name The name of the contact.
        /// \param type         The type of wallet.
        /// \param key          The key to remove.
        Q_INVOKABLE void remove_contact_wallet_info(QString contact_name, QString type, QString key);
        
        /// \brief Adds a contact to a category.
        /// \param contact_name The name of the contact.
        /// \param category     The name of the category. (e.g. "Employer")
        Q_INVOKABLE void add_contact_category(QString contact_name, QString category);
        
        /// \brief Removes a contact from a category.
        /// \param contact_name The name of the contact.
        /// \param category     The name of the category. (e.g. "Friend")
        Q_INVOKABLE void remove_contact_category(QString contact_name, QString category);
        
    private:
        Q_PROPERTY(addressbook_model* addressbook_model READ get_addressbook_model NOTIFY addressbookChanged)
    public:
        [[nodiscard]]
        addressbook_model* get_addressbook_model() const noexcept;
    signals:
        void addressbookChanged();
    
        /// @} End of QML API section.
    };
}

REFL_AUTO(type(atomic_dex::addressbook_page))