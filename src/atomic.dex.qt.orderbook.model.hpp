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

#include <QAbstractTableModel>

namespace atomic_dex
{
    class orderbook_model final : public QAbstractTableModel
    {
      public:
        enum class kind
        {
            asks,
            bids
        };

        orderbook_model(kind orderbook_kind, QObject* parent = nullptr);
        ~orderbook_model() noexcept final;

        [[nodiscard]] int      rowCount(const QModelIndex& parent) const final;
        [[nodiscard]] int      columnCount(const QModelIndex& parent) const final;
        [[nodiscard]] QVariant data(const QModelIndex& index, int role) const final;

      private:
        kind m_current_orderbook_kind{kind::asks};
    };
} // namespace atomic_dex