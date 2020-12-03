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
#include <utility>

//! Qt
#include <QJsonDocument>

//! Project
#include "qt.addressbook.contact.model.hpp"
#include "atomicdex/utilities/qt.utilities.hpp"
#include "atomicdex/services/mm2/mm2.service.hpp"


//! Constructors.
namespace atomic_dex
{
    addressbook_contact_model::addressbook_contact_model(ag::ecs::system_manager& system_manager, QString name, QObject* parent) :
        QAbstractListModel(parent), m_system_manager(system_manager), m_name(std::move(name))
    {
        populate();
    }
}

//! QAbstractListModel implementation
namespace atomic_dex
{
    QVariant addressbook_contact_model::data(const QModelIndex& index, int role) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()))
        {
            return {};
        }
    
        const auto& data = m_model_data.at(index.row());
        switch (role)
        {
        case ContactRoles::WalletInfoRole:
            return QVariant::fromValue(data);
        default:
            return {};
        }
    }
    
    int addressbook_contact_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return m_model_data.count();
    }
    
    QHash<int, QByteArray> addressbook_contact_model::roleNames() const
    {
        return {
            {WalletInfoRole, "wallet_info"},
        };
    }
}

//! QML API implementation
namespace atomic_dex
{
    const QString&
    addressbook_contact_model::get_name() const noexcept
    {
        return m_name;
    }

    void
    addressbook_contact_model::set_name(const QString& name) noexcept
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();

        if (name != m_name)
        {
            if (!m_name.isEmpty())
            {
                addrbook_manager.change_contact_name(m_name.toStdString(), name.toStdString());
                addrbook_manager.save_configuration();
            }
            m_name = name;
            emit nameChanged();
        }
    }

    const QStringList&
    addressbook_contact_model::get_categories() const noexcept
    {
        return m_categories;
    }

    void
    addressbook_contact_model::set_categories(QStringList categories) noexcept
    {
        m_categories = std::move(categories);
        emit categoriesChanged();
    }

    bool
    addressbook_contact_model::add_category(const QString& category) noexcept
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();

        if (addrbook_manager.has_category(m_name.toStdString(), category.toStdString()))
        {
            return false;
        }
        m_categories.append(category);
        emit categoriesChanged();
        return true;
    }

    void
    addressbook_contact_model::remove_category(const QString& category) noexcept
    {
        m_categories.removeOne(category);
        emit categoriesChanged();
    }

    void
    addressbook_contact_model::reset()
    {
        // Clears categories.
        m_categories.clear();

        // Clears inner model data.
        for (auto& inner_model: m_model_data) { delete inner_model; }
        m_model_data.clear();
        
        // Repopulates inner model data.
        populate();
    }

    void
    addressbook_contact_model::save()
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();

        // Saves categories.
        addrbook_manager.reset_contact_categories(m_name.toStdString());
        for (auto& category: m_categories) { addrbook_manager.add_contact_category(m_name.toStdString(), category.toStdString()); }

        // Saves inner model data.
        for (auto& data: m_model_data) { data->save(); }

        addrbook_manager.save_configuration();
    }
}

//! Misc section.
namespace atomic_dex
{
    void addressbook_contact_model::populate()
    {
        //! Loads categories.
        {
            auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();
            auto& contact          = addrbook_manager.get_contact(m_name.toStdString());
            
            set_categories(vector_std_string_to_qt_string_list(contact.at("categories")));
        }
        //! Loads inner model data (wallets info).
        {
            const auto& mm2          = m_system_manager.get_system<mm2_service>();
            const auto coins_list    = mm2.get_all_coins();
            const auto coins_nb      = coins_list.size();
            const auto coins_type_nb = 3;
            const auto create_addresses_model = [this](const QString& type)
            {
                m_model_data.push_back(new addressbook_contact_addresses_model(m_system_manager, m_name, type, this));
            };
            
            beginInsertRows(QModelIndex(), 0, coins_nb + coins_type_nb);
            for (const auto& coin : coins_list)
            {
                create_addresses_model(QString::fromStdString(coin.ticker));
            }
            create_addresses_model("QRC20");
            create_addresses_model("ERC20");
            create_addresses_model("SmartChain");
            endInsertRows();
        }
    }
}