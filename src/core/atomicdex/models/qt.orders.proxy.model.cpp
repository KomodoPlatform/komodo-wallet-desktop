/******************************************************************************
 * Copyright © 2013-2024 The Komodo Platform Developers.                      *
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

//! Qt
#include <QDebug>

//! Boost
#include <boost/algorithm/string.hpp>

//! Project
#include "atomicdex/models/qt.orders.model.hpp"
#include "atomicdex/models/qt.orders.proxy.model.hpp"
#include "atomicdex/pages/qt.trading.page.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

namespace atomic_dex
{
    orders_proxy_model::orders_proxy_model(QObject* parent, ag::ecs::system_manager& system_manager) :
        QSortFilterProxyModel(parent), m_system_manager(system_manager)
    {
    }

    bool
    orders_proxy_model::lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const
    {
        int      role       = this->sortRole();
        QVariant left_data  = sourceModel()->data(source_left, role);
        QVariant right_data = sourceModel()->data(source_right, role);
        switch (static_cast<atomic_dex::orders_model::OrdersRoles>(role))
        {
        case orders_model::BaseCoinRole:
            break;
        case orders_model::RelCoinRole:
            break;
        case orders_model::TickerPairRole:
            break;
        case orders_model::BaseCoinAmountRole:
            break;
        case orders_model::BaseCoinAmountCurrentCurrencyRole:
            break;
        case orders_model::RelCoinAmountRole:
            break;
        case orders_model::RelCoinAmountCurrentCurrencyRole:
            break;
        case orders_model::MinVolumeRole:
            break;
        case orders_model::MaxVolumeRole:
            break;
        case orders_model::OrderTypeRole:
            break;
        case orders_model::IsMakerRole:
            break;
        case orders_model::HumanDateRole:
            break;
        case orders_model::UnixTimestampRole:
            return left_data.toULongLong() < right_data.toULongLong();
        case orders_model::PaymentLockRole:
            break;
        case orders_model::OrderIdRole:
            break;
        case orders_model::OrderStatusRole:
            break;
        case orders_model::MakerPaymentIdRole:
            break;
        case orders_model::TakerPaymentIdRole:
            break;
        case orders_model::IsSwapRole:
            break;
        case orders_model::CancellableRole:
            break;
        case orders_model::IsRecoverableRole:
            break;
        case orders_model::OrdersRoles::OrderErrorStateRole:
            break;
        case orders_model::OrdersRoles::OrderErrorMessageRole:
            break;
        case orders_model::EventsRole:
            break;
        case orders_model::SuccessEventsRole:
            break;
        case orders_model::ErrorEventsRole:
            break;
        }
        return true;
    }

    bool
    orders_proxy_model::am_i_in_history() const
    {
        return m_is_history;
    }

    void
    orders_proxy_model::set_is_history(bool is_history)
    {
        if (this->m_is_history != is_history)
        {
            this->m_is_history = is_history;
            emit isHistoryChanged();
            this->invalidate();
            if (m_is_history)
            {
                SPDLOG_INFO("history mode enabled");
                qobject_cast<orders_model*>(this->sourceModel())->set_current_page(1);
            }
            else
            {
                SPDLOG_INFO("order mode enabled");
                emit qobject_cast<orders_model*>(this->sourceModel())->lengthChanged();
            }
        }
    }

    bool
    orders_proxy_model::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const
    {
        QModelIndex idx = this->sourceModel()->index(source_row, 0, source_parent);
        if (not this->sourceModel()->hasIndex(idx.row(), 0))
        {
            return false;
        }
        auto       data           = this->sourceModel()->data(idx, orders_model::OrdersRoles::OrderStatusRole).toString();
        const bool is_swap        = this->sourceModel()->data(idx, orders_model::OrdersRoles::IsSwapRole).toBool();
        const bool is_maker       = this->sourceModel()->data(idx, orders_model::OrdersRoles::IsMakerRole).toBool();
        auto       timestamp      = this->sourceModel()->data(idx, orders_model::OrdersRoles::UnixTimestampRole).toULongLong();
        auto       date           = QDateTime::fromMSecsSinceEpoch(timestamp).date();
        const bool is_simple_view = m_system_manager.get_system<trading_page>().get_current_trading_mode() == TradingModeGadget::Simple;

        if (not this->m_is_history && not date_in_range(date))
        {
            return false;
        }

        assert(not data.isEmpty());

        if (this->m_is_history)
        {
            if (data == "matching" || data == "ongoing" || data == "matched" || data == "refunding")
            {
                return false;
            }
        }
        else
        {
            if (data == "successful" || data == "failed")
            {
                return false;
            }
        }

        if (!this->m_is_history && is_maker && !is_swap && is_simple_view)
        {
            return false;
        }

        if (not this->m_is_history && this->filterRole() == orders_model::OrdersRoles::TickerPairRole)
        {
            const auto pattern = this->filterRegExp().pattern().toStdString();
            if (pattern.find("/") != std::string::npos)
            {
                std::vector<std::string> out;
                boost::algorithm::split(out, pattern, boost::is_any_of("/"));
                auto base_coin = this->sourceModel()->data(idx, orders_model::OrdersRoles::BaseCoinRole).toString();
                auto rel_coin  = this->sourceModel()->data(idx, orders_model::OrdersRoles::RelCoinRole).toString();
                if (out.size() >= 2)
                {
                    const auto& left_pattern  = out[0];
                    const auto& right_pattern = out[1];
                    if (left_pattern == "All" && right_pattern == "All")
                    {
                        return true;
                    }
                    if (left_pattern == "All" && right_pattern == rel_coin.toStdString())
                    {
                        return true;
                    }
                    if (right_pattern == "All" && left_pattern == base_coin.toStdString())
                    {
                        return true;
                    }
                    return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
                }
            }
        }

        return true;
    }

    QDate
    orders_proxy_model::filter_minimum_date() const
    {
        return m_min_date;
    }

    void
    orders_proxy_model::set_filter_minimum_date(QDate date)
    {
        m_min_date = date;
        emit filterMinimumDateChanged();
        if (not this->m_is_history)
        {
            this->invalidate();
            emit qobject_cast<orders_model*>(this->sourceModel())->lengthChanged();
        }
        else
        {
            this->set_apply_filtering(true);
        }
    }

    QDate
    orders_proxy_model::filter_maximum_date() const
    {
        return m_max_date;
    }

    void
    orders_proxy_model::set_filter_maximum_date(QDate date)
    {
        m_max_date = date;
        emit filterMaximumDateChanged();
        if (not this->m_is_history)
        {
            this->invalidate();
            emit qobject_cast<orders_model*>(this->sourceModel())->lengthChanged();
        }
        else
        {
            this->set_apply_filtering(true);
        }
    }

    bool
    orders_proxy_model::date_in_range(QDate date) const
    {
        return (!m_min_date.isValid() || date >= m_min_date) && (!m_max_date.isValid() || date <= m_max_date);
    }

    QStringList
    orders_proxy_model::get_filtered_ids() const
    {
        QStringList out;
        int         nb_items = this->rowCount();
        out.reserve(nb_items);
        qDebug() << nb_items;
        for (int cur_idx = 0; cur_idx < nb_items; ++cur_idx)
        {
            QModelIndex idx = this->index(cur_idx, 0);
            out << this->data(idx, orders_model::OrdersRoles::OrderIdRole).toString();
        }
        return out;
    }

    void
    orders_proxy_model::set_coin_filter(const QString& to_filter)
    {
        SPDLOG_INFO("filter pattern: {}, is_history: {}", to_filter.toStdString(), m_is_history);
        this->setFilterFixedString(to_filter);
        if (this->m_is_history)
        {
            this->set_apply_filtering(true);
        }
        // else
        //{
        // emit qobject_cast<orders_model*>(this->sourceModel())->lengthChanged();
        //}
    }

    void
    orders_proxy_model::export_csv_visible_history(const QString& path)
    {
        const std::filesystem::path csv_path = path.toStdString();
        SPDLOG_INFO("exporting csv with path: {}", csv_path.string());
        std::ofstream ofs(csv_path.string(), std::ios::out | std::ios::trunc);
        int           nb_items = this->rowCount();
        ofs << "Date,BaseCoin,BaseAmount,Status,RelCoin,RelAmount,UUID,ErrorState" << std::endl;
        for (int cur_idx = 0; cur_idx < nb_items; ++cur_idx)
        {
            QModelIndex idx = this->index(cur_idx, 0);
            ofs << this->data(idx, orders_model::OrdersRoles::HumanDateRole).toString().toStdString() << ",";
            ofs << this->data(idx, orders_model::OrdersRoles::BaseCoinRole).toString().toStdString() << ",";
            ofs << this->data(idx, orders_model::OrdersRoles::BaseCoinAmountRole).toString().toStdString() << ",";
            auto status = this->data(idx, orders_model::OrdersRoles::OrderStatusRole).toString().toStdString();
            ofs << status << ",";
            ofs << this->data(idx, orders_model::OrdersRoles::RelCoinRole).toString().toStdString() << ",";
            ofs << this->data(idx, orders_model::OrdersRoles::RelCoinAmountRole).toString().toStdString() << ",";
            ofs << this->data(idx, orders_model::OrdersRoles::OrderIdRole).toString().toStdString();
            if (status == "failed")
            {
                ofs << "," << this->data(idx, orders_model::OrdersRoles::OrderErrorStateRole).toString().toStdString() << std::endl;
            }
            else
            {
                ofs << ",Success" << std::endl;
            }
        }
        ofs.close();
    }

    void
    orders_proxy_model::apply_all_filtering()
    {
        auto* model        = qobject_cast<orders_model*>(this->sourceModel());
        auto  filter_infos = model->get_filtering_infos();

        if (m_min_date.isValid() && !m_min_date.isNull())
        {
            std::size_t from_timestamp  = m_min_date.startOfDay().toSecsSinceEpoch();
            filter_infos.from_timestamp = from_timestamp;
        }

        if (m_max_date.isValid() && !m_max_date.isNull())
        {
            std::size_t to_timestamp  = m_max_date.startOfDay().toSecsSinceEpoch();
            filter_infos.to_timestamp = to_timestamp;
        }

        const auto pattern = this->filterRegExp().pattern().toStdString();
        if (pattern.find("/") != std::string::npos)
        {
            std::vector<std::string> out;
            boost::algorithm::split(out, pattern, boost::is_any_of("/"));
            if (out.size() >= 2)
            {
                const auto& left_pattern  = out[0];
                const auto& right_pattern = out[1];
                if (left_pattern == "All")
                {
                    filter_infos.my_coin = std::nullopt;
                }
                else
                {
                    filter_infos.my_coin = left_pattern;
                }

                if (right_pattern == "All")
                {
                    filter_infos.other_coin = std::nullopt;
                }
                else
                {
                    filter_infos.other_coin = right_pattern;
                }
            }
        }

        model->set_filtering_infos(filter_infos);
        this->set_apply_filtering(false);
    }

    bool
    orders_proxy_model::get_apply_filtering() const
    {
        return m_is_filtering_applicable;
    }
    void
    orders_proxy_model::set_apply_filtering(bool status)
    {
        if (m_is_filtering_applicable != status)
        {
            m_is_filtering_applicable = status;
            emit filteringStatusChanged();
        }
    }
} // namespace atomic_dex
