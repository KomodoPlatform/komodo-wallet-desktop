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

//! PCH
#include "atomicdex/pch.hpp"

//! Project Headers
#include "qt.market.pairs.hpp"

namespace atomic_dex
{
    market_pairs::market_pairs(ag::ecs::system_manager& system_manager, portfolio_model* portfolio_mdl, QObject* parent) :
        QObject(parent),
        m_left_selection_box(new portfolio_proxy_model(system_manager, nullptr)),
        m_right_selection_box(new portfolio_proxy_model(system_manager, nullptr)),
        m_multiple_selection_box(new portfolio_proxy_model(system_manager, nullptr)),
        m_multi_order_coins(new portfolio_proxy_model(system_manager, nullptr))
    {
        m_left_selection_box->is_a_market_selector(true);
        m_left_selection_box->setSourceModel(portfolio_mdl);
        m_left_selection_box->setDynamicSortFilter(true);
        m_left_selection_box->sort_by_currency_balance(false);
        this->m_left_selection_box->setFilterRole(portfolio_model::PortfolioRoles::NameAndTicker);
        this->m_left_selection_box->setFilterCaseSensitivity(Qt::CaseInsensitive);

        m_right_selection_box->is_a_market_selector(true);
        m_right_selection_box->setSourceModel(portfolio_mdl);
        m_right_selection_box->setDynamicSortFilter(true);
        m_right_selection_box->sort_by_currency_balance(false);
        this->m_right_selection_box->setFilterRole(portfolio_model::PortfolioRoles::NameAndTicker);
        this->m_right_selection_box->setFilterCaseSensitivity(Qt::CaseInsensitive);

        m_multiple_selection_box->is_a_market_selector(true);
        m_multiple_selection_box->setSourceModel(portfolio_mdl);
        m_multiple_selection_box->setDynamicSortFilter(true);
        m_multiple_selection_box->sort_by_name(true);
        this->m_multiple_selection_box->setFilterRole(portfolio_model::PortfolioRoles::NameAndTicker);
        this->m_multiple_selection_box->setFilterCaseSensitivity(Qt::CaseInsensitive);

        m_multi_order_coins->setSourceModel(portfolio_mdl);
        m_multi_order_coins->setDynamicSortFilter(true);
        m_multi_order_coins->sort_by_name(true);
        this->m_multi_order_coins->setFilterRole(portfolio_model::PortfolioRoles::MultiTickerCurrentlyEnabled);
        this->m_multiple_selection_box->setFilterCaseSensitivity(Qt::CaseInsensitive);
    }

    market_pairs::~market_pairs() 
    {
        delete m_left_selection_box;
        delete m_right_selection_box;
        delete m_multiple_selection_box;
    }
} // namespace atomic_dex

//! Properties implementation
namespace atomic_dex
{
    QString
    market_pairs::get_left_selected_coin() const 
    {
        return m_left_selected_coin;
    }

    QString
    market_pairs::get_right_selected_coin() const 
    {
        return m_right_selected_coin;
    }

    void
    market_pairs::set_left_selected_coin(QString left_coin) 
    {
        if (left_coin != m_left_selected_coin)
        {
            //! Set new one to true
            m_left_selected_coin = std::move(left_coin);
            m_multiple_selection_box->set_excluded_coin(m_left_selected_coin);
            emit leftSelectedCoinChanged();
        }
    }

    void
    market_pairs::set_right_selected_coin(QString right_coin) 
    {
        if (right_coin != m_right_selected_coin)
        {
            //! Set new one to true
            m_right_selected_coin = std::move(right_coin);
            emit rightSelectedCoinChanged();
        }
    }

    portfolio_proxy_model*
    market_pairs::get_left_selection_box() const 
    {
        return m_left_selection_box;
    }

    portfolio_proxy_model*
    market_pairs::get_right_selection_box() const 
    {
        return m_right_selection_box;
    }

    portfolio_proxy_model*
    market_pairs::get_multiple_selection_box() const 
    {
        return m_multiple_selection_box;
    }

    portfolio_proxy_model*
    market_pairs::get_multiple_order_coins() const 
    {
        return m_multi_order_coins;
    }

    void
    market_pairs::reset()
    {
        this->m_left_selected_coin  = "";
        this->m_right_selected_coin = "";
        this->m_base_selected_coin  = "";
        this->m_rel_selected_coin   = "";
        emit rightSelectedCoinChanged();
        emit leftSelectedCoinChanged();
        emit baseSelectedCoinChanged();
        emit relSelectedCoinChanged();
    }

    QString
    market_pairs::get_base_selected_coin() const 
    {
        return m_base_selected_coin;
    }

    QString
    market_pairs::get_rel_selected_coin() const 
    {
        return m_rel_selected_coin;
    }

    void
    market_pairs::set_base_selected_coin(QString base_coin) 
    {
        if (base_coin != m_base_selected_coin)
        {
            //! Set new one to true
            m_base_selected_coin = std::move(base_coin);
            emit baseSelectedCoinChanged();
        }
    }

    void
    market_pairs::set_rel_selected_coin(QString rel_coin) 
    {
        if (rel_coin != m_rel_selected_coin)
        {
            //! Set new one to true
            m_rel_selected_coin = std::move(rel_coin);
            emit relSelectedCoinChanged();
        }
    }
} // namespace atomic_dex

//! public API
namespace atomic_dex
{
} // namespace atomic_dex
