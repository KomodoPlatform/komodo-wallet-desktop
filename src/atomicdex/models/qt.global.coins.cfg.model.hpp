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

//! STD
#include <array>

//! Qt
#include <QAbstractListModel>

//! Boost
#include <boost/container/flat_map.hpp>

//! Deps
#include <entt/core/attribute.h>

//! Project Headers
#include "atomicdex/config/coins.cfg.hpp"
#include "atomicdex/models/qt.global.coins.cfg.proxy.filter.model.hpp"

namespace atomic_dex
{
    using cfg_proxy_model_list = QList<global_coins_cfg_proxy_model*>;

    class ENTT_API global_coins_cfg_model final : public QAbstractListModel
    {
        //! Q_Object definition
        Q_OBJECT

        std::vector<coin_config>                             m_model_data;    ///< contains all the data
        boost::container::flat_map<std::string, coin_config> m_enabled_coins; ///< enabled_coins

        std::array<global_coins_cfg_proxy_model*, ::CoinType::Size> m_proxies;

        int m_checked_nb{0};

        Q_PROPERTY(global_coins_cfg_proxy_model* qrc20_proxy READ get_qrc20_proxy NOTIFY qrc20_proxyChanged)
        Q_PROPERTY(global_coins_cfg_proxy_model* erc20_proxy READ get_erc20_proxy NOTIFY erc20_proxyChanged)
        Q_PROPERTY(global_coins_cfg_proxy_model* smartchains_proxy READ get_smartchains_proxy NOTIFY smartchains_proxyChanged)
        Q_PROPERTY(global_coins_cfg_proxy_model* utxo_proxy READ get_utxo_proxy NOTIFY utxo_proxyChanged)
        Q_PROPERTY(global_coins_cfg_proxy_model* all_disabled_proxy READ get_all_disabled_proxy NOTIFY all_disabled_proxyChanged)
        Q_PROPERTY(global_coins_cfg_proxy_model* all_proxy READ get_all_proxy NOTIFY all_proxyChanged)

        Q_PROPERTY(int length READ get_length NOTIFY lengthChanged)
        Q_PROPERTY(int checked_nb READ get_checked_nb WRITE set_checked_nb NOTIFY checked_nbChanged)

      signals:
        void globalCoinsCfgProxyChanged();

      public:
        //! Enums
        enum CoinsRoles
        {
            TickerRole = Qt::UserRole + 1,
            GuiTickerRole,
            NameRole,
            TickerAndNameRole,
            IsClaimable,
            CurrentlyEnabled,
            Active,
            IsCustomCoin,
            Type,
            CoinType,
            Checked
        };
        Q_ENUM(CoinsRoles)

        //! Constructor / Destructor
        explicit global_coins_cfg_model(QObject* parent = nullptr) noexcept;
        ~global_coins_cfg_model() noexcept final = default;

        //! CPP API
        void                                                               initialize_model(std::vector<coin_config> cfg) noexcept;
        const std::vector<coin_config>&                                    get_model_data() const noexcept;
        [[nodiscard]] coin_config                                          get_coin_info(const std::string& ticker) const noexcept;
        [[nodiscard]] boost::container::flat_map<std::string, coin_config> get_enabled_coins() const noexcept;

        template <typename TArray>
        void update_status(const TArray& tickers, bool status) noexcept;

        //! Overrides
        [[nodiscard]] QVariant               data(const QModelIndex& index, int role) const final;
        bool                                 setData(const QModelIndex& index, const QVariant& value, int role) final;
        [[nodiscard]] int                    rowCount(const QModelIndex& parent = QModelIndex()) const final;
        [[nodiscard]] QHash<int, QByteArray> roleNames() const final;

        //! QML API
        [[nodiscard]] Q_INVOKABLE QStringList get_checked_coins() const noexcept;
        [[nodiscard]] Q_INVOKABLE QVariant    get_coin_info(const QString& ticker) const noexcept;

        //! Properties
        [[nodiscard]] global_coins_cfg_proxy_model* get_qrc20_proxy() const noexcept;
        [[nodiscard]] global_coins_cfg_proxy_model* get_erc20_proxy() const noexcept;
        [[nodiscard]] global_coins_cfg_proxy_model* get_smartchains_proxy() const noexcept;
        [[nodiscard]] global_coins_cfg_proxy_model* get_utxo_proxy() const noexcept;
        [[nodiscard]] global_coins_cfg_proxy_model* get_all_disabled_proxy() const noexcept;
        [[nodiscard]] global_coins_cfg_proxy_model* get_all_proxy() const noexcept;

        [[nodiscard]] int get_length() const noexcept;

        [[nodiscard]] int get_checked_nb() const noexcept;
        void              set_checked_nb(int value) noexcept;

      signals:
        void qrc20_proxyChanged();
        void erc20_proxyChanged();
        void smartchains_proxyChanged();
        void utxo_proxyChanged();
        void all_disabled_proxyChanged();
        void all_proxyChanged();

        void lengthChanged();

        void checked_nbChanged();
    };
} // namespace atomic_dex