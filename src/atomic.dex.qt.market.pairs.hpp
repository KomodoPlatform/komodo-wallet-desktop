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

namespace atomic_dex
{
    class market_pairs final : public QObject
    {
        //! Q_OBJECT Definition
        Q_OBJECT

        //! QT Properties
        Q_PROPERTY(QString left_selected_coin READ get_left_selected_coin WRITE set_left_selected_coin NOTIFY leftSelectedCoinChanged)
        Q_PROPERTY(QString right_selected_coin READ get_right_selected_coin WRITE set_right_selected_coin NOTIFY rightSelectedCoinChanged)

        QString m_left_selected_coin{"KMD"};
        QString m_right_selected_coin{"BTC"};

      public:
        //! Constructor / Destructor
        market_pairs(QObject* parent = nullptr);
        ~market_pairs() noexcept final;

        //! Properties Getter/Setter
        [[nodiscard]] QString get_left_selected_coin() const noexcept;
        [[nodiscard]] QString get_right_selected_coin() const noexcept;
        void                  set_left_selected_coin(QString left_coin) noexcept;
        void                  set_right_selected_coin(QString right_coin) noexcept;

      signals:
        void leftSelectedCoinChanged();
        void rightSelectedCoinChanged();
    };
} // namespace atomic_dex