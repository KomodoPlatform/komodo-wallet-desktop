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

#include "atomic.dex.qt.bindings.hpp"

namespace atomic_dex
{
    qt_coin_config::qt_coin_config(QObject* parent) : QObject(parent) {}
    qt_send_answer::qt_send_answer(QObject* parent) : QObject(parent) {}
    qt_transactions::qt_transactions(QObject* parent) : QObject(parent) {}
} // namespace atomic_dex