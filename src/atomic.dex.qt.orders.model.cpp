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

//! Project
#include "atomic.dex.qt.orders.model.hpp"
#include "atomic.dex.mm2.hpp"

namespace atomic_dex
{
    orders_model::orders_model(ag::ecs::system_manager& system_manager, QObject* parent) noexcept : QAbstractListModel(parent), m_system_manager(system_manager)
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("orders model created");
    }

    orders_model::~orders_model() noexcept
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("orders model destroyed");
    }

    int
    orders_model::rowCount([[maybe_unused]] const QModelIndex& parent) const
    {
        return this->m_model_data.count();
    }


    bool
    orders_model::setData(const QModelIndex& index, const QVariant& value, int role)
    {
        if (!hasIndex(index.row(), index.column(), index.parent()) || !value.isValid())
        {
            return false;
        }

        order_data& item = m_model_data[index.row()];
        switch (static_cast<OrdersRoles>(role))
        {
        case BaseCoinRole:
            item.base_coin = value.toString();
            break;
        case RelCoinRole:
            item.rel_coin = value.toString();
            break;
        case BaseCoinAmountRole:
            item.base_amount = value.toString();
            break;
        case RelCoinAmountRole:
            item.rel_amount = value.toString();
            break;
        case OrderTypeRole:
            item.order_type = value.toString();
            break;
        case HumanDateRole:
            item.human_date = value.toString();
            break;
        case UnixTimestampRole:
            item.unix_timestamp = value.toInt();
            break;
        case OrderIdRole:
            item.order_id = value.toString();
            break;
        case OrderStatusRole:
            item.order_status = value.toString();
            break;
        case MakerPaymentSpentIdRole:
            item.maker_payment_spent_id = value.toString();
            break;
        case TakerPaymentSentIdRole:
            item.taker_payment_sent_id = value.toString();
            break;
        }

        emit dataChanged(index, index, {role});
    }

    QVariant
    orders_model::data(const QModelIndex& index, int role) const
    {
        if (!hasIndex(index.row(), index.column(), index.parent()))
        {
            return {};
        }

        const order_data& item = m_model_data.at(index.row());
        switch (static_cast<OrdersRoles>(role))
        {
        case BaseCoinRole:
            return item.base_coin;
        case RelCoinRole:
            return item.rel_coin;
        case BaseCoinAmountRole:
            return item.base_amount;
        case RelCoinAmountRole:
            return item.rel_amount;
        case OrderTypeRole:
            return item.order_type;
        case HumanDateRole:
            return item.human_date;
        case UnixTimestampRole:
            return item.unix_timestamp;
        case OrderIdRole:
            return item.order_id;
        case OrderStatusRole:
            return item.order_status;
        case MakerPaymentSpentIdRole:
            return item.maker_payment_spent_id;
        case TakerPaymentSentIdRole:
            return item.taker_payment_sent_id;
        }
        return {};
    }

    bool
    orders_model::removeRows(int position, int rows, [[maybe_unused]] const QModelIndex& parent)
    {
        spdlog::trace("(orders_model::removeRows) removing {} elements at position {}", rows, position);

        beginRemoveRows(QModelIndex(), position, position + rows - 1);
        for (int row = 0; row < rows; ++row)
        {
            this->m_model_data.removeAt(position);
            // emit lengthChanged();
        }
        endRemoveRows();

        return true;
    }

    void
    orders_model::initialize_order(const ::mm2::api::my_order_contents& contents) noexcept
    {
        spdlog::trace("inserting in model order id {}", contents.order_id);
        beginInsertRows(QModelIndex(), this->m_model_data.count(), this->m_model_data.count());
        order_data data{
            .base_coin      = QString::fromStdString(contents.base),
            .rel_coin       = QString::fromStdString(contents.rel),
            .base_amount    = QString::fromStdString(contents.base_amount),
            .rel_amount     = QString::fromStdString(contents.rel_amount),
            .order_type     = QString::fromStdString(contents.order_type),
            .human_date     = QString::fromStdString(contents.human_timestamp),
            .unix_timestamp = static_cast<int>(contents.timestamp),
            .order_id       = QString::fromStdString(contents.order_id),
            .order_status   = "Matching",
        };
        this->m_orders_id_registry.emplace(contents.order_id);
        this->m_model_data.push_back(std::move(data));
        endInsertRows();
    }

    void
    orders_model::refresh_or_insert_orders() noexcept
    {
        const auto&     mm2_system = this->m_system_manager.get_system<mm2>();
        std::error_code ec;
        const auto      orders = mm2_system.get_raw_orders(ec);

        if (!ec)
        {
            auto functor_process_orders = [this](auto&& orders) {
                for (auto&& [key, value]: orders)
                {
                    if (this->m_orders_id_registry.find(value.order_id) != this->m_orders_id_registry.end())
                    {
                        //! Find update needed
                    }
                    else
                    {
                        //! Not found, insert and initialize.
                        this->initialize_order(value);
                    }
                }
            };

            functor_process_orders(orders.maker_orders);
            functor_process_orders(orders.taker_orders);

            //! Check for cleaning orders that are not present anymore
            for (auto&& id: this->m_orders_id_registry)
            {
                //! Check if the current id from the model registry is present in the orders collection

                //! Check in maker_orders
                bool res = std::none_of(begin(orders.maker_orders), end(orders.maker_orders), [id](auto&& contents) { return contents.second.order_id == id; });

                //! And compute with taker orders
                res &= std::none_of(begin(orders.taker_orders), end(orders.taker_orders), [id](auto&& contents) { return contents.second.order_id == id; });
                if (res)
                {
                    //! If it's the case retrieve the index of the row that match this id
                    auto res_list = this->match(index(0, 0), OrderIdRole, QString::fromStdString(id));
                    if (not res_list.empty())
                    {
                        //! And then delete it
                        this->removeRow(res_list.at(0).row());
                    }
                }
            }
        }
    }

    QHash<int, QByteArray>
    orders_model::roleNames() const
    {
        return {
            {BaseCoinRole, "base_coin"},
            {RelCoinRole, "rel_coin"},
            {BaseCoinAmountRole, "base_amount"},
            {RelCoinAmountRole, "rel_amount"},
            {OrderTypeRole, "type"},
            {HumanDateRole, "human_date"},
            {UnixTimestampRole, "timestamp"},
            {OrderIdRole, "order_id"},
            {OrderStatusRole, "order_status"},
            {MakerPaymentSpentIdRole, "maker_payment_spent_id"},
            {TakerPaymentSentIdRole, "taker_payment_sent_id"}};
    }
} // namespace atomic_dex