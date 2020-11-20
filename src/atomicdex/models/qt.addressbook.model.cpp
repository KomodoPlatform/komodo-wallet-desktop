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
        this->m_addressbook_proxy->setSourceModel(this);
        this->m_addressbook_proxy->setSortRole(SubModelRole);
        this->m_addressbook_proxy->setDynamicSortFilter(true);
        this->m_addressbook_proxy->sort(0);
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
        return m_contact_models.size();
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
    atomic_dex::addressbook_model::removeRows(int position, int rows, [[maybe_unused]] const QModelIndex& parent)
    {
        spdlog::trace("(addressbook_model::removeRows) removing {} elements at position {}", rows, position);
        beginRemoveRows(QModelIndex(), position, position + rows - 1);
        for (int row = 0; row < rows; ++row)
        {
            auto* contact_model = m_contact_models.at(position);
            
            if (not contact_model->get_name().isEmpty())
            {
                m_addressbook_manager.remove_contact(contact_model->get_name().toStdString());
                m_addressbook_manager.save_configuration();
            }
            delete contact_model;
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

//! Other member functions
namespace atomic_dex
{
    void addressbook_model::init_from_manager()
    {
        for (std::size_t i = 0; i < m_addressbook_manager.get_contacts().size(); i++)
        {
            int   rows          = 1;
            auto  contact_name  = m_addressbook_manager.get_contacts().at(i).at("name").get<std::string>();
            auto* contact_model = new addressbook_contact_model(m_addressbook_manager, QString::fromStdString(contact_name), nullptr);
    
            beginInsertRows(QModelIndex(), m_contact_models.count(), m_contact_models.count());
            for (int row = 0; row < rows; ++row)
            {
                m_contact_models.push_back(contact_model);
            }
            endInsertRows();
        }
    }

    void
    addressbook_model::remove_at(int position)
    {
        auto* contact_model = m_contact_models.at(position);
        
        m_addressbook_manager.remove_contact(contact_model->get_name().toStdString());
        removeRow(position);
    }
    
    void
    addressbook_model::add_contact_entry(const QString& name)
    {
        if (m_addressbook_manager.has_contact(name.toStdString()))
        {
            return;
        }
        
        auto* contact_model = new addressbook_contact_model(m_addressbook_manager, name, nullptr);
        
        m_addressbook_manager.add_contact(name.toStdString());
        beginInsertRows(QModelIndex(), m_contact_models.count(), m_contact_models.count());
        m_contact_models.push_back(contact_model);
        endInsertRows();
    }

    addressbook_proxy_model*
    addressbook_model::get_addressbook_proxy_mdl() const noexcept
    {
        return m_addressbook_proxy;
    }
} // namespace atomic_dex
