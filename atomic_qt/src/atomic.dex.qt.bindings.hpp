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

//!
#include "atomic.dex.mm2.hpp"

namespace atomic_dex
{
    struct qt_send_answer : QObject
    {
        Q_OBJECT
      public:
        explicit qt_send_answer(QObject* parent = nullptr);
        bool m_has_error;
        QString m_error_message;

        Q_PROPERTY(bool has_error READ get_error CONSTANT MEMBER m_has_error)
        Q_PROPERTY(QString error_message READ get_error_message CONSTANT MEMBER m_error_message)

        [[nodiscard]] bool get_error() const noexcept
        {
            return m_has_error;
        }

        [[nodiscard]] QString get_error_message() const noexcept
        {
            return m_error_message;
        }
    };

    struct qt_transactions : QObject
    {
        Q_OBJECT
      public:
        explicit qt_transactions(QObject* parent = nullptr);
        bool    m_received;
        QString m_amount;
        QString m_amount_fiat;
        QString m_date;

        Q_PROPERTY(bool received READ get_received CONSTANT MEMBER m_received)
        Q_PROPERTY(QString amount READ get_amount CONSTANT MEMBER m_amount)
        Q_PROPERTY(QString amount_fiat READ get_amount_fiat CONSTANT MEMBER m_amount_fiat)
        Q_PROPERTY(QString date READ get_date CONSTANT MEMBER m_date)

        [[nodiscard]] bool get_received() const noexcept
        {
            return m_received;
        }

        [[nodiscard]] QString
        get_amount() const noexcept
        {
            return m_amount;
        }

        [[nodiscard]] QString
        get_amount_fiat() const noexcept
        {
            return m_amount_fiat;
        }

        [[nodiscard]] QString
        get_date() const noexcept
        {
            return m_date;
        }
    };

    struct qt_coin_config : QObject
    {
        Q_OBJECT
      public:
        explicit qt_coin_config(QObject* parent = nullptr);
        QString m_ticker;
        QString m_name;
        bool    m_active;

        Q_PROPERTY(bool active READ get_active CONSTANT MEMBER m_active)
        Q_PROPERTY(QString ticker READ get_ticker CONSTANT MEMBER m_ticker)
        Q_PROPERTY(QString name READ get_name CONSTANT MEMBER m_name)

        [[nodiscard]] bool get_active() const noexcept
        {
            return m_active;
        }

        [[nodiscard]] QString
        get_ticker() const noexcept
        {
            return m_ticker;
        }

        [[nodiscard]] QString
        get_name() const noexcept
        {
            return m_name;
        }
    };

    inline QObject*
    to_qt_binding(tx_infos&& tx, QObject* parent)
    {
        auto* obj          = new qt_transactions(parent);
        obj->m_amount      = QString::fromStdString(tx.total_amount);
        obj->m_received    = !tx.am_i_sender;
        obj->m_date        = QString::fromStdString(tx.date);
        obj->m_amount_fiat = "0";
        return obj;
    }

    QObjectList inline to_qt_binding(t_transactions&& transactions, QObject* parent)
    {
        QObjectList out;
        out.reserve(transactions.size());
        for (auto&& tx: transactions) { out.append(to_qt_binding(std::move(tx), parent)); }
        return out;
    }

    inline QObject*
    to_qt_binding(t_coins::value_type&& coin, QObject* parent)
    {
        auto* obj     = new qt_coin_config(parent);
        obj->m_ticker = QString::fromStdString(coin.ticker);
        obj->m_name   = QString::fromStdString(coin.name);
        obj->m_active = coin.active;
        return obj;
    }

    QObjectList inline to_qt_binding(t_coins&& coins, QObject* parent)
    {
        QObjectList out;
        out.reserve(coins.size());
        for (auto&& coin: coins) { out.append(to_qt_binding(std::move(coin), parent)); }
        return out;
    }

    inline QObject*
    to_qt_binding(t_withdraw_answer&& answer, QObject* parent)
    {
        auto* obj = new qt_send_answer(parent);
        obj->m_has_error = answer.error.has_value();
        obj->m_error_message = answer.error.has_value() ? QString::fromStdString(answer.error.value()) : "";
        return obj;
    }
} // namespace atomic_dex