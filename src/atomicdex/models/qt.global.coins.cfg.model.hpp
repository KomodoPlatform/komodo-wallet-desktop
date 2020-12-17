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

//! Qt
#include <QAbstractListModel>

//! Deps
#include <entt/core/attribute.h>

//! Project Headers
#include "atomicdex/config/coins.cfg.hpp"
#include "atomicdex/models/qt.global.coins.cfg.proxy.filter.model.hpp"

namespace atomic_dex
{
    class ENTT_API global_coins_cfg_model final : public QAbstractListModel
    {
        //! Q_Object definition
        Q_OBJECT
        Q_PROPERTY(global_coins_cfg_proxy_model* global_coins_cfg_proxy_mdl READ get_global_coins_cfg_proxy_mdl NOTIFY globalCoinsCfgProxyChanged);

        std::vector<coin_config>      m_model_data;
        global_coins_cfg_proxy_model* m_model_data_proxy;

      signals:
        void globalCoinsCfgProxyChanged();

      public:
        //! Enums
        enum CoinsRoles
        {
            TickerRole = Qt::UserRole + 1,
            GuiTickerRole,
            NameRole,
            IsClaimable,
            CurrentlyEnabled,
            Active,
            IsCustomCoin,
            Type
        };
        Q_ENUM(CoinsRoles)

        //! Constructor / Destructor
        explicit global_coins_cfg_model(QObject* parent = nullptr) noexcept;
        ~global_coins_cfg_model() noexcept final = default;

        //! CPP API
        void initialize_model(std::vector<coin_config> cfg) noexcept;

        template <typename TArray>
        void update_status(const TArray& tickers, bool status) noexcept;

        //! Properties
        [[nodiscard]] global_coins_cfg_proxy_model* get_global_coins_cfg_proxy_mdl() const noexcept;

        //! Overrides
        [[nodiscard]] QVariant               data(const QModelIndex& index, int role) const final;
        bool                                 setData(const QModelIndex& index, const QVariant& value, int role) final;
        [[nodiscard]] int                    rowCount(const QModelIndex& parent) const final;
        [[nodiscard]] QHash<int, QByteArray> roleNames() const final;
    };
} // namespace atomic_dex