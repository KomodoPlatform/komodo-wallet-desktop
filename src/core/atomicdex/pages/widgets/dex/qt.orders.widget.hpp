/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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

//! Qt
#include <QObject>
#include <QStringList>

//! Deps
#include <antara/gaming/ecs/system.manager.hpp>

#include "atomicdex/models/qt.portfolio.model.hpp"
#include "qt.market.pairs.hpp"

namespace atomic_dex
{
    class qt_orders_widget final : public QObject
    {
        Q_OBJECT

        //! Private member fields
        ag::ecs::system_manager& m_system_mgr;

        //! Private member functions
        void common_cancel_all_orders(bool by_coin = false, const QString& ticker = "");

      public:
        qt_orders_widget(ag::ecs::system_manager& system_manager, QObject* parent = nullptr) ;
        ~qt_orders_widget()  final;

        //! QML_API
        Q_INVOKABLE void cancel_order(const QStringList& orders_id);
        Q_INVOKABLE void cancel_all_orders();
        Q_INVOKABLE void cancel_all_orders_by_ticker(const QString& ticker);
    };
} // namespace atomic_dex
