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

#include <boost/algorithm/string/replace.hpp>
//! Project Headers
#include "atomicdex/api/kdf/rpc_v2/rpc2.bestorders.hpp"
#include "atomicdex/pages/qt.trading.page.hpp"
#include "atomicdex/services/kdf/kdf.service.hpp"
#include "atomicdex/services/price/orderbook.scanner.service.hpp"

//! Constructor
namespace atomic_dex
{
    orderbook_scanner_service::orderbook_scanner_service(entt::registry& registry, ag::ecs::system_manager& system_manager) :
        system(registry), m_system_manager(system_manager)
    {
        SPDLOG_INFO("orderbook_scanner_service created");
        m_update_clock      = std::chrono::high_resolution_clock::now();
        m_best_orders_infos = nlohmann::json::object();
    }
} // namespace atomic_dex

//! Private member functions
namespace atomic_dex
{
    void
    orderbook_scanner_service::process_best_orders() 
    {
        if (m_bestorders_busy)
        {
            SPDLOG_INFO("process_best_orders is busy - skipping");
            return;
        }

        // SPDLOG_INFO("process_best_orders processing");
        if (m_system_manager.has_system<kdf_service>())
        {
            auto& kdf_system = m_system_manager.get_system<kdf_service>();
            if (kdf_system.is_kdf_running() && kdf_system.is_orderbook_thread_active())
            {
                // SPDLOG_INFO("process_best_orders");
                using namespace std::string_literals;
                const auto&            trading_pg = m_system_manager.get_system<trading_page>();
                auto                   volume     = trading_pg.get_volume().toStdString();
                auto                   action     = trading_pg.get_market_mode() == MarketMode::Buy ? "buy"s : "sell"s;
                auto                   coin       = trading_pg.get_market_pairs_mdl()->get_left_selected_coin().toStdString();

                auto callback = [this, &trading_pg]<typename RpcRequest>(RpcRequest rpc)
                {
                    nlohmann::json batch = nlohmann::json::array();
                    if (rpc.error)
                    {
                        // SPDLOG_DEBUG("error: bad answer json for process_best_orders: {}", rpc.error->error);
                        this->m_bestorders_busy = false;
                        // SPDLOG_DEBUG("Triggering [process_orderbook_finished]: true");
                        this->dispatcher_.trigger<process_orderbook_finished>(true);
                    }
                    else
                    {
                        if (rpc.result.has_value())
                        {
                            this->m_best_orders_infos = rpc.result.value();
                        }
                        this->m_bestorders_busy = false;
                        // SPDLOG_DEBUG("Triggering [process_orderbook_finished]: false");
                        this->dispatcher_.trigger<process_orderbook_finished>(false);
                        emit trading_pg.get_orderbook_wrapper()->bestOrdersBusyChanged();
                    }
                };


                this->m_bestorders_busy = true;
                emit trading_pg.get_orderbook_wrapper()->bestOrdersBusyChanged();
                kdf::bestorders_rpc rpc{.request={.coin = std::move(coin), .volume = std::move(volume), .action = std::move(action)}};
                kdf_system.get_kdf_client().process_rpc_async<atomic_dex::kdf::bestorders_rpc>(rpc.request, callback);
            }
            else
            {
                SPDLOG_WARN("KDF Service not launched yet - skipping process_best_orders");
            }
        }
        else
        {
            SPDLOG_WARN("KDF Service not created yet - skipping process_best_orders");
        }
    }
} // namespace atomic_dex

//! Override member
namespace atomic_dex
{
    void
    orderbook_scanner_service::update() 
    {
        //! Scan orderbook widget every 30 seconds if there is not any update
        using namespace std::chrono_literals;

        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - m_update_clock);
        if (s >= 45s)
        {
            SPDLOG_DEBUG("<<<<<<<<<<< orderbook_scanner_service update loop after 30 seconds >>>>>>>>>>>>>");
            process_best_orders();
            m_update_clock = std::chrono::high_resolution_clock::now();
        }
    }

    bool
    orderbook_scanner_service::is_best_orders_busy() const 
    {
        return m_bestorders_busy.load();
    }

    t_orders_contents
    orderbook_scanner_service::get_bestorders_data() const 
    {
        return m_best_orders_infos.get().result;
    }
} // namespace atomic_dex