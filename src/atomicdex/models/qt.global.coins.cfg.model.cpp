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

//! Project Headers
#include "atomicdex/models/qt.global.coins.cfg.model.hpp"
#include "atomicdex/utilities/qt.utilities.hpp"

//! Constructor
namespace atomic_dex
{
    global_coins_cfg_model::global_coins_cfg_model(QObject* parent) noexcept :
        QAbstractListModel(parent) /*, m_proxies[i](new global_coins_cfg_proxy_model(this))*/
    {
        m_proxies.reserve(CoinType::Size);

        for (int i = 0; i < CoinType::Size; ++i)
        {
            m_proxies[i] = new global_coins_cfg_proxy_model(this);
            m_proxies[i]->setSourceModel(this);
            m_proxies[i]->setDynamicSortFilter(true);
            m_proxies[i]->setFilterRole(CoinsRoles::TickerAndNameRole);
            m_proxies[i]->setFilterCaseSensitivity(Qt::CaseInsensitive);

            //! Initial State will be enableable
            m_proxies[i]->filter_by_enableable();
            m_proxies[i]->filter_by_type(static_cast<::CoinType>(i));
        }
    }
} // namespace atomic_dex

//! Override
namespace atomic_dex
{
    QVariant
    global_coins_cfg_model::data(const QModelIndex& index, int role) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()))
        {
            return {};
        }

        const coin_config& item = m_model_data.at(index.row());
        switch (static_cast<CoinsRoles>(role))
        {
        case TickerRole:
            return QString::fromStdString(item.ticker);
        case GuiTickerRole:
            return QString::fromStdString(item.gui_ticker);
        case NameRole:
            return QString::fromStdString(item.name);
        case IsClaimable:
            return item.is_claimable;
        case CurrentlyEnabled:
            return item.currently_enabled;
        case Active:
            return item.active;
        case IsCustomCoin:
            return item.is_custom_coin;
        case Type:
            return QString::fromStdString(item.type);
        case CoinType:
            return static_cast<int>(item.coin_type);
        case TickerAndNameRole:
            return QString::fromStdString(item.ticker) + QString::fromStdString(item.name); ///! ETHethereum
        case Checked:
            return item.checked;
        }
        return {};
    }

    bool
    global_coins_cfg_model::setData(const QModelIndex& index, const QVariant& value, int role)
    {
        coin_config& item = m_model_data[index.row()];
        switch (static_cast<CoinsRoles>(role))
        {
        case CurrentlyEnabled:
            item.currently_enabled = value.toBool();
            break;
        case Active:
            item.active = value.toBool();
            break;
        case Checked:
            item.checked = value.toBool();
            break;
        default:
            return false;
        }

        emit dataChanged(index, index, {role});
        return true;
    }

    int
    global_coins_cfg_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return m_model_data.size();
    }

    QHash<int, QByteArray>
    global_coins_cfg_model::roleNames() const
    {
        return {{TickerRole, "ticker"}, {GuiTickerRole, "gui_ticker"},    {NameRole, "name"}, {IsClaimable, "is_claimable"}, {CurrentlyEnabled, "enabled"},
                {Active, "active"},     {IsCustomCoin, "is_custom_coin"}, {Type, "type"}};
    }
} // namespace atomic_dex

//! CPP API
namespace atomic_dex
{
    void
    global_coins_cfg_model::initialize_model(std::vector<coin_config> cfg) noexcept
    {
        SPDLOG_INFO("Initializing global coin cfg model with size {}", cfg.size());
        beginResetModel();
        m_model_data = std::move(cfg);
        endResetModel();
    }

    template <typename TArray>
    void
    global_coins_cfg_model::update_status(const TArray& tickers, bool status) noexcept
    {
        auto update_functor = [this, status](QModelIndexList res, const QString& ticker) {
            SPDLOG_INFO("Changing Active/CurrentlyEnabled status to {} for ticker {}", status, ticker.toStdString());
            const QModelIndex& idx = res.at(0);
            update_value(Active, status, idx, *this);
            update_value(CurrentlyEnabled, status, idx, *this);
        };

        for (auto&& ticker: tickers)
        {
            QString final_ticker = "";

            if constexpr (std::is_same_v<std::string, std::decay_t<decltype(ticker)>>)
            {
                final_ticker = QString::fromStdString(ticker);
            }
            else if constexpr (std::is_same_v<QString, std::decay_t<decltype(ticker)>>)
            {
                final_ticker = ticker;
            }

            if (const auto res = this->match(this->index(0, 0), TickerRole, final_ticker); not res.isEmpty())
            {
                update_functor(res, final_ticker);
            }
        }
    }

    template void global_coins_cfg_model::update_status(const QStringList&, bool);
    template void global_coins_cfg_model::update_status(const std::vector<std::string>&, bool);
} // namespace atomic_dex

//! Properties
namespace atomic_dex
{
    cfg_proxy_model_list
    global_coins_cfg_model::get_global_coins_cfg_proxy_mdl() const noexcept
    {
        return m_proxies;
    }
} // namespace atomic_dex