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

//! QT Headers
#include <QObject>

//! Portfolio
#include "atomic.dex.qt.portfolio.model.hpp"
#include "atomic.dex.qt.portfolio.proxy.filter.model.hpp"

namespace atomic_dex
{
    class market_pairs final : public QObject
    {
        //! Q_OBJECT Definition
        Q_OBJECT

        //! QT Properties
        Q_PROPERTY(QString left_selected_coin READ get_left_selected_coin WRITE set_left_selected_coin NOTIFY leftSelectedCoinChanged)
        Q_PROPERTY(QString right_selected_coin READ get_right_selected_coin WRITE set_right_selected_coin NOTIFY rightSelectedCoinChanged)
        Q_PROPERTY(portfolio_proxy_model* left_selection_box READ get_left_selection_box NOTIFY leftSelectionBoxChanged)
        Q_PROPERTY(portfolio_proxy_model* right_selection_box READ get_right_selection_box NOTIFY rightSelectionBoxChanged)

        QString                m_left_selected_coin;
        QString                m_right_selected_coin;
        portfolio_proxy_model* m_left_selection_box;
        portfolio_proxy_model* m_right_selection_box;


      public:
        //! Constructor / Destructor
        market_pairs(portfolio_model* portfolio_mdl, QObject* parent = nullptr);
        ~market_pairs() noexcept final;

        //! Properties Getter/Setter
        [[nodiscard]] QString                get_left_selected_coin() const noexcept;
        [[nodiscard]] QString                get_right_selected_coin() const noexcept;
        [[nodiscard]] portfolio_proxy_model* get_left_selection_box() const noexcept;
        [[nodiscard]] portfolio_proxy_model* get_right_selection_box() const noexcept;
        void                                 set_left_selected_coin(QString left_coin) noexcept;
        void                                 set_right_selected_coin(QString right_coin) noexcept;
        void                                 reset();

      signals:
        void leftSelectedCoinChanged();
        void rightSelectedCoinChanged();
        void leftSelectionBoxChanged();
        void rightSelectionBoxChanged();
    };
} // namespace atomic_dex