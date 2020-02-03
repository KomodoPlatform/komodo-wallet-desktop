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
    struct qt_my_order_contents : QObject
    {
        Q_OBJECT
      public:
        explicit qt_my_order_contents(QObject* parent = nullptr);
        QString m_order_id;
        QString m_date;
        QString m_base;
        QString m_rel;
        bool    m_cancellable;
        QString m_available_amount;
        QString m_price;

        Q_PROPERTY(QString price READ get_price CONSTANT MEMBER m_price)
        Q_PROPERTY(QString date READ get_date CONSTANT MEMBER m_date)
        Q_PROPERTY(QString base READ get_base CONSTANT MEMBER m_base)

        [[nodiscard]] QString get_base() const noexcept
        {
            return m_base;
        }

        [[nodiscard]] QString
        get_price() const noexcept
        {
            return m_price;
        }

        [[nodiscard]] QString
        get_date() const noexcept
        {
            return m_date;
        }
    };

    struct qt_my_orders : QObject
    {
        Q_OBJECT
      public:
        explicit qt_my_orders(QObject* parent = nullptr);

        QObjectList m_taker_orders;
        QObjectList m_maker_orders;
    };

    struct qt_ordercontent : QObject
    {
        Q_OBJECT
      public:
        explicit qt_ordercontent(QObject* parent = nullptr);
        QString m_price;
        QString m_maxvolume;

        Q_PROPERTY(QString price READ get_price CONSTANT MEMBER m_price)
        Q_PROPERTY(QString maxvolume READ get_maxvolume CONSTANT MEMBER m_maxvolume)

        [[nodiscard]] QString get_price() const noexcept
        {
            return m_price;
        }

        [[nodiscard]] QString
        get_maxvolume() const noexcept
        {
            return m_maxvolume;
        }
    };

    struct qt_orderbook : QObject
    {
        Q_OBJECT
      public:
        explicit qt_orderbook(QObject* parent = nullptr);
        QObjectList m_bids;
        QObjectList m_asks;
        QString     m_base;
        QString     m_rel;

        Q_PROPERTY(QString rel READ get_rel CONSTANT MEMBER m_rel)
        Q_PROPERTY(QString base READ get_base CONSTANT MEMBER m_base)
        Q_PROPERTY(QObjectList bids READ get_bids CONSTANT MEMBER m_bids)
        Q_PROPERTY(QObjectList asks READ get_asks CONSTANT MEMBER m_asks)

        [[nodiscard]] QObjectList get_bids() const noexcept
        {
            return m_bids;
        }

        [[nodiscard]] QObjectList
        get_asks() const noexcept
        {
            return m_asks;
        }

        [[nodiscard]] QString
        get_rel() const noexcept
        {
            return m_rel;
        }

        [[nodiscard]] QString
        get_base() const noexcept
        {
            return m_base;
        }
    };

    struct qt_send_answer : QObject
    {
        Q_OBJECT
      public:
        explicit qt_send_answer(QObject* parent = nullptr);
        bool    m_has_error;
        QString m_error_message;
        QString m_tx_hex;
        QString m_human_date;
        QString m_fees;
        QString m_explorer_url;

        Q_PROPERTY(bool has_error READ get_error CONSTANT MEMBER m_has_error)
        Q_PROPERTY(QString error_message READ get_error_message CONSTANT MEMBER m_error_message)
        Q_PROPERTY(QString tx_hex READ get_tx_hex CONSTANT MEMBER m_tx_hex)
        Q_PROPERTY(QString date READ get_date CONSTANT MEMBER m_human_date)
        Q_PROPERTY(QString fees READ get_fees CONSTANT MEMBER m_fees)
        Q_PROPERTY(QString explorer_url READ get_explorer_url CONSTANT MEMBER m_explorer_url)

        [[nodiscard]] QString get_explorer_url() const noexcept
        {
            return m_explorer_url;
        }

        [[nodiscard]] bool
        get_error() const noexcept
        {
            return m_has_error;
        }

        [[nodiscard]] QString
        get_fees() const noexcept
        {
            return m_fees;
        }

        [[nodiscard]] QString
        get_date() const noexcept
        {
            return m_human_date;
        }

        [[nodiscard]] QString
        get_error_message() const noexcept
        {
            return m_error_message;
        }

        [[nodiscard]] QString
        get_tx_hex() const noexcept
        {
            return m_tx_hex;
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
        auto* obj       = new qt_transactions(parent);
        obj->m_amount   = QString::fromStdString(tx.my_balance_change);
        obj->m_received = !tx.am_i_sender;
        if (tx.am_i_sender)
        {
            obj->m_amount = obj->m_amount.right(1);
        }
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
    to_qt_binding(t_withdraw_answer&& answer, QObject* parent, QString explorer_url)
    {
        auto* obj            = new qt_send_answer(parent);
        obj->m_has_error     = answer.error.has_value();
        obj->m_error_message = QString::fromStdString(answer.error.value_or(""));
        obj->m_tx_hex        = answer.result.has_value() ? QString::fromStdString(answer.result.value().tx_hex) : "";
        obj->m_human_date    = answer.result.has_value() ? QString::fromStdString(answer.result.value().timestamp_as_date) : "";
        if (answer.result.has_value())
        {
            auto& current = answer.result.value();
            auto  fees =
                current.fee_details.normal_fees.has_value() ? current.fee_details.normal_fees.value().amount : current.fee_details.erc_fees.value().total_fee;
            obj->m_fees         = answer.result.has_value() ? QString::fromStdString(fees) : "";
            obj->m_explorer_url = std::move(explorer_url);
        }
        return obj;
    }

    inline QObject*
    to_qt_binding(t_orderbook_answer&& answer, QObject* parent)
    {
        auto* obj   = new qt_orderbook(parent);
        obj->m_rel  = QString::fromStdString(answer.rel);
        obj->m_base = QString::fromStdString(answer.base);
        obj->m_bids.reserve(answer.bids.size());
        for (auto&& bid: answer.bids)
        {
            auto* q_bid        = new qt_ordercontent(parent);
            q_bid->m_maxvolume = QString::fromStdString(bid.maxvolume);
            q_bid->m_price     = QString::fromStdString(bid.price);
        }

        for (auto&& ask: answer.asks)
        {
            auto* q_ask        = new qt_ordercontent(parent);
            q_ask->m_maxvolume = QString::fromStdString(ask.maxvolume);
            q_ask->m_price     = QString::fromStdString(ask.price);
        }
        return obj;
    }

    inline QObject*
    to_qt_binding(t_my_orders_answer&& answer, QObject* parent)
    {
        auto* obj = new qt_my_orders(parent);

        auto functor = [&parent, &obj](auto&& collection, bool is_taker) {
            for (auto&& cur_taker: collection)
            {
                auto* qt_cur_order   = new qt_my_order_contents(parent);
                qt_cur_order->m_rel  = QString::fromStdString(cur_taker.second.rel);
                qt_cur_order->m_base = QString::fromStdString(cur_taker.second.base);
                qt_cur_order->m_date = QString::fromStdString(cur_taker.second.human_timestamp);
                if (is_taker)
                {
                    obj->m_taker_orders.append(qt_cur_order);
                }
                else
                {
                    obj->m_maker_orders.append(qt_cur_order);
                }
            }
        };

        functor(answer.taker_orders, true);
        functor(answer.maker_orders, false);
        return obj;
    }
} // namespace atomic_dex