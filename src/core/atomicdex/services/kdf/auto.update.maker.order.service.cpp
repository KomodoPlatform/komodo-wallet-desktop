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

//! Qt Headers
#include <QSettings>

// Project Headers
#include "atomicdex/api/kdf/rpc_v1/rpc.update_maker_order.hpp"
#include "atomicdex/services/kdf/auto.update.maker.order.service.hpp"
#include "atomicdex/services/kdf/kdf.service.hpp"
#include "atomicdex/services/price/global.provider.hpp"

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
    std::string
    auto_update_maker_order_service::get_new_price_from_order(const t_order_swaps_data& data, const t_float_50& spread)
    {
        const auto& price_service = m_system_manager.get_system<global_price_service>();
        const auto& base          = data.base_coin.toStdString();
        const auto& rel           = data.rel_coin.toStdString();
        const auto& order         = data.order_id.toStdString();
        t_float_50  price         = safe_float(data.rel_amount.toStdString()) / safe_float(data.base_amount.toStdString());
        t_float_50  price_diff(0);
        t_float_50  cex_price   = safe_float(price_service.get_cex_rates(base, rel));
        price_diff              = t_float_50(100) * (t_float_50(1) - price / cex_price) * t_float_50(1);
        t_float_50 percent      = spread / 100;
        t_float_50 target_price = cex_price + (cex_price * percent);
        SPDLOG_INFO("spread of the order {} for {}/{} is: {}%", order, base, rel, utils::format_float(price_diff));
        SPDLOG_INFO("price of the order {} is {} {}", order, utils::format_float(price), rel);
        SPDLOG_INFO("actual cex rates is: 1 {} = {} {}", base, utils::format_float(cex_price), rel);
        SPDLOG_INFO(
            "target price for the updated order is 1 {} = {} {}, target_spread: {}", base, utils::format_float(target_price), rel, utils::format_float(spread));
        return utils::format_float(target_price);
    }

    void
    auto_update_maker_order_service::update_order(const t_order_swaps_data& data)
    {
        const auto&   kdf               = this->m_system_manager.get_system<kdf_service>();
        const auto    base_coin         = data.base_coin.toStdString();
        const auto    rel_coin          = data.rel_coin.toStdString();
        const auto    base_coin_info    = kdf.get_coin_info(base_coin);
        const auto    rel_coin_info     = kdf.get_coin_info(rel_coin);
        QSettings&    settings          = entity_registry_.ctx<QSettings>();
        const auto    category_settings = data.base_coin + "_" + data.rel_coin;
        const QString target_settings   = "Disabled";
        settings.beginGroup(category_settings);
        const bool is_disabled        = settings.value(target_settings, true).toBool();
        t_float_50 spread             = settings.value("Spread", 1.0).toDouble();
        const bool max                = settings.value("Max", false).toBool();
        t_float_50 min_volume_percent = settings.value("MinVolume", 10.0).toDouble() / 100; ///< min volume is always 10% of the order or more
        settings.endGroup();
        if (base_coin_info.coingecko_id != "test-coin" && rel_coin_info.coingecko_id != "test-coin" && !is_disabled)
        {
            SPDLOG_INFO("Updating maker order: {}", data.order_id.toStdString());
            nlohmann::json               batch                   = nlohmann::json::array();
            std::string                  new_price               = get_new_price_from_order(data, spread);
            nlohmann::json               conf_settings           = data.conf_settings.value_or(nlohmann::json());
            nlohmann::json               update_maker_order_json = kdf::template_request("update_maker_order");
            t_float_50                   volume                  = safe_float(data.base_amount.toStdString());
            t_float_50                   min_volume              = volume * min_volume_percent;
            t_update_maker_order_request request{
                .uuid         = data.order_id.toStdString(),
                .new_price    = new_price,
                .max          = max,
                .min_volume   = utils::format_float(min_volume)};
            if (!conf_settings.empty())
            {
                request.base_nota  = conf_settings.at("base_nota").get<bool>();
                request.rel_nota   = conf_settings.at("rel_nota").get<bool>();
                request.base_confs = conf_settings.at("base_confs").get<std::size_t>();
                request.rel_confs  = conf_settings.at("rel_confs").get<std::size_t>();
            }
            kdf::to_json(update_maker_order_json, request);
            batch.push_back(update_maker_order_json);
            update_maker_order_json["userpass"] = "";
            SPDLOG_INFO("request: {}", update_maker_order_json.dump(1));
            auto& kdf = this->m_system_manager.get_system<kdf_service>();
            kdf.get_kdf_client()
                .async_rpc_batch_standalone(batch)
                .then(
                    []([[maybe_unused]] web::http::http_response resp)
                    {
                        if (resp.status_code() != 200)
                        {
                            std::string body = TO_STD_STR(resp.extract_string(true).get());
                            SPDLOG_ERROR("An error occured during update_maker_order (code: {}): {}", resp.status_code(), body);
                        }
                    })
                .then(&handle_exception_pplx_task);
        }
    }

    void
    auto_update_maker_order_service::internal_update()
    {
        SPDLOG_DEBUG("update maker orders");
        const auto&      kdf  = this->m_system_manager.get_system<kdf_service>();
        orders_and_swaps data = kdf.get_orders_and_swaps();
        auto             cur  = data.orders_and_swaps.begin();
        auto             end  = data.orders_and_swaps.begin() + data.nb_orders;
        for (; cur != end && cur != data.orders_and_swaps.end(); ++cur)
        {
            if (cur->is_maker)
            {
                SPDLOG_DEBUG("Updating order: {}", cur->order_id.toStdString());
                this->update_order(*cur);
            }
        }
    }

    void
    auto_update_maker_order_service::process_update_orders()
    {
        try
        {
            if (this->m_system_manager.has_system<kdf_service>())
            {
                const auto& kdf = this->m_system_manager.get_system<kdf_service>();
                if (kdf.is_kdf_running())
                {
                    this->internal_update();
                }
                else
                {
                    SPDLOG_WARN("KDF service is not running yet - skipping");
                }
            }
            else
            {
                SPDLOG_WARN("KDF service not created yet - skipping");
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

    void
    auto_update_maker_order_service::force_update()
    {
        SPDLOG_INFO("Force update");
        this->process_update_orders();
        m_update_clock = std::chrono::high_resolution_clock::now();
    }
} // namespace atomic_dex