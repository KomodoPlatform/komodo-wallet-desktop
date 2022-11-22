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
#include "../../qt.settings.page.hpp"
#include "../../qt.trading.page.hpp"
#include "atomicdex/api/mm2/mm2.hpp"
#include "atomicdex/services/mm2/mm2.service.hpp"
#include "atomicdex/services/price/global.provider.hpp"
#include "qt.orders.widget.hpp"

//! Constructor / Destructor
namespace atomic_dex
{
    qt_orders_widget::qt_orders_widget(ag::ecs::system_manager& system_manager, QObject* parent) : QObject(parent), m_system_mgr(system_manager)
    {
        SPDLOG_INFO("qt_orders_widget created");
    }
    qt_orders_widget::~qt_orders_widget() { SPDLOG_INFO("qt_orders widget destroyed"); }
} // namespace atomic_dex

//! Private member functions
namespace atomic_dex
{
    void
    qt_orders_widget::common_cancel_all_orders(bool by_coin, const QString& ticker)
    {
        nlohmann::json batch          = nlohmann::json::array();
        nlohmann::json cancel_request = mm2::template_request("cancel_all_orders");
        if (by_coin && not ticker.isEmpty())
        {
            mm2::cancel_data cd;
            cd.ticker = ticker.toStdString();
            mm2::cancel_all_orders_request req{{"Coin", cd}};
            mm2::to_json(cancel_request, req);
        }
        else
        {
            mm2::cancel_data cd;
            cd.ticker = ticker.toStdString();
            mm2::cancel_all_orders_request req_all;
            mm2::to_json(cancel_request, req_all);
        }

        batch.push_back(cancel_request);
        auto& mm2_system = m_system_mgr.get_system<mm2_service>();
        mm2_system.get_mm2_client()
            .async_rpc_batch_standalone(batch)
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
            mm2::cancel_all_orders_request req;
            nlohmann::json                        cancel_request = mm2::template_request("cancel_order");
            mm2::cancel_order_request      cancel_req{order_id.toStdString()};
            to_json(cancel_request, cancel_req);
            batch.push_back(cancel_request);
        }

        auto& mm2_system = m_system_mgr.get_system<mm2_service>();
        mm2_system.get_mm2_client()
            .async_rpc_batch_standalone(batch)
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
