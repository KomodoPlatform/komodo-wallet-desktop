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

#include <QAbstractListModel>

#include "atomic.dex.mm2.api.hpp"

namespace atomic_dex
{
    class orderbook_model final : public QAbstractListModel
    {
        Q_OBJECT
        Q_PROPERTY(int length READ get_length NOTIFY lengthChanged)
      public:
        enum class kind
        {
            asks,
            bids
        };

        enum OrderbookRoles
        {
            PriceRole,
            QuantityRole,
            TotalRole
        };

        orderbook_model(t_orderbook_answer& orderbook, kind orderbook_kind, QObject* parent = nullptr);
        ~orderbook_model() noexcept final;

        [[nodiscard]] int                    rowCount(const QModelIndex& parent = QModelIndex()) const final;
        [[nodiscard]] QVariant               data(const QModelIndex& index, int role) const final;
        [[nodiscard]] QHash<int, QByteArray> roleNames() const final;

        void              reset_orderbook(t_orderbook_answer& orderbook) noexcept;
        [[nodiscard]] int get_length() const noexcept;
      signals:
        void lengthChanged();

      private:
        kind                m_current_orderbook_kind{kind::asks};
        t_orderbook_answer& m_model_data;
    };

} // namespace atomic_dex