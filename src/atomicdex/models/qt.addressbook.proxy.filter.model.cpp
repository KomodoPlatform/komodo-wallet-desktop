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

//! Project Headers
#include "atomicdex/models/qt.addressbook.model.hpp"
#include "atomicdex/models/qt.addressbook.proxy.filter.model.hpp"

//! Ctor
namespace atomic_dex
{
    addressbook_proxy_model::addressbook_proxy_model(QObject* parent) :
        QSortFilterProxyModel(parent)
    {}
}

//! QSortFilterProxyModel Functions
namespace atomic_dex
{
    bool
    addressbook_proxy_model::lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const
    {
        int      role       = sortRole();
        QVariant left_data  = sourceModel()->data(source_left, role);
        QVariant right_data = sourceModel()->data(source_right, role);
        
        switch (static_cast<addressbook_model::AddressBookRoles>(role))
        {
        case addressbook_model::SubModelRole:
        {
            auto* left_obj      = qvariant_cast<QObject*>(left_data);
            auto* left_contact  = qobject_cast<addressbook_contact_model*>(left_obj);
            auto* right_obj     = qvariant_cast<QObject*>(right_data);
            auto* right_contact = qobject_cast<addressbook_contact_model*>(right_obj);
            return left_contact->get_name().toLower() < right_contact->get_name().toLower();
        }
        default:
            SPDLOG_WARN("No sort behavior on role {}", role);
            break;
        }
        return false;
    }
    
    bool addressbook_proxy_model::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const
    {
        int role        = filterRole();
        QModelIndex idx = sourceModel()->index(source_row, 0, source_parent);
        assert(sourceModel()->hasIndex(idx.row(), 0));
        
        switch (static_cast<addressbook_model::AddressBookRoles>(role))
        {
        case addressbook_model::NameRoleAndCategoriesRole:
        {
            QStringList search_pattern = m_search_exp.split(' ', Qt::SplitBehaviorFlags::SkipEmptyParts);
            QString     data           = idx.data(addressbook_model::NameRoleAndCategoriesRole).toString();

            for (auto& word: search_pattern)
            {
                if (!data.contains(word, Qt::CaseInsensitive))
                {
                    return false;
                }
            }
        }
        default:
            SPDLOG_WARN("No filter behavior on role {}", role);
            break;
        }
        return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
    }
} // namespace atomic_dex

//! Getters/Setters
namespace atomic_dex
{
    const QString& addressbook_proxy_model::get_search_exp() const noexcept
    {
        return m_search_exp;
    }
    
    void addressbook_proxy_model::set_search_exp(QString expression) noexcept
    {
        m_search_exp = std::move(expression);
        invalidateFilter();
    }
}