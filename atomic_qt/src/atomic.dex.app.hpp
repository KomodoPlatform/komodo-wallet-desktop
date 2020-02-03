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

#include <QObject>
#include <QStringList>
#include <QVariantMap>

//! PCH Headers
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"
#include "atomic.dex.qt.bindings.hpp"

namespace ag = antara::gaming;

namespace atomic_dex
{
    struct current_coin_info : QObject
    {
        Q_OBJECT
        Q_PROPERTY(QString ticker READ get_ticker WRITE set_ticker NOTIFY ticker_changed)
        Q_PROPERTY(QString balance READ get_balance WRITE set_balance NOTIFY balance_changed)
        Q_PROPERTY(QString address READ get_address WRITE set_address NOTIFY address_changed)
        Q_PROPERTY(QString fiat_amount READ get_fiat_amount WRITE set_fiat_amount NOTIFY fiat_amount_changed);
        Q_PROPERTY(QString explorer_url READ get_explorer_url WRITE set_explorer_url NOTIFY explorer_url_changed);
        Q_PROPERTY(QList<QObject*> transactions READ get_transactions WRITE set_transactions NOTIFY transactionsChanged)


      public:
        explicit current_coin_info(entt::dispatcher& dispatcher, QObject* pParent = nullptr) noexcept;
        QObjectList get_transactions() const noexcept;
        void        set_transactions(QObjectList transactions) noexcept;
        QString     get_ticker() const noexcept;
        void        set_ticker(QString ticker) noexcept;
        QString     get_address() const noexcept;
        void        set_address(QString address) noexcept;
        QString     get_balance() const noexcept;
        void        set_balance(QString balance) noexcept;
        QString     get_explorer_url() const noexcept;
        void        set_explorer_url(QString url) noexcept;
        QString     get_fiat_amount() const noexcept;
        void        set_fiat_amount(QString fiat_amount) noexcept;
      signals:
        void ticker_changed();
        void balance_changed();
        void address_changed();
        void explorer_url_changed();
        void fiat_amount_changed();
        void transactionsChanged();

      public:
        QString           selected_coin_name;
        QString           selected_coin_balance;
        QString           selected_coin_address;
        QString           selected_coin_fiat_amount{"0"};
        QString           selected_coin_url;
        QObjectList       selected_coin_transactions;
        entt::dispatcher& m_dispatcher;
    };

    struct application : public QObject, public ag::world::app
    {
        Q_OBJECT
        Q_PROPERTY(QList<QObject*> enabled_coins READ get_enabled_coins NOTIFY enabledCoinsChanged)
        Q_PROPERTY(QList<QObject*> enableable_coins READ get_enableable_coins NOTIFY enableableCoinsChanged)
        Q_PROPERTY(QObject* current_coin_info READ get_current_coin_info NOTIFY coinInfoChanged)
        Q_PROPERTY(QString fiat READ get_current_fiat WRITE set_current_fiat NOTIFY on_fiat_changed)
        Q_PROPERTY(QString initial_loading_status READ get_status WRITE set_status NOTIFY on_status_changed)

      private:
        void refresh_transactions(const mm2& mm2);
        void refresh_fiat_balance(const mm2& mm2, const coinpaprika_provider& paprika);

      public:
        explicit application(QObject* pParent = nullptr) noexcept;

        void                  on_enabled_coins_event(const enabled_coins_event&) noexcept;
        void                  on_change_ticker_event(const change_ticker_event&) noexcept;
        void                  on_tx_fetch_finished_event(const tx_fetch_finished&) noexcept;
        void                  on_coin_disabled_event(const coin_disabled&) noexcept;
        void                  on_mm2_initialized_event(const mm2_initialized&) noexcept;
        void                  on_mm2_started_event(const mm2_started&) noexcept;
        mm2&                  get_mm2() noexcept;
        const mm2&            get_mm2() const noexcept;
        coinpaprika_provider& get_paprika() noexcept;
        entt::dispatcher&     get_dispatcher() noexcept;
        QObject*              get_current_coin_info() const noexcept;
        QObjectList           get_enabled_coins() const noexcept;
        QObjectList           get_enableable_coins() const noexcept;
        QString               get_current_fiat() const noexcept;
        void                  set_current_fiat(QString current_fiat) noexcept;
        QString               get_status() const noexcept;
        void                  set_status(QString status) noexcept;
        void                  launch();

        Q_INVOKABLE QObject* prepare_send(const QString& address, const QString& amount, bool max = false);
        Q_INVOKABLE QString  send(const QString& tx_hex);
        Q_INVOKABLE void     change_state(int visibility);
        Q_INVOKABLE void     on_gui_enter_dex();
        Q_INVOKABLE void     on_gui_leave_dex();
        Q_INVOKABLE QString  get_mnemonic();
        Q_INVOKABLE bool     first_run();
        Q_INVOKABLE bool     login(const QString& password);
        Q_INVOKABLE bool     create(const QString& password, const QString& seed);
        Q_INVOKABLE bool     enable_coins(const QStringList& coins);
        Q_INVOKABLE QString  get_balance(const QString& coin);
        Q_INVOKABLE bool     place_buy_order(const QString& base, const QString& rel, const QString& price, const QString& volume);
        Q_INVOKABLE bool     place_sell_order(const QString& base, const QString& rel, const QString& price, const QString& volume);
        Q_INVOKABLE void     set_current_orderbook(const QString& base, const QString& rel);
        Q_INVOKABLE QObject*    get_orderbook();
        Q_INVOKABLE bool        do_i_have_enough_funds(const QString& ticker, const QString& amount) const;
        Q_INVOKABLE bool        disable_coins(const QStringList& coins);
        Q_INVOKABLE QVariantMap get_my_orders();


      signals:
        void enabledCoinsChanged();
        void enableableCoinsChanged();
        void coinInfoChanged();
        void on_fiat_changed();
        void on_status_changed();

      private:
        std::atomic_bool   m_refresh_enabled_coin_event{false};
        std::atomic_bool   m_refresh_current_ticker_infos{false};
        std::atomic_bool   m_refresh_transaction_only{false};
        QObjectList        m_enabled_coins;
        QObjectList        m_enableable_coins;
        QString            m_current_fiat{"USD"};
        QString            m_current_status{"None"};
        current_coin_info* m_coin_info;

      private:
        void tick();
        void refresh_address(mm2& mm2);
    };
} // namespace atomic_dex
