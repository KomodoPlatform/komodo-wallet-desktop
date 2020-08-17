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

#include <QQmlEngine>

//!
#include "atomic.dex.qt.portfolio.page.hpp"

namespace atomic_dex
{
    portfolio_page::portfolio_page(entt::registry& registry, ag::ecs::system_manager& system_manager, entt::dispatcher& dispatcher, QObject* parent) :
        QObject(parent), system(registry), m_system_manager(system_manager), m_portfolio_mdl(new portfolio_model(system_manager, dispatcher, nullptr))
    {
        emit portfolioChanged();
    }

    portfolio_model*
    portfolio_page::get_portfolio() const noexcept
    {
        return m_portfolio_mdl;
    }

    void
    portfolio_page::update() noexcept
    {
    }

    portfolio_page::~portfolio_page() noexcept { delete m_portfolio_mdl; }
} // namespace atomic_dex