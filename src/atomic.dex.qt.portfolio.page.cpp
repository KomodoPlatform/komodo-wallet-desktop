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

//! PCH
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.band.oracle.price.service.hpp"
#include "atomic.dex.qt.portfolio.page.hpp"

namespace atomic_dex
{
    portfolio_page::portfolio_page(entt::registry& registry, ag::ecs::system_manager& system_manager, entt::dispatcher& dispatcher, QObject* parent) :
        QObject(parent), system(registry), m_system_manager(system_manager), m_portfolio_mdl(new portfolio_model(system_manager, dispatcher, this))
    {
        emit portfolioChanged();
        this->dispatcher_.sink<band_oracle_refreshed>().connect<&portfolio_page::on_band_oracle_refreshed>(*this);
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

    portfolio_page::~portfolio_page() noexcept {}

    QStringList
    portfolio_page::get_oracle_price_supported_pairs() const noexcept
    {
        auto        result = m_system_manager.get_system<band_oracle_price_service>().supported_pair();
        QStringList out;
        out.reserve(result.size());
        for (auto&& cur: result) { out.push_back(QString::fromStdString(cur)); }
        return out;
    }

    QString
    portfolio_page::get_oracle_last_price_reference() const noexcept
    {
        return QString::fromStdString(m_system_manager.get_system<band_oracle_price_service>().last_oracle_reference());
    }

    void
    portfolio_page::on_band_oracle_refreshed(const band_oracle_refreshed&)
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        emit oraclePriceUpdated();
    }
} // namespace atomic_dex