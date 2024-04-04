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

//! Project Headers
#include "atomicdex/services/price/defi.stats.hpp"
#include "atomicdex/services/price/komodo_prices/komodo.prices.provider.hpp"
#include "atomicdex/pages/qt.settings.page.hpp"
#include "atomicdex/services/price/global.provider.hpp"


//! Constructor
namespace atomic_dex
{
    global_defi_stats_service::global_defi_stats_service(entt::registry& registry, ag::ecs::system_manager& system_manager):
        system(registry), m_system_manager(system_manager)
    {
        SPDLOG_INFO("global_defi_stats_service created");
        m_update_clock = std::chrono::high_resolution_clock::now();
        process_update();
    }
} // namespace atomic_dex

namespace
{
    web::http::client::http_client_config g_defi_stats_cfg{
        [](){
            web::http::client::http_client_config cfg;
            cfg.set_validate_certificates(false);
            cfg.set_timeout(std::chrono::seconds(5));
            return cfg;
        }()
    };

    t_http_client_ptr g_defi_stats_client = std::make_unique<web::http::client::http_client>(FROM_STD_STR("https://defi-stats.komodo.earth/"), g_defi_stats_cfg);
    pplx::cancellation_token_source d_token_source;

    pplx::task<web::http::http_response>
    async_fetch_defi_stats_volumes()
    {
        web::http::http_request req;
        req.set_method(web::http::methods::GET);
        req.set_request_uri(FROM_STD_STR("api/v3/pairs/volumes_24hr"));
        SPDLOG_INFO("defi_stats req: {}", TO_STD_STR(req.to_string()));
        return g_defi_stats_client->request(req, d_token_source.get_token());
    }

    nlohmann::json
    process_fetch_defi_stats_volumes_answer(web::http::http_response resp)
    {
        std::string body = TO_STD_STR(resp.extract_string(true).get());
        if (resp.status_code() == 200)
        {
            nlohmann::json    answer = nlohmann::json::parse(body);
            return answer;
        }
        else
        {
            SPDLOG_WARN("Failed to update defi_stats!");
            return nlohmann::json::array();            
        }
        
    }
} // namespace

namespace atomic_dex
{
    void
    global_defi_stats_service::update()
    {
        using namespace std::chrono_literals;

        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - m_update_clock);
        if (s >= 5min)
        {
            SPDLOG_INFO("[global_defi_stats_service::update()] - 5min elapsed, updating ticker stats");
            process_update();
            m_update_clock = std::chrono::high_resolution_clock::now();
        }
    }

} // namespace atomic_dex


// Events
namespace atomic_dex
{   
    void
    global_defi_stats_service::process_update()
    {
        static std::atomic_size_t nb_try = 0;
        nb_try += 1;
        SPDLOG_INFO("pair volume stats service tick loop");
        auto error_functor = [this](pplx::task<void> previous_task)
        {
            try
            {
                previous_task.wait();
            }
            catch (const std::exception& e)
            {
                SPDLOG_ERROR("pplx task error from async_fetch_ticker_stats: {} - nb_try {}", e.what(), nb_try);
                using namespace std::chrono_literals;
                std::this_thread::sleep_for(1s);
                this->process_update();
            };
        };
        async_fetch_defi_stats_volumes()
            .then(
                [this](web::http::http_response resp)
                {
                    this->m_defi_stats_volumes = process_fetch_defi_stats_volumes_answer(resp);
                    nb_try = 0;
                })
            .then(error_functor);
    }

    std::string
    global_defi_stats_service::get_volume_24h_usd(const std::string& base, const std::string& quote) const
    {
        std::string volume_24h_usd = "0.00";
        auto ticker = base + "_" + quote;
        auto ticker_reversed = quote + "_" + base;
        SPDLOG_INFO("Getting 24hr volume data for {}", ticker);

        // Check if base/quote are the same
        if (base == quote)
        {
            SPDLOG_INFO("Base/quote must be different, no volume data for {}", ticker);
            return volume_24h_usd;
        }

        // Check if defi_stats_volumes is valid
        auto defi_stats_volumes = m_defi_stats_volumes.get();
        if (!defi_stats_volumes.is_object())
        {
            SPDLOG_WARN("Invalid defi stats volumes data.");
            return volume_24h_usd;
        }
        
        // Check if volumes key exists
        if (!defi_stats_volumes.contains("volumes"))
        {
            SPDLOG_WARN("No volumes data available.");
            return volume_24h_usd;
        }

        // Extract ticker trade_volume_usd safely
        if (defi_stats_volumes.at("volumes").contains(ticker))
        {
            auto volume_node = defi_stats_volumes["volumes"][ticker]["ALL"]["trade_volume_usd"];
            if (volume_node.is_number())
            {
                volume_24h_usd = std::to_string(volume_node.get<double>());
                SPDLOG_INFO("{} volume usd: {}", ticker, volume_24h_usd);
            }
            else if (volume_node.is_null()) 
            {
                SPDLOG_WARN("Volume value is null for {}", ticker);
            }
            else
            {
                SPDLOG_WARN("Volume value is not a number for {}: {}", ticker, volume_node.type_name());
            }
        }
        else if (defi_stats_volumes["volumes"].contains(ticker_reversed))
        {
            auto volume_node = defi_stats_volumes["volumes"][ticker_reversed]["ALL"]["trade_volume_usd"];
            if (volume_node.is_number())
            {
                volume_24h_usd = std::to_string(volume_node.get<double>());
                SPDLOG_INFO("{} volume usd: {}", ticker_reversed, volume_24h_usd);
            }
            else if (volume_node.is_null()) 
            {
                SPDLOG_WARN("Volume value is null for {}", ticker);
            }
            else
            {
                SPDLOG_WARN("Volume value is not a number for {}: {}", ticker, volume_node.type_name());
            }
        }
        else
        {
            SPDLOG_WARN("No volume data available for {}", ticker);
        }
        return volume_24h_usd;
    }

    std::string
    global_defi_stats_service::get_trades_24h(const std::string& base, const std::string& quote) const
    {
        std::string trades_24h = "0";
        auto ticker = base + "_" + quote;
        auto ticker_reversed = quote + "_" + base;
        SPDLOG_INFO("Getting 24hr trade data for {}", ticker);

        // Check if base/quote are the same
        if (base == quote)
        {
            SPDLOG_INFO("Base/quote must be different, no volume data for {}", ticker);
            return trades_24h;
        }

        // Check if defi_stats_volumes is valid
        auto defi_stats_volumes = m_defi_stats_volumes.get();
        if (!defi_stats_volumes.is_object())
        {
            SPDLOG_WARN("Invalid defi stats volumes data.");
            return trades_24h;
        }
        
        // Check if volumes key exists
        if (!defi_stats_volumes.contains("volumes"))
        {
            SPDLOG_WARN("No volumes data available.");
            return trades_24h;
        }

        // Extract ticker trade_volume_usd safely
        if (defi_stats_volumes.at("volumes").contains(ticker))
        {
            auto trades_node = defi_stats_volumes["volumes"][ticker]["ALL"]["trades_24hr"];
            if (trades_node.is_number())
            {
                trades_24h = std::to_string(trades_node.get<int>());
                SPDLOG_INFO("{} trades_24h: {}", ticker, trades_24h);
            }
            else if (trades_node.is_null()) 
            {
                SPDLOG_WARN("Trades value is null for {}", ticker);
            }
            else
            {
                SPDLOG_WARN("Trades value is not a number for {}: {}", ticker, trades_node.type_name());
            }
        }
        else if (defi_stats_volumes["volumes"].contains(ticker_reversed))
        {
            auto trades_node = defi_stats_volumes["volumes"][ticker_reversed]["ALL"]["trades_24hr"];
            if (trades_node.is_number())
            {
                trades_24h = std::to_string(trades_node.get<int>());
                SPDLOG_INFO("{} trades_24h: {}", ticker_reversed, trades_24h);
            }
            else if (trades_node.is_null()) 
            {
                SPDLOG_WARN("Trades value is null for {}", ticker);
            }
            else
            {
                SPDLOG_WARN("Trades value is not a number for {}: {}", ticker, trades_node.type_name());
            }
        }
        else
        {
            SPDLOG_WARN("No trades data available for {}", ticker);
        }
        return trades_24h;
    }
} // namespace atomic_dex
