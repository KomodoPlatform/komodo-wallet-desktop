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

//! Utils
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
    orders_model::orders_model(ag::ecs::system_manager& system_manager, QObject* parent) noexcept :
        QAbstractListModel(parent), m_system_manager(system_manager), m_model_proxy(new orders_proxy_model(this))
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("orders model created");

        this->m_model_proxy->setSourceModel(this);
        this->m_model_proxy->setDynamicSortFilter(true);
        this->m_model_proxy->setSortRole(UnixTimestampRole);
        this->m_model_proxy->sort(0);
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
        case MakerPaymentIdRole:
            item.maker_payment_spent_id = value.toString();
            break;
        case TakerPaymentIdRole:
            item.taker_payment_sent_id = value.toString();
            break;
        case CancellableRole:
            item.is_cancellable = value.toBool();
            break;
        case IsMakerRole:
            item.is_maker = value.toBool();
            break;
        case IsSwapRole:
            item.is_swap = value.toBool();
        case IsRecoverableRole:
            item.is_recoverable = value.toBool();
        }

        emit dataChanged(index, index, {role});
        return true;
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
        case MakerPaymentIdRole:
            return item.maker_payment_spent_id;
        case TakerPaymentIdRole:
            return item.taker_payment_sent_id;
        case CancellableRole:
            return item.is_cancellable;
        case IsMakerRole:
            return item.is_maker;
        case IsSwapRole:
            return item.is_swap;
        case IsRecoverableRole:
            return item.is_recoverable;
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
            emit lengthChanged();
        }
        endRemoveRows();

        return true;
    }

    QString
    orders_model::determine_order_status_from_last_event(const ::mm2::api::swap_contents& contents) noexcept
    {
        if (contents.events.empty())
        {
            return "matching";
        }
        auto last_event = contents.events.back().at("state").get<std::string>();
        if (last_event == "Started")
        {
            return "matched";
        }

        QString status = "ongoing";
        if (last_event == "Finished")
        {
            status = "successful";
            //! Find error or not
            for (auto&& cur_event: contents.events)
            {
                if (cur_event.contains("data") && cur_event.at("data").contains("error") &&
                    std::any_of(begin(contents.error_events), end(contents.error_events), [&cur_event](auto&& error_str) {
                        return cur_event.at("state").get<std::string>() == error_str;
                    }))
                {
                    //! It's an error
                    status = "failed";
                }
            }
        }

        return status;
    }

    void
    orders_model::initialize_swap(const ::mm2::api::swap_contents& contents) noexcept
    {
        spdlog::trace("inserting in model order id {}", contents.uuid);
        beginInsertRows(QModelIndex(), this->m_model_data.count(), this->m_model_data.count());
        bool       is_maker = boost::algorithm::to_lower_copy(contents.type) == "maker";
        order_data data{
            .is_maker       = is_maker,
            .base_coin      = is_maker ? QString::fromStdString(contents.maker_coin) : QString::fromStdString(contents.taker_coin),
            .rel_coin       = is_maker ? QString::fromStdString(contents.taker_coin) : QString::fromStdString(contents.maker_coin),
            .base_amount    = is_maker ? QString::fromStdString(contents.maker_amount) : QString::fromStdString(contents.taker_amount),
            .rel_amount     = is_maker ? QString::fromStdString(contents.taker_amount) : QString::fromStdString(contents.maker_amount),
            .order_type     = is_maker ? "maker" : "taker",
            .human_date     = not contents.events.empty() ? QString::fromStdString(contents.events.back().at("human_timestamp").get<std::string>()) : "",
            .unix_timestamp = not contents.events.empty() ? contents.events.back().at("timestamp").get<int>() : 0,
            .order_id       = QString::fromStdString(contents.uuid),
            .order_status   = determine_order_status_from_last_event(contents),
            .is_swap        = true,
            .is_cancellable = false,
            .is_recoverable = contents.funds_recoverable};
        this->m_swaps_id_registry.emplace(contents.uuid);
        this->m_model_data.push_back(std::move(data));
        endInsertRows();
        emit lengthChanged();
    }

    void
    orders_model::initialize_order(const ::mm2::api::my_order_contents& contents) noexcept
    {
        spdlog::trace("inserting in model order id {}", contents.order_id);
        beginInsertRows(QModelIndex(), this->m_model_data.count(), this->m_model_data.count());
        order_data data{
            .is_maker       = contents.order_type == "maker",
            .base_coin      = QString::fromStdString(contents.base),
            .rel_coin       = QString::fromStdString(contents.rel),
            .base_amount    = QString::fromStdString(contents.base_amount),
            .rel_amount     = QString::fromStdString(contents.rel_amount),
            .order_type     = QString::fromStdString(contents.order_type),
            .human_date     = QString::fromStdString(contents.human_timestamp),
            .unix_timestamp = static_cast<int>(contents.timestamp),
            .order_id       = QString::fromStdString(contents.order_id),
            .order_status   = "matching",
            .is_swap        = false,
            .is_cancellable = contents.cancellable,
            .is_recoverable = false};
        this->m_orders_id_registry.emplace(contents.order_id);
        this->m_model_data.push_back(std::move(data));
        endInsertRows();
        emit lengthChanged();
    }


    void
    orders_model::update_existing_order(const ::mm2::api::my_order_contents& contents) noexcept
    {
        if (const auto res = this->match(index(0, 0), OrderIdRole, QString::fromStdString(contents.order_id)); not res.isEmpty())
        {
            const QModelIndex& idx = res.at(0);
            update_value(OrdersRoles::CancellableRole, contents.cancellable, idx, *this);
            update_value(OrdersRoles::IsMakerRole, contents.order_type == "maker", idx, *this);
            update_value(OrdersRoles::OrderTypeRole, QString::fromStdString(contents.order_type), idx, *this);
        }
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
                        this->update_existing_order(value);
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
            std::unordered_set<std::string> to_remove;
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
                        to_remove.emplace(id);
                    }
                }
            }
            std::unordered_set<std::string> out;
            std::set_difference(begin(m_orders_id_registry), end(m_orders_id_registry), begin(to_remove), end(to_remove), std::inserter(out, out.begin()));
            m_orders_id_registry = out;
        }
    }

    void
    orders_model::refresh_or_insert_swaps() noexcept
    {
        const auto& mm2_system = this->m_system_manager.get_system<mm2>();
        const auto  result     = mm2_system.get_swaps();
        for (auto&& current_swap: result.swaps)
        {
            if (this->m_swaps_id_registry.find(current_swap.uuid) != this->m_swaps_id_registry.end())
            {
                spdlog::trace("find id {}, updating", current_swap.uuid);
                //! update
            }
            else
            {
                //! Insert
                spdlog::trace("id {}, not found, inserting", current_swap.uuid);
                this->initialize_swap(current_swap);
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
            {IsMakerRole, "is_maker"},
            {HumanDateRole, "date"},
            {UnixTimestampRole, "timestamp"},
            {OrderIdRole, "order_id"},
            {OrderStatusRole, "order_status"},
            {MakerPaymentIdRole, "maker_payment_id"},
            {TakerPaymentIdRole, "taker_payment_id"},
            {IsSwapRole, "is_swap"},
            {CancellableRole, "cancellable"},
            {IsRecoverableRole, "recoverable"}};
    }

    int
    orders_model::get_length() const noexcept
    {
        return this->rowCount(QModelIndex());
    }

    orders_proxy_model*
    orders_model::get_orders_proxy_mdl() const noexcept
    {
        return m_model_proxy;
    }

    void
    orders_model::clear_registry() noexcept
    {
        spdlog::trace("clearing orders");
        this->beginResetModel();
        this->m_swaps_id_registry.clear();
        this->m_orders_id_registry.clear();
        this->m_model_data.clear();
        this->endResetModel();
    }
} // namespace atomic_dex