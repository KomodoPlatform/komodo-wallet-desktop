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

    inline nlohmann::json
    to_qt_binding(t_coins::value_type&& coin)
    {
        nlohmann::json j{
            {"active", coin.active},
            {"is_claimable", coin.is_claimable},
            {"minimal_balance_for_asking_rewards", coin.minimal_claim_amount},
            {"ticker", coin.ticker},
            {"name", coin.name},
            {"type", coin.type},
            {"explorer_url", coin.explorer_url}};
        return j;
    }

    QVariantList inline to_qt_binding(t_coins&& coins)
    {
        QVariantList out;
        out.reserve(coins.size());
        nlohmann::json j = nlohmann::json::array();
        for (auto&& coin: coins) { j.push_back(to_qt_binding(std::move(coin))); }
        QJsonDocument q_json = QJsonDocument::fromJson(QString::fromStdString(j.dump()).toUtf8());
        out                  = q_json.array().toVariantList();
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
} // namespace atomic_dex