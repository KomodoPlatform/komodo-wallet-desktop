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
      public:
        explicit current_coin_info(QObject* pParent = nullptr) noexcept;
        QString get_ticker() const noexcept;
        void    set_ticker(QString ticker) noexcept;
      signals:
        void ticker_changed();

      public:
        QString  selected_coin_name;
        QObject* selected_coin_info;
    };

    struct application : public QObject, public ag::world::app
    {
        Q_OBJECT
        Q_PROPERTY(qt_coins_model* enabled_coins READ get_enabled_coins NOTIFY enabled_coins_changed)
        Q_PROPERTY(qt_coins_model* enableable_coins READ get_enableable_coins NOTIFY enableable_coins_changed)
        Q_PROPERTY(QObject* current_coin_info READ get_current_coin_info NOTIFY coin_info_changed)

      public:
        explicit application(QObject* pParent = nullptr) noexcept;

        mm2&                  get_mm2() noexcept;
        coinpaprika_provider& get_paprika() noexcept;
        entt::dispatcher&     get_dispatcher() noexcept;
        QObject*              get_current_coin_info() const noexcept;
        qt_coins_model*       get_enabled_coins() const noexcept;
        qt_coins_model*       get_enableable_coins() const noexcept;

        void launch();

        Q_INVOKABLE void    change_state(int visibility);
        Q_INVOKABLE QString get_mnemonic();
        Q_INVOKABLE bool    first_run();
        Q_INVOKABLE bool    login(const QString& password);
        Q_INVOKABLE bool    create(const QString& password, const QString& seed);

      signals:
        void enabled_coins_changed();
        void enableable_coins_changed();
        void coin_info_changed();

      private:
        void               tick();
        qt_coins_model*    m_enabled_coins;
        qt_coins_model*    m_enableable_coins;
        current_coin_info* m_coin_info;
    };
} // namespace atomic_dex
