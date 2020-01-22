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

#include "atomic.dex.qt.bindings.hpp"

namespace atomic_dex
{
    atomic_dex::qt_coins_model::qt_coins_model(QObject* pParent) noexcept : QAbstractListModel(pParent) {

    }

    qt_coin_config::qt_coin_config(QObject* parent) : QObject(parent) {}

    int
    qt_coins_model::rowCount(const QModelIndex&) const
    {
        return m_items.size();
    }

    QVariant
    qt_coins_model::data(const QModelIndex& index, int) const
    {
        QObject* item = m_items.at(index.row());
        return QVariant::fromValue(item);
    }

    void
    qt_coins_model::insert(QObject* item)
    {
        beginInsertRows(QModelIndex(), 0, 0);
        m_items.push_front(item);
        endInsertRows();
    }

    void
    qt_coins_model::remove(QObject* item)
    {
        for (int i = 0; i < m_items.size(); ++i)
        {
            if (m_items.at(i) == item)
            {
                beginRemoveRows(QModelIndex(), i, i);
                m_items.remove(i);
                endRemoveRows();
                break;
            }
        }
    }

    QHash<int, QByteArray>
    qt_coins_model::roleNames() const
    {
        QHash<int, QByteArray> roles;
        roles[Qt::UserRole + 1] = "item";
        return roles;
    }
} // namespace atomic_dex