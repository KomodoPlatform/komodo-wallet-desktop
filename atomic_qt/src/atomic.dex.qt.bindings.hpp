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
    struct qt_coin_config : QObject
    {
        Q_OBJECT
      public:
        explicit qt_coin_config(QObject* parent = nullptr);
        QString m_ticker;
        QString m_name;

        Q_PROPERTY(QString ticker READ get_ticker CONSTANT MEMBER ticker)
        Q_PROPERTY(QString name READ get_name CONSTANT MEMBER name)

        QString
        get_ticker()
        {
            return m_ticker;
        }

        QString
        get_name()
        {
            return m_name;
        }
    };

    QObjectList inline to_qt_binding(t_coins&& coins, QObject* parent)
    {
        QObjectList out;
        out.reserve(coins.size());
        for (auto&& coin: coins)
        {
            auto* obj     = new qt_coin_config(parent);
            obj->m_ticker = QString::fromStdString(coin.ticker);
            obj->m_name   = QString::fromStdString(coin.name);
            out.append(obj);
        }
        return out;
    }
} // namespace atomic_dex