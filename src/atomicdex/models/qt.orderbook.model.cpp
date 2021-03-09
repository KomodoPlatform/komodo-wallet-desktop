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

//! Project
#include "atomicdex/models/qt.orderbook.model.hpp"
#include "atomicdex/pages/qt.trading.page.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

namespace
{
    template <typename TValue, typename TModel>
    void
    update_value(int role, const TValue& value, const QModelIndex& idx, TModel& model)
    {
        if (value != model.data(idx, role))
        {
            model.setData(idx, value, role);
        }
    }
} // namespace

namespace atomic_dex
{
    orderbook_model::orderbook_model(kind orderbook_kind, ag::ecs::system_manager& system_mgr, QObject* parent) :
        QAbstractListModel(parent), m_current_orderbook_kind(orderbook_kind), m_system_mgr(system_mgr), m_model_proxy(new orderbook_proxy_model(this))
    {
        this->m_model_proxy->setSourceModel(this);
        this->m_model_proxy->setDynamicSortFilter(true);
        this->m_model_proxy->setSortRole(PriceRole);
        if (this->m_current_orderbook_kind == kind::asks)
        {
            this->m_model_proxy->sort(0, Qt::AscendingOrder);
        }
        else
        {
            this->m_model_proxy->sort(0, Qt::DescendingOrder);
        }
    }

    int
    orderbook_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return m_model_data.size();
    }

    QVariant
    orderbook_model::data(const QModelIndex& index, int role) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()) || this->rowCount() == 0)
        {
            return {};
        }

        switch (static_cast<OrderbookRoles>(role))
        {
        case PriceRole:
            return QString::fromStdString(m_model_data.at(index.row()).price);
        case CoinRole:
            return QString::fromStdString(m_model_data.at(index.row()).coin);
        case PriceDenomRole:
            return QString::fromStdString(m_model_data.at(index.row()).price_fraction_denom);
        case PriceNumerRole:
            return QString::fromStdString(m_model_data.at(index.row()).price_fraction_numer);
        case QuantityRole:
            return QString::fromStdString(m_model_data.at(index.row()).maxvolume);
        case TotalRole:
            return QString::fromStdString(m_model_data.at(index.row()).total);
        case UUIDRole:
            return QString::fromStdString(m_model_data.at(index.row()).uuid);
        case IsMineRole:
            return m_model_data.at(index.row()).is_mine;
        case PercentDepthRole:
            return QString::fromStdString(m_model_data.at(index.row()).depth_percent);
        case QuantityDenomRole:
            return QString::fromStdString(m_model_data.at(index.row()).max_volume_fraction_denom);
        case QuantityNumerRole:
            return QString::fromStdString(m_model_data.at(index.row()).max_volume_fraction_numer);
        case MinVolumeRole:
            return QString::fromStdString(m_model_data.at(index.row()).min_volume);
        case EnoughFundsToPayMinVolume:
        {
            bool        i_have_enough_funds = true;
            const auto& order_model_data    = m_model_data.at(index.row());
            const auto  min_volume_f        = t_float_50(order_model_data.min_volume);
            const auto& trading_pg          = m_system_mgr.get_system<trading_page>();
            auto        taker_vol_std       = trading_pg.get_orderbook_wrapper()->get_base_max_taker_vol().toJsonObject()["decimal"].toString().toStdString();
            if (taker_vol_std.empty())
            {
                taker_vol_std = "0";
            }
            t_float_50 mm2_min_trade_vol(trading_pg.get_mm2_min_trade_vol().toStdString());
            t_float_50 taker_vol(taker_vol_std);
            i_have_enough_funds = min_volume_f > 0 && taker_vol > min_volume_f;
            return i_have_enough_funds;
        }
        }
    }

    bool
    orderbook_model::setData(const QModelIndex& index, const QVariant& value, int role)
    {
        if (!hasIndex(index.row(), index.column(), index.parent()) || !value.isValid())
        {
            return false;
        }
        ::mm2::api::order_contents& order = m_model_data.at(index.row());
        switch (static_cast<OrderbookRoles>(role))
        {
        case PriceRole:
            order.price = value.toString().toStdString();
            break;
        case PriceDenomRole:
            order.price_fraction_denom = value.toString().toStdString();
            break;
        case PriceNumerRole:
            order.price_fraction_denom = value.toString().toStdString();
            break;
        case IsMineRole:
            order.is_mine = value.toBool();
            break;
        case QuantityRole:
            order.maxvolume = value.toString().toStdString();
            break;
        case TotalRole:
            order.total = value.toString().toStdString();
            break;
        case UUIDRole:
            order.uuid = value.toString().toStdString();
            break;
        case PercentDepthRole:
            order.depth_percent = value.toString().toStdString();
            break;
        case QuantityDenomRole:
            order.max_volume_fraction_denom = value.toString().toStdString();
            break;
        case QuantityNumerRole:
            order.max_volume_fraction_numer = value.toString().toStdString();
            break;
        case CoinRole:
            order.coin = value.toString().toStdString();
            break;
        case MinVolumeRole:
            order.min_volume = value.toString().toStdString();
            break;
        case EnoughFundsToPayMinVolume:
            break;
        }
        emit dataChanged(index, index, {role});
        return true;
    }

    QHash<int, QByteArray>
    orderbook_model::roleNames() const
    {
        return {
            {PriceRole, "price"},
            {CoinRole, "coin"},
            {QuantityRole, "quantity"},
            {TotalRole, "total"},
            {UUIDRole, "uuid"},
            {IsMineRole, "is_mine"},
            {PriceDenomRole, "price_denom"},
            {PriceNumerRole, "price_numer"},
            {QuantityDenomRole, "quantity_denom"},
            {QuantityNumerRole, "quantity_numer"},
            {PercentDepthRole, "depth"},
            {MinVolumeRole, "min_volume"},
            {EnoughFundsToPayMinVolume, "enough_funds_to_pay_min_volume"}};
    }

    void
    orderbook_model::reset_orderbook(const t_orders_contents& orderbook) noexcept
    {
        this->beginResetModel();
        m_model_data = orderbook;
        m_orders_id_registry.clear();
        for (auto&& order: m_model_data)
        {
            if (this->m_orders_id_registry.find(order.uuid) == m_orders_id_registry.end())
            {
                this->m_orders_id_registry.emplace(order.uuid);
            }
        }
        this->endResetModel();
        emit lengthChanged();
        assert(model_data.size() == m_orders_id_registry.size());
    }

    int
    orderbook_model::get_length() const noexcept
    {
        return rowCount();
    }


    void
    orderbook_model::initialize_order(const ::mm2::api::order_contents& order) noexcept
    {
        assert(m_model_data.size() == m_orders_id_registry.size());
        beginInsertRows(QModelIndex(), m_model_data.size(), m_model_data.size());
        m_model_data.push_back(order);
        this->m_orders_id_registry.emplace(order.uuid);
        endInsertRows();
        emit lengthChanged();
        assert(m_model_data.size() == m_orders_id_registry.size());
    }

    void
    orderbook_model::update_order(const ::mm2::api::order_contents& order) noexcept
    {
        if (const auto res = this->match(index(0, 0), UUIDRole, QString::fromStdString(order.uuid)); not res.isEmpty())
        {
            //! ID Found, update !
            const QModelIndex& idx = res.at(0);
            update_value(OrderbookRoles::PriceRole, QString::fromStdString(order.price), idx, *this);
            update_value(OrderbookRoles::PriceNumerRole, QString::fromStdString(order.price_fraction_numer), idx, *this);
            update_value(OrderbookRoles::PriceDenomRole, QString::fromStdString(order.price_fraction_denom), idx, *this);
            update_value(OrderbookRoles::IsMineRole, order.is_mine, idx, *this);
            update_value(OrderbookRoles::QuantityRole, QString::fromStdString(order.maxvolume), idx, *this);
            update_value(OrderbookRoles::TotalRole, QString::fromStdString(order.total), idx, *this);
            update_value(OrderbookRoles::PercentDepthRole, QString::fromStdString(order.depth_percent), idx, *this);
            update_value(OrderbookRoles::EnoughFundsToPayMinVolume, true, idx, *this);
        }
    }

    void
    orderbook_model::refresh_orderbook(const t_orders_contents& orderbook) noexcept
    {
        auto refresh_functor = [this](const std::vector<::mm2::api::order_contents>& contents) {
            for (auto&& current_order: contents)
            {
                if (this->m_orders_id_registry.find(current_order.uuid) != this->m_orders_id_registry.end())
                {
                    //! Update
                    this->update_order(current_order);
                }
                else
                {
                    //! Insertion
                    this->initialize_order(current_order);
                }
            }

            // Deletion
            std::unordered_set<std::string> to_remove;
            for (auto&& id: this->m_orders_id_registry)
            {
                bool res = std::none_of(begin(contents), end(contents), [id](auto&& contents) { return contents.uuid == id; });
                //! Need to remove the row
                if (res)
                {
                    auto res_list = this->match(index(0, 0), UUIDRole, QString::fromStdString(id));
                    if (not res_list.empty())
                    {
                        this->removeRow(res_list.at(0).row());
                        to_remove.emplace(id);
                    }
                }
            }
            for (auto&& cur_to_remove: to_remove) { m_orders_id_registry.erase(cur_to_remove); }
        };
        refresh_functor(orderbook);
    }

    bool
    orderbook_model::removeRows(int position, int rows, [[maybe_unused]] const QModelIndex& parent)
    {
        beginRemoveRows(QModelIndex(), position, position + rows - 1);
        for (int row = 0; row < rows; ++row)
        {
            m_model_data.erase(m_model_data.begin() + position);
            emit lengthChanged();
        }
        endRemoveRows();

        return true;
    }

    void
    orderbook_model::clear_orderbook() noexcept
    {
        this->beginResetModel();
        m_model_data = t_orders_contents{};
        m_orders_id_registry.clear();
        this->endResetModel();
        emit lengthChanged();
    }

    orderbook_proxy_model*
    orderbook_model::get_orderbook_proxy() const noexcept
    {
        return m_model_proxy;
    }
} // namespace atomic_dex
