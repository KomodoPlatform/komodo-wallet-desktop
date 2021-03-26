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

//! Qt Headers
#include <QSettings>

// Project Headers
#include "atomicdex/services/mm2/auto.update.maker.order.service.hpp"
#include "atomicdex/services/mm2/mm2.service.hpp"

//! Constructor
namespace atomic_dex
{
    auto_update_maker_order_service::auto_update_maker_order_service(entt::registry& registry, ag::ecs::system_manager& system_manager) :
        system(registry), m_system_manager(system_manager)
    {
        m_update_clock = std::chrono::high_resolution_clock::now();
        SPDLOG_INFO("auto_update_maker_order_service created");
    }
} // namespace atomic_dex

//! Private member functions
namespace atomic_dex
{
    void
    auto_update_maker_order_service::update_order(const t_order_swaps_data& data)
    {
        const auto&   mm2               = this->m_system_manager.get_system<mm2_service>();
        const auto    base_coin_info    = mm2.get_coin_info(data.base_coin.toStdString());
        const auto    rel_coin_info     = mm2.get_coin_info(data.rel_coin.toStdString());
        QSettings&    settings          = entity_registry_.ctx<QSettings>();
        const auto    category_settings = data.base_coin + "_" + data.rel_coin;
        const QString target_settings   = "Disabled";
        settings.beginGroup(category_settings);
        const bool is_disabled = settings.value(target_settings, true).toBool();
        settings.endGroup();
        if (base_coin_info.coingecko_id != "test-coin" && rel_coin_info.coingecko_id != "test-coin" && !is_disabled)
        {
            SPDLOG_INFO("Updating maker order: {}", data.order_id.toStdString());
        }
    }

    void
    auto_update_maker_order_service::internal_update()
    {
        SPDLOG_INFO("update maker orders");
        const auto&      mm2  = this->m_system_manager.get_system<mm2_service>();
        orders_and_swaps data = mm2.get_orders_and_swaps();
        auto             cur  = data.orders_and_swaps.cbegin();
        auto             end  = data.orders_and_swaps.cbegin() + data.nb_orders;
        for (; cur != end; ++cur)
        {
            if (cur->is_maker)
            {
                this->update_order(*cur);
            }
        }
    }

    void
    auto_update_maker_order_service::process_update_orders()
    {
        try
        {
            if (this->m_system_manager.has_system<mm2_service>())
            {
                const auto& mm2 = this->m_system_manager.get_system<mm2_service>();
                if (mm2.is_mm2_running())
                {
                    this->internal_update();
                }
                else
                {
                    SPDLOG_WARN("MM2 service is not running yet - skipping");
                }
            }
            else
            {
                SPDLOG_WARN("MM2 service not created yet - skipping");
            }
        }
        catch (const std::exception& error)
        {
            SPDLOG_ERROR("Exception caught: {}", error.what());
        }
    }
} // namespace atomic_dex

//! Public functions override
namespace atomic_dex
{
    void
    auto_update_maker_order_service::update()
    {
        //! Scan orderbook widget every 30 seconds if there is not any update
        using namespace std::chrono_literals;

        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - m_update_clock);
        if (s >= 2min)
        {
            process_update_orders();
            m_update_clock = std::chrono::high_resolution_clock::now();
        }
    }
} // namespace atomic_dex