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

//! QT
#include <QObject>     //! QObject
#include <QObjectList> //! QObjectList
#include <QString>     //! QString

//! PCH
#include "atomic.dex.pch.hpp"

namespace atomic_dex
{
    struct current_coin_info : QObject
    {
        Q_OBJECT
        Q_PROPERTY(bool is_claimable READ is_claimable_ticker WRITE set_claimable NOTIFY claimable_changed)
        Q_PROPERTY(QString claimable_amount READ get_claimable_amount WRITE set_claimable_amount NOTIFY claimable_amount_changed)
        Q_PROPERTY(QString ticker READ get_ticker WRITE set_ticker NOTIFY ticker_changed)
        Q_PROPERTY(QString balance READ get_balance WRITE set_balance NOTIFY balance_changed)
        Q_PROPERTY(QString address READ get_address WRITE set_address NOTIFY address_changed)
        Q_PROPERTY(QString fiat_amount READ get_fiat_amount WRITE set_fiat_amount NOTIFY fiat_amount_changed);
        Q_PROPERTY(QString explorer_url READ get_explorer_url WRITE set_explorer_url NOTIFY explorer_url_changed);
        Q_PROPERTY(QList<QObject*> transactions READ get_transactions WRITE set_transactions NOTIFY transactionsChanged)
        Q_PROPERTY(QString tx_state READ get_tx_state WRITE set_tx_state NOTIFY tx_state_changed);
        Q_PROPERTY(unsigned int tx_current_block READ get_tx_current_block WRITE set_tx_current_block NOTIFY tx_current_block_changed);

      public:
        explicit current_coin_info(entt::dispatcher& dispatcher, QObject* pParent = nullptr) noexcept;
        [[nodiscard]] bool         is_claimable_ticker() const noexcept;
        void                       set_claimable(bool claimable) noexcept;
        [[nodiscard]] QString      get_claimable_amount() const noexcept;
        void                       set_claimable_amount(QString amount) noexcept;
        [[nodiscard]] QString      get_tx_state() const noexcept;
        void                       set_tx_state(QString state) noexcept;
        [[nodiscard]] unsigned int get_tx_current_block() const noexcept;
        void                       set_tx_current_block(unsigned int block) noexcept;
        [[nodiscard]] QObjectList  get_transactions() const noexcept;
        void                       set_transactions(QObjectList transactions) noexcept;
        [[nodiscard]] QString      get_ticker() const noexcept;
        void                       set_ticker(QString ticker) noexcept;
        [[nodiscard]] QString      get_address() const noexcept;
        void                       set_address(QString address) noexcept;
        [[nodiscard]] QString      get_balance() const noexcept;
        void                       set_balance(QString balance) noexcept;
        [[nodiscard]] QString      get_explorer_url() const noexcept;
        void                       set_explorer_url(QString url) noexcept;
        [[nodiscard]] QString      get_fiat_amount() const noexcept;
        void                       set_fiat_amount(QString fiat_amount) noexcept;
      signals:
        void ticker_changed();
        void tx_state_changed();
        void tx_current_block_changed();
        void balance_changed();
        void address_changed();
        void claimable_changed();
        void claimable_amount_changed();
        void explorer_url_changed();
        void fiat_amount_changed();
        void transactionsChanged();

      public:
        QString           selected_coin_name;
        QString           selected_coin_balance;
        QString           selected_coin_address;
        QString           selected_coin_fiat_amount{"0"};
        QString           selected_coin_url;
        QString           selected_coin_state;
        unsigned int      selected_coin_block;
        QObjectList       selected_coin_transactions;
        bool              selected_coin_is_claimable;
        QString           selected_coin_claimable_amount{"0"};
        entt::dispatcher& m_dispatcher;
    };
} // namespace atomic_dex