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

#include "atomic.dex.qt.orderbook.hpp"

namespace atomic_dex
{
    qt_orderbook_wrapper::qt_orderbook_wrapper(ag::ecs::system_manager& system_manager, QObject* parent) :
        QObject(parent), m_system_manager(system_manager), m_asks(new orderbook_model( orderbook_model::kind::asks, this)),
        m_bids(new orderbook_model(orderbook_model::kind::bids, this))
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("orderbook wrapper object created");
    }

    qt_orderbook_wrapper::~qt_orderbook_wrapper() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("orderbook wrapper object destroyed");
    }

    atomic_dex::orderbook_model*
    atomic_dex::qt_orderbook_wrapper::get_asks() const noexcept
    {
        return m_asks;
    }

    orderbook_model*
    qt_orderbook_wrapper::get_bids() const noexcept
    {
        return m_bids;
    }

    void
    qt_orderbook_wrapper::refresh_orderbook(t_orderbook_answer answer)
    {
        spdlog::trace("refresh orderbook");
        this->m_asks->refresh_orderbook(answer);
        this->m_bids->refresh_orderbook(answer);
    }

    void
    qt_orderbook_wrapper::reset_orderbook(t_orderbook_answer answer)
    {
        spdlog::trace("full reset orderbook");
        this->m_asks->reset_orderbook(answer);
        this->m_bids->reset_orderbook(answer);
    }

    void
    qt_orderbook_wrapper::clear_orderbook()
    {
        this->m_asks->clear_orderbook();
        this->m_bids->clear_orderbook();
    }
} // namespace atomic_dex