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

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QObject>

//! PCH Headers
#include "atomic.dex.pch.hpp"

//!
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"

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
        QString m_base_amount;
        QString m_rel_amount;
        QString m_price;
        int     m_timestamp;
        bool    m_am_i_maker;

        Q_PROPERTY(QString price READ get_price CONSTANT MEMBER m_price)
        Q_PROPERTY(QString date READ get_date CONSTANT MEMBER m_date)
        Q_PROPERTY(int timestamp READ get_timestamp CONSTANT MEMBER m_timestamp)
        Q_PROPERTY(QString base READ get_base CONSTANT MEMBER m_base)
        Q_PROPERTY(QString rel READ get_rel CONSTANT MEMBER m_rel)
        Q_PROPERTY(bool cancellable READ is_cancellable CONSTANT MEMBER m_cancellable)
        Q_PROPERTY(bool am_i_maker READ is_maker CONSTANT MEMBER m_am_i_maker)
        Q_PROPERTY(QString base_amount READ get_base_amount CONSTANT MEMBER m_base_amount)
        Q_PROPERTY(QString rel_amount READ get_rel_amount CONSTANT MEMBER m_rel_amount)
        Q_PROPERTY(QString uuid READ get_uuid CONSTANT MEMBER m_order_id)

        [[nodiscard]] int get_timestamp() const noexcept
        {
            return m_timestamp;
        }

        [[nodiscard]] QString
        get_uuid() const noexcept
        {
            return m_order_id;
        }

        [[nodiscard]] bool
        is_cancellable() const noexcept
        {
            return m_cancellable;
        }

        [[nodiscard]] bool
        is_maker() const noexcept
        {
            return m_am_i_maker;
        }

        [[nodiscard]] QString
        get_base_amount() const noexcept
        {
            return m_base_amount;
        }

        [[nodiscard]] QString
        get_rel_amount() const noexcept
        {
            return m_rel_amount;
        }

        [[nodiscard]] QString
        get_base() const noexcept
        {
            return m_base;
        }

        [[nodiscard]] QString
        get_rel() const noexcept
        {
            return m_rel;
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

    using qt_my_order_contents_ptr = qt_my_order_contents*;

    struct qt_my_orders : QObject
    {
        Q_OBJECT
      public:
        explicit qt_my_orders(QObject* parent = nullptr);
        QObjectList m_taker_orders;
        QObjectList m_maker_orders;

        Q_PROPERTY(QList<QObject*> taker_orders READ get_taker_orders CONSTANT MEMBER m_taker_orders)
        Q_PROPERTY(QList<QObject*> maker_orders READ get_maker_orders CONSTANT MEMBER m_maker_orders)

        [[nodiscard]] QObjectList get_taker_orders() const noexcept
        {
            return m_taker_orders;
        }

        [[nodiscard]] QObjectList
        get_maker_orders() const noexcept
        {
            return m_maker_orders;
        }
    };

    using qt_my_orders_ptr = qt_my_orders*;

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
        Q_PROPERTY(QList<QObject*> bids READ get_bids CONSTANT MEMBER m_bids)
        Q_PROPERTY(QList<QObject*> asks READ get_asks CONSTANT MEMBER m_asks)

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
        QString m_balance_change;
        QString m_fees;
        QString m_total_amount;
        QString m_explorer_url;

        Q_PROPERTY(bool has_error READ get_error CONSTANT MEMBER m_has_error)
        Q_PROPERTY(QString error_message READ get_error_message CONSTANT MEMBER m_error_message)
        Q_PROPERTY(QString tx_hex READ get_tx_hex CONSTANT MEMBER m_tx_hex)
        Q_PROPERTY(QString date READ get_date CONSTANT MEMBER m_human_date)
        Q_PROPERTY(QString total_amount READ get_total_amount CONSTANT MEMBER m_total_amount)
        Q_PROPERTY(QString balance_change READ get_balance_change CONSTANT MEMBER m_balance_change)
        Q_PROPERTY(QString fees READ get_fees CONSTANT MEMBER m_fees)
        Q_PROPERTY(QString explorer_url READ get_explorer_url CONSTANT MEMBER m_explorer_url)

        [[nodiscard]] QString get_total_amount() const noexcept
        {
            return m_total_amount;
        }

        [[nodiscard]] QString
        get_balance_change() const noexcept
        {
            return m_balance_change;
        }

        [[nodiscard]] QString
        get_explorer_url() const noexcept
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

    struct qt_coin_config : QObject
    {
        Q_OBJECT
      public:
        explicit qt_coin_config(QObject* parent = nullptr);
        QString m_ticker;
        QString m_explorer_url;
        QString m_name;
        QString m_type;
        bool    m_active;
        bool    m_claimable;
        QString m_minimal_balance_for_asking_rewards;

        Q_PROPERTY(bool active READ get_active CONSTANT MEMBER m_active)
        Q_PROPERTY(bool is_claimable READ is_claimable_coin CONSTANT MEMBER m_claimable)
        Q_PROPERTY(QString minimal_balance_for_asking_rewards READ get_minimal_balance_for_asking_rewards CONSTANT MEMBER m_minimal_balance_for_asking_rewards)
        Q_PROPERTY(QString ticker READ get_ticker CONSTANT MEMBER m_ticker)
        Q_PROPERTY(QString name READ get_name CONSTANT MEMBER m_name)
        Q_PROPERTY(QString type READ get_type CONSTANT MEMBER m_type)
        Q_PROPERTY(QString explorer_url READ get_explorer_url CONSTANT MEMBER m_explorer_url)

        [[nodiscard]] QString get_type() const noexcept
        {
            return m_type;
        }

        [[nodiscard]] QString
        get_explorer_url() const noexcept
        {
            return m_explorer_url;
        }

        [[nodiscard]] bool
        is_claimable_coin() const noexcept
        {
            return m_claimable;
        }

        [[nodiscard]] bool
        get_active() const noexcept
        {
            return m_active;
        }

        [[nodiscard]] QString
        get_minimal_balance_for_asking_rewards() const noexcept
        {
            return m_minimal_balance_for_asking_rewards;
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

    inline nlohmann::json
    to_qt_binding(tx_infos&& tx, std::string fiat_amount)
    {
        nlohmann::json obj{
            {"amount", tx.my_balance_change},
            {"received", !tx.am_i_sender},
            {"date", tx.date},
            {"timestamp", tx.timestamp},
            {"amount_fiat", std::move(fiat_amount)},
            {"tx_hash", tx.tx_hash},
            {"fees", tx.fees},
            {"from", tx.from},
            {"to", tx.to},
            {"blockheight", tx.block_height},
            {"confirmations", tx.confirmations}};
        if (tx.am_i_sender)
        {
            obj["amount"] = tx.my_balance_change.substr(1);
        }
        return obj;
    }

    QVariantList inline to_qt_binding(t_transactions&& transactions, coinpaprika_provider& paprika, const std::string& fiat, const std::string& ticker)
    {
        QVariantList out;
        out.reserve(transactions.size());
        nlohmann::json j = nlohmann::json::array();
        for (auto&& tx: transactions)
        {
            std::error_code ec;
            auto            fiat_amount = paprika.get_price_as_currency_from_tx(fiat, ticker, tx, ec);
            j.push_back(to_qt_binding(std::move(tx), fiat_amount));
        }
        QJsonDocument q_json = QJsonDocument::fromJson(QString::fromStdString(j.dump()).toUtf8());
        out                  = q_json.array().toVariantList();
        return out;
    }

    inline QObject*
    to_qt_binding(t_coins::value_type&& coin, QObject* parent)
    {
        auto* obj                                 = new qt_coin_config(parent);
        obj->m_ticker                             = QString::fromStdString(coin.ticker);
        obj->m_name                               = QString::fromStdString(coin.name);
        obj->m_active                             = coin.active;
        obj->m_type                               = QString::fromStdString(coin.type);
        obj->m_claimable                          = coin.is_claimable;
        obj->m_explorer_url                       = QString::fromStdString(coin.explorer_url[0]);
        obj->m_minimal_balance_for_asking_rewards = QString::fromStdString(coin.minimal_claim_amount);
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
        auto* obj             = new qt_send_answer(parent);
        obj->m_has_error      = answer.error.has_value();
        obj->m_error_message  = QString::fromStdString(answer.error.value_or(""));
        obj->m_tx_hex         = answer.result.has_value() ? QString::fromStdString(answer.result.value().tx_hex) : "";
        obj->m_human_date     = answer.result.has_value() ? QString::fromStdString(answer.result.value().timestamp_as_date) : "";
        obj->m_balance_change = answer.result.has_value() ? QString::fromStdString(answer.result.value().my_balance_change) : "";
        obj->m_total_amount   = answer.result.has_value() ? QString::fromStdString(answer.result.value().total_amount) : "";
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
        obj->m_asks.reserve(answer.asks.size());
        for (auto&& bid: answer.bids)
        {
            auto* q_bid        = new qt_ordercontent(parent);
            q_bid->m_maxvolume = QString::fromStdString(bid.maxvolume);
            q_bid->m_price     = QString::fromStdString(bid.price);
            obj->m_bids.append(q_bid);
        }

        for (auto&& ask: answer.asks)
        {
            auto* q_ask        = new qt_ordercontent(parent);
            q_ask->m_maxvolume = QString::fromStdString(ask.maxvolume);
            q_ask->m_price     = QString::fromStdString(ask.price);
            obj->m_asks.append(q_ask);
        }
        return obj;
    }

    inline QObject*
    to_qt_binding(t_my_orders_answer&& answer, QObject* parent)
    {
        auto* obj = new qt_my_orders(parent);

        auto functor = [&parent, &obj](auto&& collection, bool is_taker) {
            for (auto&& cur_order: collection)
            {
                auto* qt_cur_order          = new qt_my_order_contents(parent);
                qt_cur_order->m_rel         = QString::fromStdString(cur_order.second.rel);
                qt_cur_order->m_base        = QString::fromStdString(cur_order.second.base);
                qt_cur_order->m_date        = QString::fromStdString(cur_order.second.human_timestamp);
                qt_cur_order->m_cancellable = cur_order.second.cancellable;
                qt_cur_order->m_base_amount = QString::fromStdString(cur_order.second.base_amount);
                qt_cur_order->m_rel_amount  = QString::fromStdString(cur_order.second.rel_amount);
                qt_cur_order->m_order_id    = QString::fromStdString(cur_order.second.order_id);
                qt_cur_order->m_am_i_maker  = cur_order.second.order_type == "maker";
                qt_cur_order->m_timestamp   = cur_order.second.timestamp;

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

Q_DECLARE_METATYPE(atomic_dex::qt_my_orders_ptr);
Q_DECLARE_METATYPE(atomic_dex::qt_my_order_contents_ptr);