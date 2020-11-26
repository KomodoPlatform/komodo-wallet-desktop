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

//! Qt
#include <QJsonArray>
#include <QJsonDocument>

//! Project headers
#include "atomicdex/models/qt.addressbook.model.hpp"
#include "atomicdex/utilities/qt.utilities.hpp"

//! Constructors
namespace atomic_dex
{
    addressbook_model::addressbook_model(ag::ecs::system_manager& system_registry, QObject* parent) noexcept :
        QAbstractListModel(parent),
        m_addressbook_manager(system_registry.get_system<addressbook_manager>()),
        m_addressbook_proxy(new addressbook_proxy_model(this))
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("addressbook model created");
        m_addressbook_proxy->setSourceModel(this);
        m_addressbook_proxy->setSortRole(SubModelRole);
        m_addressbook_proxy->setDynamicSortFilter(true);
        m_addressbook_proxy->sort(0);
    }
    
    addressbook_model::~addressbook_model() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("addressbook model destroyed");
    }
}

//! QAbstractListModel implementation
namespace atomic_dex
{
    int
    atomic_dex::addressbook_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return m_contact_models.count();
    }
    
    QVariant
    atomic_dex::addressbook_model::data(const QModelIndex& index, int role) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()))
        {
            return {};
        }

        switch (static_cast<AddressBookRoles>(role))
        {
        case SubModelRole:
            return QVariant::fromValue(m_contact_models.at(index.row()));
        default:
            return {};
        }
    }
    
    bool
    atomic_dex::addressbook_model::insertRows(int position, int rows, const QModelIndex& parent)
    {
        spdlog::trace("(addressbook_model::insertRows) inserting {} contact(s) at position {}", rows, position);
        beginInsertRows(parent, position, position + rows - 1);
        for (int row = 0; row < rows; ++row)
        {
            auto* contact_model = new addressbook_contact_model(m_addressbook_manager, this);
            auto  contact_name  = m_addressbook_manager.at(m_addressbook_manager.nb_contacts() - 1 + row).at("name").get<std::string>();
            auto  contact_categ =
                nlohmann_json_array_to_qt_json_array(m_addressbook_manager.at(m_addressbook_manager.nb_contacts() - 1 + row).at("categories"));
            
            contact_model->set_name(QString::fromStdString(contact_name));
            contact_model->set_categories(qt_variant_list_to_qt_string_list(contact_categ.toVariantList()));
            m_contact_models.insert(position, contact_model);
        }
        endInsertRows();
        return true;
    }

    bool
    atomic_dex::addressbook_model::removeRows(int position, int rows, const QModelIndex& parent)
    {
        spdlog::trace("(addressbook_model::removeRows) removing {} elements at position {}", rows, position);
        beginRemoveRows(parent, position, position + rows - 1);
        for (int row = 0; row < rows; ++row)
        {
            delete m_contact_models.at(position);
            m_contact_models.removeAt(position);
        }
        endRemoveRows();
        return true;
    }
    
    QHash<int, QByteArray>
    atomic_dex::addressbook_model::roleNames() const
    {
        return {
            {SubModelRole, "contacts"}
        };
    }
}

//! QML API
namespace atomic_dex
{
    addressbook_proxy_model* addressbook_model::get_addressbook_proxy_mdl() const noexcept
    {
        return m_addressbook_proxy;
    }
}

//! Other member functions
namespace atomic_dex
{
    void addressbook_model::populate()
    {
        beginInsertRows(QModelIndex(), 0, m_addressbook_manager.nb_contacts() - 1);
        for (auto& contact : m_addressbook_manager.get_contacts())
        {
            auto* contact_model = new addressbook_contact_model(m_addressbook_manager, this);
            auto  contact_name  = contact.at("name").get<std::string>();
            auto  contact_categ = vector_std_string_to_qt_string_list(contact.at("categories"));
    
            contact_model->set_name(QString::fromStdString(contact_name));
            contact_model->set_categories(contact_categ);
            m_contact_models.push_back(contact_model);
        }
        endInsertRows();
    }
    
    void addressbook_model::remove_contact(int row, const QString& name)
    {
        spdlog::debug("(addressbook_model::remove_contact) removing {} contact at row {}", name.toStdString(), row);
        for (auto* it = m_contact_models.begin(); it != m_contact_models.end(); ++it)
        {
            if ((*it)->get_name() == name)
            {
                m_addressbook_manager.remove_contact(name.toStdString());
                m_addressbook_manager.save_configuration();
                beginRemoveRows(QModelIndex(), row, row);
                delete *it;
                m_contact_models.erase(it);
                endRemoveRows();
                return;
            }
        }
        spdlog::error("(addressbook_model::remove_contact) Cannot remove contact with name {} since it does not exist", name.toStdString());
    }
    
    void addressbook_model::remove_all_contacts()
    {
        spdlog::debug("(addressbook_model::remove_all_contacts) removing every contact");
        m_addressbook_manager.remove_all_contacts();
        m_addressbook_manager.save_configuration();
        beginRemoveRows(QModelIndex(), 0, rowCount());
        for (auto& contact_model : m_contact_models)
        {
            delete contact_model;
        }
        m_contact_models.clear();
        endRemoveRows();
    }

    bool addressbook_model::add_contact(const QString& name)
    {
        spdlog::trace("(addressbook_model::add_contact) adding {} contact", name.toStdString());
        if (m_addressbook_manager.has_contact(name.toStdString()))
        {
            spdlog::error("(addressbook_model::add_contact) cannot add {} contact because it already exists", name.toStdString());
            return false;
        }
        
        m_addressbook_manager.add_contact(name.toStdString());
        m_addressbook_manager.save_configuration();
        insertRow(rowCount());
        return true;
    }

    void addressbook_model::clear()
    {
        removeRows(0, rowCount());
    }
} // namespace atomic_dex
