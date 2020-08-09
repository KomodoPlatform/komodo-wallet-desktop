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
#include "atomic.dex.qt.events.hpp"
#include "atomic.dex.qt.utilities.hpp"

//! Utils
namespace
{
    template <typename TModel>
    auto
    update_value(int role, const QVariant& value, const QModelIndex& idx, TModel& model)
    {
        if (auto prev_value = model.data(idx, role); value != prev_value)
        {
            model.setData(idx, value, role);
            return std::make_tuple(prev_value, value, true);
        }
        return std::make_tuple(value, value, false);
    }

    std::pair<QString, QString>
    extract_error(const ::mm2::api::swap_contents& contents)
    {
        for (auto&& cur_event: contents.events)
        {
            if (std::any_of(begin(contents.error_events), end(contents.error_events), [&cur_event](auto&& error_str) {
                    return cur_event.at("state").get<std::string>() == error_str;
                }))
            {
                //! It's an error
                if (cur_event.contains("data") && cur_event.at("data").contains("error"))
                {
                    return {
                        QString::fromStdString(cur_event.at("state").get<std::string>()),
                        QString::fromStdString(cur_event.at("data").at("error").get<std::string>())};
                }
            }
        }
        return {};
    }
} // namespace

namespace atomic_dex
{
    orders_model::orders_model(ag::ecs::system_manager& system_manager, entt::dispatcher& dispatcher, QObject* parent) noexcept :
        QAbstractListModel(parent), m_system_manager(system_manager), m_dispatcher(dispatcher), m_model_proxy(new orders_proxy_model(this))
    {
        spdlog::trace("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::trace("orders model created");

        this->m_model_proxy->setSourceModel(this);
        this->m_model_proxy->setDynamicSortFilter(true);
        this->m_model_proxy->setSortRole(UnixTimestampRole);
        this->m_model_proxy->setFilterRole(TickerPairRole);
        this->m_model_proxy->sort(0, Qt::DescendingOrder);
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
        case TickerPairRole:
            item.ticker_pair = value.toString();
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
            item.unix_timestamp = value.toULongLong();
            break;
        case OrderIdRole:
            item.order_id = value.toString();
            break;
        case OrderStatusRole:
            item.order_status = value.toString();
            break;
        case MakerPaymentIdRole:
            item.maker_payment_id = value.toString();
            break;
        case TakerPaymentIdRole:
            item.taker_payment_id = value.toString();
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
        case OrderErrorStateRole:
            item.order_error_state = value.toString();
        case OrderErrorMessageRole:
            item.order_error_message = value.toString();
        case EventsRole:
            item.events = value.toJsonArray();
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
        case TickerPairRole:
            return item.ticker_pair;
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
            return item.maker_payment_id;
        case TakerPaymentIdRole:
            return item.taker_payment_id;
        case CancellableRole:
            return item.is_cancellable;
        case IsMakerRole:
            return item.is_maker;
        case IsSwapRole:
            return item.is_swap;
        case IsRecoverableRole:
            return item.is_recoverable;
        case OrderErrorStateRole:
            return item.order_error_state;
        case OrderErrorMessageRole:
            return item.order_error_message;
        case EventsRole:
            return item.events;
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
    orders_model::determine_payment_id(const ::mm2::api::swap_contents& contents, bool am_i_maker, bool want_taker_id) noexcept
    {
        QString result = "";

        if (contents.events.empty())
        {
            return result;
        }

        std::string search_name;
        if (am_i_maker)
        {
            search_name = want_taker_id ? "TakerPaymentSpent" : "MakerPaymentSent";
        }
        else
        {
            search_name = want_taker_id ? "TakerPaymentSent" : "MakerPaymentSpent";
        }
        for (auto&& cur_event: contents.events)
        {
            if (cur_event.at("state").get<std::string>() == search_name)
            {
                result = QString::fromStdString(cur_event.at("data").at("tx_hash").get<std::string>());
            }
        }
        return result;
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

        if (last_event == "TakerPaymentWaitRefundStarted" || last_event == "MakerPaymentWaitRefundStarted")
        {
            return "refunding";
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
            .is_maker         = is_maker,
            .base_coin        = is_maker ? QString::fromStdString(contents.maker_coin) : QString::fromStdString(contents.taker_coin),
            .rel_coin         = is_maker ? QString::fromStdString(contents.taker_coin) : QString::fromStdString(contents.maker_coin),
            .base_amount      = is_maker ? QString::fromStdString(contents.maker_amount) : QString::fromStdString(contents.taker_amount),
            .rel_amount       = is_maker ? QString::fromStdString(contents.taker_amount) : QString::fromStdString(contents.maker_amount),
            .order_type       = is_maker ? "maker" : "taker",
            .human_date       = not contents.events.empty() ? QString::fromStdString(contents.events.back().at("human_timestamp").get<std::string>()) : "",
            .unix_timestamp   = not contents.events.empty() ? contents.events.back().at("timestamp").get<unsigned long long>() : 0,
            .order_id         = QString::fromStdString(contents.uuid),
            .order_status     = determine_order_status_from_last_event(contents),
            .maker_payment_id = determine_payment_id(contents, is_maker, false),
            .taker_payment_id = determine_payment_id(contents, is_maker, true),
            .is_swap          = true,
            .is_cancellable   = false,
            .is_recoverable   = contents.funds_recoverable,
            .events           = nlohmann_json_array_to_qt_json_array(contents.events)};
        data.ticker_pair = data.base_coin + "/" + data.rel_coin;
        if (data.order_status == "failed")
        {
            auto error               = extract_error(contents);
            data.order_error_state   = error.first;
            data.order_error_message = error.second;
        }

        if (data.order_status == "matched")
        {
            using namespace std::string_literals;
            m_dispatcher.trigger<swap_status_notification>(data.order_id, "matching", "matched", data.base_coin, data.rel_coin, data.human_date);
        }

        if (this->m_swaps_id_registry.find(contents.uuid) == m_swaps_id_registry.end())
        {
            this->m_swaps_id_registry.emplace(contents.uuid);
        }
        this->m_model_data.push_back(std::move(data));
        endInsertRows();
        emit lengthChanged();
    }

    void
    orders_model::update_swap(const ::mm2::api::swap_contents& contents) noexcept
    {
        if (const auto res = this->match(index(0, 0), OrderIdRole, QString::fromStdString(contents.uuid)); not res.isEmpty())
        {
            const QModelIndex& idx      = res.at(0);
            bool               is_maker = boost::algorithm::to_lower_copy(contents.type) == "maker";
            update_value(OrdersRoles::IsRecoverableRole, contents.funds_recoverable, idx, *this);
            auto&& [prev_value, new_value, is_change] =
                update_value(OrdersRoles::OrderStatusRole, determine_order_status_from_last_event(contents), idx, *this);
            update_value(
                OrdersRoles::UnixTimestampRole, not contents.events.empty() ? contents.events.back().at("timestamp").get<unsigned long long>() : 0, idx, *this);
            auto&& [prev_value_d, new_value_d, _] = update_value(
                OrdersRoles::HumanDateRole,
                not contents.events.empty() ? QString::fromStdString(contents.events.back().at("human_timestamp").get<std::string>()) : "", idx, *this);
            if (is_change)
            {
                const QString& base_coin = data(idx, OrdersRoles::BaseCoinRole).toString();
                const QString& rel_coin  = data(idx, OrdersRoles::RelCoinRole).toString();
                m_dispatcher.trigger<swap_status_notification>(
                    QString::fromStdString(contents.uuid), prev_value.toString(), new_value.toString(), base_coin, rel_coin, new_value_d.toString());
            }
            update_value(OrdersRoles::MakerPaymentIdRole, determine_payment_id(contents, is_maker, false), idx, *this);
            update_value(OrdersRoles::TakerPaymentIdRole, determine_payment_id(contents, is_maker, true), idx, *this);
            auto [state, msg] = extract_error(contents);
            update_value(OrdersRoles::OrderErrorStateRole, state, idx, *this);
            update_value(OrdersRoles::OrderErrorMessageRole, msg, idx, *this);
            update_value(OrdersRoles::EventsRole, nlohmann_json_array_to_qt_json_array(contents.events), idx, *this);
            emit lengthChanged();
        }
        else
        {
            bool is_maker = boost::algorithm::to_lower_copy(contents.type) == "maker";
            spdlog::error(
                "swap with id {} and ticker: {}, not found in the model, cannot update, forcing an initialization instead", contents.uuid,
                is_maker ? contents.maker_coin : contents.taker_coin);
            initialize_swap(contents);
        }
    }

    void
    orders_model::initialize_order(const ::mm2::api::my_order_contents& contents) noexcept
    {
        spdlog::trace("inserting in model order id {}", contents.order_id);
        beginInsertRows(QModelIndex(), this->m_model_data.count(), this->m_model_data.count());
        order_data data{
            .is_maker       = contents.order_type == "maker",
            .base_coin      = contents.action == "Sell" ? QString::fromStdString(contents.base) : QString::fromStdString(contents.rel),
            .rel_coin       = contents.action == "Sell" ? QString::fromStdString(contents.rel) : QString::fromStdString(contents.base),
            .base_amount    = contents.action == "Sell" ? QString::fromStdString(contents.base_amount) : QString::fromStdString(contents.rel_amount),
            .rel_amount     = contents.action == "Sell" ? QString::fromStdString(contents.rel_amount) : QString::fromStdString(contents.base_amount),
            .order_type     = QString::fromStdString(contents.order_type),
            .human_date     = QString::fromStdString(contents.human_timestamp),
            .unix_timestamp = static_cast<unsigned long long>(contents.timestamp),
            .order_id       = QString::fromStdString(contents.order_id),
            .order_status   = "matching",
            .is_swap        = false,
            .is_cancellable = contents.cancellable,
            .is_recoverable = false};
        data.ticker_pair = data.base_coin + "/" + data.rel_coin;
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
            emit lengthChanged();
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
                        spdlog::trace("removing order with id {} from the UI", id);
                        this->removeRow(res_list.at(0).row());
                        to_remove.emplace(id);
                    }
                }
            }
            // std::unordered_set<std::string> out;
            // std::set_difference(begin(m_orders_id_registry), end(m_orders_id_registry), begin(to_remove), end(to_remove), std::inserter(out, out.begin()));
            for (auto&& cur_to_remove: to_remove) { m_orders_id_registry.erase(cur_to_remove); }
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
                this->update_swap(current_swap);
            }
            else
            {
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
            {TickerPairRole, "ticker_pair"},
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
            {IsRecoverableRole, "recoverable"},
            {OrderErrorStateRole, "order_error_state"},
            {OrderErrorMessageRole, "order_error_message"},
            {EventsRole, "events"}};
    }

    int
    orders_model::get_length() const noexcept
    {
        return this->m_model_proxy->rowCount(QModelIndex());
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