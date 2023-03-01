/******************************************************************************
 * Copyright © 2013-2022 The Komodo Platform Developers.                      *
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

#include <utility>

#include <QJsonDocument>

#include "atomicdex/pages/qt.portfolio.page.hpp"
#include "atomicdex/utilities/qt.utilities.hpp"
#include "atomicdex/managers/addressbook.manager.hpp"    //> addressbook_manager
#include "qt.addressbook.contact.model.hpp"              //> addressbook_contact_model
#include "qt.addressbook.contact.proxy.filter.model.hpp" //> addressbook_contact_proxy_filter_model

// Ctor/Dtor
namespace atomic_dex
{
    addressbook_contact_model::addressbook_contact_model(ag::ecs::system_manager& system_manager, QString name, QObject* parent) :
        QAbstractListModel(parent),
        m_system_manager(system_manager),
        m_name(std::move(name)),
        m_proxy_filter(new addressbook_contact_proxy_filter_model(system_manager, this))
    {
        populate();
        m_proxy_filter->setDynamicSortFilter(true);
        m_proxy_filter->setSourceModel(this);
        m_proxy_filter->sort(0);
    }

    addressbook_contact_model::~addressbook_contact_model()  { clear(); }
}

// QAbstractListModel Functions
namespace atomic_dex
{
    QVariant addressbook_contact_model::data(const QModelIndex& index, int role) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()))
        {
            return {};
        }

        const auto& address_entry = m_address_entries.at(index.row());
        switch (role)
        {
        case ContactRoles::AddressTypeRole:
            return address_entry.type;
        case ContactRoles::AddressKeyRole:
            return address_entry.key;
        case ContactRoles::AddressValueRole:
            return address_entry.value;
        case ContactRoles::AddressTypeAndKeyRole: // Used for address entry removal.
            return address_entry.type + address_entry.key;
        default:
            return {};
        }
    }

    int addressbook_contact_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return m_address_entries.size();
    }

    QHash<int, QByteArray> addressbook_contact_model::roleNames() const
    {
        return {
            {AddressTypeRole, "address_type"},
            {AddressKeyRole, "address_key"},
            {AddressValueRole, "address_value"}
        };
    }
} // namespace atomic_dex

// Getters/Setters
namespace atomic_dex
{
    const QString& addressbook_contact_model::get_name() const 
    {
        return m_name;
    }
    
    void addressbook_contact_model::set_name(const QString& name) 
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();
        
        if (name != m_name)
        {
            if (!name.isEmpty())
            {
                addrbook_manager.change_contact_name(m_name.toStdString(), name.toStdString());
                addrbook_manager.save_configuration();
                m_name = name;
                emit nameChanged();
            }
        }
    }
    
    const QStringList& addressbook_contact_model::get_categories() const 
    {
        return m_categories;
    }
    
    void addressbook_contact_model::set_categories(QStringList categories) 
    {
        m_categories = std::move(categories);
        emit categoriesChanged();
    }
    
    addressbook_contact_proxy_filter_model* addressbook_contact_model::get_proxy_filter() const 
    {
        return m_proxy_filter;
    }
    
    const QVector<addressbook_contact_model::address_entry>& addressbook_contact_model::get_address_entries() const 
    {
        return m_address_entries;
    }
}

// QML API
namespace atomic_dex
{
    bool addressbook_contact_model::addCategory(const QString& category) 
    {
        if (m_categories.contains(category))
        {
            return false;
        }
        m_categories.append(category);
        emit categoriesChanged();
        return true;
    }

    void addressbook_contact_model::removeCategory(const QString& category) 
    {
        m_categories.removeOne(category);
        emit categoriesChanged();
    }
    
    bool addressbook_contact_model::addAddressEntry(QString type, QString key, QString value) 
    {
        // Returns false if the given key already exists.
        auto res = match(index(0), AddressTypeAndKeyRole, type + key, 1, Qt::MatchFlag::MatchExactly);
        if (not res.empty())
        {
            return false;
        }
    
        beginInsertRows(QModelIndex(), rowCount(), rowCount());
        m_address_entries.push_back(address_entry
                                        {
                                            .type = std::move(type),
                                            .key = std::move(key),
                                            .value = std::move(value)
                                        });
        endInsertRows();
        return true;
    }
    
    void addressbook_contact_model::removeAddressEntry(const QString& type, const QString& key) 
    {
        auto res = match(index(0), AddressTypeAndKeyRole, type + key, 1, Qt::MatchFlag::MatchExactly);
    
        if (not res.empty())
        {
            beginRemoveRows(QModelIndex(), res.at(0).row(), res.at(0).row());
            m_address_entries.removeAt(res.at(0).row());
            endRemoveRows();
        }
    }

    void addressbook_contact_model::reload()
    {
        // Clears model
        clear();

        // Repopulates inner model data.
        populate();
    }

    void addressbook_contact_model::save()
    {
        auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();

        // Saves categories.
        addrbook_manager.reset_contact_categories(m_name.toStdString());
        for (const auto& category: m_categories) { addrbook_manager.add_contact_category(m_name.toStdString(), category.toStdString()); }

        // Cleans existing wallet info persistent data before erasing it.
        addrbook_manager.remove_every_wallet_info(m_name.toStdString());

        // Saves inner model data.
        for (auto& address_entry: m_address_entries)
        {
            addrbook_manager.set_contact_wallet_info(m_name.toStdString(), address_entry.type.toStdString(),
                                                     address_entry.key.toStdString(), address_entry.value.toStdString());
        }

        addrbook_manager.save_configuration();
    }
} // namespace atomic_dex

//! Others
namespace atomic_dex
{
    void
    addressbook_contact_model::populate()
    {
        // Loads categories.
        {
            auto& addrbook_manager = m_system_manager.get_system<addressbook_manager>();
            auto& contact          = addrbook_manager.get_contact(m_name.toStdString());

            set_categories(vector_std_string_to_qt_string_list(contact.at("categories")));
        }
        // Loads address entries.
        {
            const auto& addrbook_manager       = m_system_manager.get_system<addressbook_manager>();
            const auto& portfolio_pg           = m_system_manager.get_system<portfolio_page>();
            const auto  coins_list             = portfolio_pg.get_global_cfg()->get_model_data();
            const auto& coins_type_list        = portfolio_pg.get_global_cfg()->get_all_coin_types();
            const auto  create_address_entries = [&](const QString& type)
            {
                if (!addrbook_manager.has_wallet_info(m_name.toStdString(), type.toStdString()))
                {
                    return;
                }
                const auto& addresses = addrbook_manager.get_wallet_info(m_name.toStdString(), type.toStdString()).at("addresses");
    
                for (auto it = addresses.begin(); it != addresses.end(); ++it)
                {
                    m_address_entries.push_back(address_entry
                                                {
                                                    .type = type,
                                                    .key = QString::fromStdString(it.key()),
                                                    .value = QString::fromStdString(it.value())
                                                });
                }
            };

            beginResetModel();
            for (const auto& coin: coins_list)
            {
                if (coin.ticker == "All")
                {
                    continue;
                }
                create_address_entries(QString::fromStdString(coin.ticker));
            }
            for (const auto& coin_type: coins_type_list)
            {
                if (coin_type == "UTXO")
                {
                    continue;
                }
                create_address_entries(coin_type);
            }
            endResetModel();
        }
    }

    void
    addressbook_contact_model::clear()
    {
        // Clears categories.
        m_categories.clear();
    
        // Clears address entries.
        beginResetModel();
        m_address_entries.clear();
        endResetModel();
    }
} // namespace atomic_dex