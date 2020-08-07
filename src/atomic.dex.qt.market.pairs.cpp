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

#include "atomic.dex.qt.market.pairs.hpp"

namespace atomic_dex
{
    market_pairs::market_pairs(QObject* parent) : QObject(parent) {}
    market_pairs::~market_pairs() noexcept {}
} // namespace atomic_dex

//! Properties implementation
namespace atomic_dex
{
    QString
    market_pairs::get_left_selected_coin() const noexcept
    {
        return m_left_selected_coin;
    }

    QString
    market_pairs::get_right_selected_coin() const noexcept
    {
        return m_right_selected_coin;
    }

    void
    market_pairs::set_left_selected_coin(QString left_coin) noexcept
    {
        if (left_coin != m_left_selected_coin)
        {
            m_left_selected_coin = std::move(left_coin);
            emit leftSelectedCoinChanged();
        }
    }

    void
    market_pairs::set_right_selected_coin(QString right_coin) noexcept
    {
        if (right_coin != m_right_selected_coin)
        {
            m_right_selected_coin = std::move(right_coin);
            emit rightSelectedCoinChanged();
        }
    }
} // namespace atomic_dex

//! public API
namespace atomic_dex
{
} // namespace atomic_dex