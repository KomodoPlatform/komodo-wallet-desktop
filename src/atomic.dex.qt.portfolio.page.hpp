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

//! QT
#include <QObject>

//! Project headers
#include "atomic.dex.qt.portfolio.model.hpp"


namespace atomic_dex
{
    class portfolio_page final : public QObject, public ag::ecs::pre_update_system<portfolio_page>
    {
        //! Q_Object definition
        Q_OBJECT

        //! Properties
        Q_PROPERTY(portfolio_model* portfolio_mdl READ get_portfolio NOTIFY portfolioChanged)

        //! Private members fields
        ag::ecs::system_manager& m_system_manager;
        portfolio_model*         m_portfolio_mdl;

      public:
        //! Constructor
        explicit portfolio_page(entt::registry& registry, ag::ecs::system_manager& system_manager, entt::dispatcher& dispatcher, QObject* parent = nullptr);
        ~portfolio_page() noexcept final;

        //! Public override
        void update() noexcept final;

        [[nodiscard]] portfolio_model* get_portfolio() const noexcept;

      signals:
        void portfolioChanged();
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::portfolio_page))