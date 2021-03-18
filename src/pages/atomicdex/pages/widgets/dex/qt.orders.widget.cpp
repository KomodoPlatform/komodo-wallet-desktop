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

//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/mm2/mm2.hpp"
#include "atomicdex/services/mm2/mm2.service.hpp"
#include "qt.orders.widget.hpp"

//! Constructor / Destructor
namespace atomic_dex
{
    qt_orders_widget::qt_orders_widget(ag::ecs::system_manager& system_manager, QObject* parent) noexcept : QObject(parent), m_system_mgr(system_manager)
    {
        SPDLOG_INFO("qt_orders_widget created");
    }
    qt_orders_widget::~qt_orders_widget() noexcept { SPDLOG_INFO("qt_orders widget destroyed"); }
} // namespace atomic_dex

//! Private member functions
namespace atomic_dex
{
    void
    qt_orders_widget::common_cancel_all_orders(bool by_coin, const QString& ticker)
    {
        nlohmann::json batch          = nlohmann::json::array();
        nlohmann::json cancel_request = ::mm2::api::template_request("cancel_all_orders");
        if (by_coin && not ticker.isEmpty())
        {
            ::mm2::api::cancel_data cd;
            cd.ticker = ticker.toStdString();
            ::mm2::api::cancel_all_orders_request req{{"Coin", cd}};
            ::mm2::api::to_json(cancel_request, req);
        }
        else
        {
            ::mm2::api::cancel_data cd;
            cd.ticker = ticker.toStdString();
            ::mm2::api::cancel_all_orders_request req_all;
            ::mm2::api::to_json(cancel_request, req_all);
        }

        batch.push_back(cancel_request);
        auto& mm2_system = m_system_mgr.get_system<mm2_service>();
        ::mm2::api::async_rpc_batch_standalone(batch, mm2_system.get_mm2_client(), pplx::cancellation_token::none())
            .then([this]([[maybe_unused]] web::http::http_response resp) {
                auto& mm2_system = m_system_mgr.get_system<mm2_service>();
                mm2_system.batch_fetch_orders_and_swap();
                mm2_system.process_orderbook(false);
            })
            .then(&handle_exception_pplx_task);
    }
} // namespace atomic_dex

//! QML API
namespace atomic_dex
{
    void
    qt_orders_widget::cancel_order(const QStringList& orders_id)
    {
        SPDLOG_INFO("cancel order");
        nlohmann::json batch = nlohmann::json::array();
        for (auto&& order_id: orders_id)
        {
            ::mm2::api::cancel_all_orders_request req;
            nlohmann::json                        cancel_request = ::mm2::api::template_request("cancel_order");
            ::mm2::api::cancel_order_request      cancel_req{order_id.toStdString()};
            to_json(cancel_request, cancel_req);
            batch.push_back(cancel_request);
        }

        auto& mm2_system = m_system_mgr.get_system<mm2_service>();
        ::mm2::api::async_rpc_batch_standalone(batch, mm2_system.get_mm2_client(), pplx::cancellation_token::none())
            .then([this]([[maybe_unused]] web::http::http_response resp) {
                auto& mm2_system = m_system_mgr.get_system<mm2_service>();
                mm2_system.batch_fetch_orders_and_swap();
                mm2_system.process_orderbook(false);
            })
            .then(&handle_exception_pplx_task);
    }

    void
    qt_orders_widget::cancel_all_orders()
    {
        SPDLOG_INFO("cancel_all_orders");
        common_cancel_all_orders();
    }

    void
    qt_orders_widget::cancel_all_orders_by_ticker(const QString& ticker)
    {
        SPDLOG_INFO("cancel_all_orders by ticker {}", ticker.toStdString());
        common_cancel_all_orders(true, ticker);
    }
} // namespace atomic_dex

namespace atomic_dex
{
    template <typename T>
    T get_multi_ticker_data(const QString& ticker, atomic_dex::portfolio_model::PortfolioRoles role, atomic_dex::portfolio_proxy_model* multi_ticker_model)
    {
        if (const auto res = multi_ticker_model->sourceModel()->match(
                multi_ticker_model->index(0, 0), atomic_dex::portfolio_model::TickerRole, ticker, 1, Qt::MatchFlag::MatchExactly);
            not res.isEmpty())
        {
            const QModelIndex& idx = res.at(0);
            return multi_ticker_model->sourceModel()->data(idx, role).value<T>();
        }
        return T{};
    }
    
    void qt_orders_widget::determine_multi_ticker_fees(const QString& ticker, market_pairs* market_pairs)
    {
        auto* selection_box   = market_pairs->get_multiple_selection_box();
        // const auto& mm2             = m_system_manager.get_system<mm2_service>();
        auto  total_amount = get_multi_ticker_data<QString>(ticker, portfolio_model::PortfolioRoles::MultiTickerReceiveAmount, selection_box);
        // auto        fees            = generate_fees_infos(market_selector->get_left_selected_coin(), ticker, true, m_volume, mm2);
        // qDebug() << "fees multi_ticker: " << fees;
        // set_multi_ticker_data(ticker, portfolio_model::MultiTickerFeesInfo, fees, selection_box);
        // this->determine_multi_ticker_error_cases(ticker, fees);
    }
}