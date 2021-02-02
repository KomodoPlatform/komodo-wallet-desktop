/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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

// Project Headers
#include "qt.addressbook.contact.proxy.filter.model.hpp" //> addressbook_contact_proxy_filter_model
#include "qt.addressbook.contact.model.hpp"              //> addressbook_contact_model::AddressTypeRole/AddressKeyRole/AddressTypeAndKeyRole/AddressValueRole

namespace atomic_dex
{
    addressbook_contact_proxy_filter_model::addressbook_contact_proxy_filter_model(QObject* parent) : QSortFilterProxyModel(parent)
    {}
}

namespace atomic_dex
{
    bool addressbook_contact_proxy_filter_model::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const
    {
        QModelIndex idx = sourceModel()->index(source_row, 0, source_parent);
        assert(sourceModel()->hasIndex(idx.row(), 0));
    
        if (m_search_expression.isEmpty())
        {
            return true;
        }
        return idx.data(addressbook_contact_model::AddressTypeRole).toString().contains(m_search_expression, Qt::CaseInsensitive) ||
               idx.data(addressbook_contact_model::AddressKeyRole).toString().contains(m_search_expression, Qt::CaseInsensitive) ||
               idx.data(addressbook_contact_model::AddressTypeAndKeyRole).toString().contains(m_search_expression, Qt::CaseInsensitive) ||
               idx.data(addressbook_contact_model::AddressValueRole).toString().contains(m_search_expression, Qt::CaseInsensitive);
    }
    
    bool addressbook_contact_proxy_filter_model::lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const
    {
        QVariant left_data  = sourceModel()->data(source_left, addressbook_contact_model::AddressTypeAndKeyRole);
        QVariant right_data = sourceModel()->data(source_right, addressbook_contact_model::AddressTypeAndKeyRole);
        
        return left_data.toString().toLower() < right_data.toString().toLower();
    }
} // namespace atomic_dex

namespace atomic_dex
{
    const QString& addressbook_contact_proxy_filter_model::get_search_expression() const noexcept
    {
        return m_search_expression;
    }
    
    void addressbook_contact_proxy_filter_model::set_search_expression(QString value) noexcept
    {
        m_search_expression = std::move(value);
        invalidateFilter();
    }
}