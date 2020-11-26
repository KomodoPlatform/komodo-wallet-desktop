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


//! Constructors.
namespace atomic_dex
{
    addressbook_contact_model::addressbook_contact_model(addressbook_manager& addrbook_manager, QObject* parent) :
        QAbstractListModel(parent), m_addressbook_manager(addrbook_manager)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("addressbook contact model created");
    }
    
    addressbook_contact_model::~addressbook_contact_model() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("addressbook contact model destroyed");
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
    
        const auto& wallets_info = m_addressbook_manager.get_contact(m_name.toStdString()).at("wallets_info");
        switch (role)
        {
        case ContactRoles::CategoriesRole:
            return get_categories();
        case ContactRoles::TypeRole:
            return QString::fromStdString(wallets_info.at(index.row()).at("type").get<std::string>());
        default:
            return {};
        }
    }
    
    bool addressbook_contact_model::setData(const QModelIndex& index, const QVariant& value, int role)
    {
        if (!hasIndex(index.row(), index.column(), index.parent()) || !value.isValid())
        {
            return false;
        }
    
        auto& wallet_info = m_addressbook_manager.at(index.row());
        switch (role)
        {
        case TypeRole:
            if (value.toString().toStdString() != wallet_info.at("type").get<std::string>())
            {
                spdlog::trace("changing contact {} ticker {} to {}",
                              this->m_name.toStdString(), wallet_info.at("type").get<std::string>(), value.toString().toStdString());
            }
            break;
        //case AddressesRole:
//            if (value.toString() != wallet_info.addresses)
//            {
//                wallet_info.addresses = value;
//                spdlog::trace("changing contact {} ticker {} to address {}", this->m_name.toStdString(), item.type.toStdString(), item.address.toStdString());
//                m_addressbook_manager.update_contact_address(this->m_name, item.type, item.address);
//                m_addressbook_manager.update_configuration();
//            }
            break;
        default:
            return false;
        }
    
        emit dataChanged(index, index, {role});
        return true;
    }
    
    int addressbook_contact_model::rowCount(const QModelIndex& parent) const
    {
        return m_addressbook_manager.get_wallets_info(m_name.toStdString()).size();
    }
    
    bool addressbook_contact_model::insertRows(int position, int rows, const QModelIndex& parent)
    {
        spdlog::trace("(contact_model::insertRows) inserting {} element(s) at position {}", rows, position);
        beginInsertRows(QModelIndex(), position, position + rows - 1);
        for (int row = 0; row < rows; ++row)
        {
        //    m_wallets_info.insert(position, );
        }
        endInsertRows();
        //emit addressesChanged();
        return true;
    }
    
    bool addressbook_contact_model::removeRows(int position, int rows, const QModelIndex& parent)
    {
        spdlog::trace("(contact_model::removeRows) removing {} element(s) at position {}", rows, position);
        beginRemoveRows(QModelIndex(), position, position + rows - 1);
    
        for (int row = 0; row < rows; ++row)
        {
           // auto contact_contents = this->m_addresses.at(position);
           // this->m_wallet_manager.remove_address_entry(this->m_name, contact_contents.type);
            //this->m_wallet_manager.update_wallet_cfg();
            //this->m_addresses.removeAt(position);
        }
    
        endRemoveRows();
        //emit addressesChanged();
        return true;
    }
    
    QHash<int, QByteArray> addressbook_contact_model::roleNames() const
    {
        return {
            {CategoriesRole, "categories"},
            {TypeRole, "type"},
            {AddressesRole, "addresses"}
        };
    }
}

//! QML API implementation
namespace atomic_dex
{
    const QString& addressbook_contact_model::get_name() const noexcept
    {
        return m_name;
    }
    
    void addressbook_contact_model::set_name(const QString& name) noexcept
    {
        if (name != m_name)
        {
            if (!m_name.isEmpty())
            {
                m_addressbook_manager.change_contact_name(m_name.toStdString(), name.toStdString());
                m_addressbook_manager.save_configuration();
            }
            m_name = name;
            emit nameChanged();
        }
    }
    
    const QStringList& addressbook_contact_model::get_categories() const noexcept
    {
        return m_categories;
    }
    
    void addressbook_contact_model::set_categories(QStringList categories) noexcept
    {
        m_categories = std::move(categories);
        emit categoriesChanged();
    }
    
    bool addressbook_contact_model::add_category(const QString& category) noexcept
    {
        spdlog::debug("(addressbook_contact_model::add_category) Adding {} category to {}", category.toStdString(), m_name.toStdString());
        if (m_addressbook_manager.has_category(m_name.toStdString(), category.toStdString()))
        {
            spdlog::debug("(addressbook_contact_model::add_category) Contact already has {} category", category.toStdString());
            return false;
        }
        m_addressbook_manager.add_contact_category(m_name.toStdString(), category.toStdString());
        m_categories.append(category);
        emit categoriesChanged();
        return true;
    }
    
    void addressbook_contact_model::remove_category(const QString& category) noexcept
    {
        spdlog::debug("(addressbook_contact_model::remove_category) Removing {} category for {}", category.toStdString(), m_name.toStdString());
        m_categories.removeOne(category);
        emit categoriesChanged();
    }
    
    QVariantList addressbook_contact_model::get_wallets_info() noexcept
    {
        QVariantList out;
        out.reserve(m_wallets_info.size());
        for (auto&& wallet_info : m_wallets_info)
        {
            nlohmann::json j{{"type", wallet_info.type.toStdString()}};
            for (auto it = wallet_info.addresses.begin(); it != wallet_info.addresses.end(); ++it)
            {
                j["addresses"][it.key().toStdString()] = it.value().toStdString();
            }
            QJsonDocument  q_json = QJsonDocument::fromJson(QString::fromStdString(j.dump()).toUtf8());
            out.push_back(q_json.toVariant());
        }
    }
    
    void addressbook_contact_model::set_wallets_info(QList<wallet_info> wallets_info)
    {
        m_wallets_info = std::move(wallets_info);
        emit walletsInfoChanged();
    }
}