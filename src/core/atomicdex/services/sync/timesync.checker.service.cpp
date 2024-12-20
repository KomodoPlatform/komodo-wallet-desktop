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

#include <nlohmann/json.hpp>
#include "atomicdex/services/sync/timesync.checker.service.hpp"
#include "atomicdex/utilities/cpprestsdk.utilities.hpp"

namespace
{
    constexpr const char* g_timesync_endpoint = "https://worldtimeapi.org";
    web::http::client::http_client_config g_timesync_cfg{[]()
                                                          {
                                                              web::http::client::http_client_config cfg;
                                                              cfg.set_validate_certificates(false);
                                                              cfg.set_timeout(std::chrono::seconds(5));
                                                              return cfg;
                                                          }()};
    t_http_client_ptr g_timesync_client = std::make_unique<web::http::client::http_client>(FROM_STD_STR(g_timesync_endpoint), g_timesync_cfg);
    pplx::cancellation_token_source g_synctoken_source;

    pplx::task<web::http::http_response>
    async_fetch_timesync()
    {
        web::http::http_request req;
        req.set_method(web::http::methods::GET);
        req.set_request_uri(FROM_STD_STR("api/timezone/UTC"));
        return g_timesync_client->request(req, g_synctoken_source.get_token());
    }

    bool get_timesync_info_rpc(web::http::http_response resp_http)
    {
        using namespace std::string_literals;
        nlohmann::json   resp;
        bool             sync_ok = true;
        std::string      resp_str = TO_STD_STR(resp_http.extract_string(true).get());
        if (resp_http.status_code() != 200)
        {
            SPDLOG_ERROR("Cannot reach the endpoint [{}]: {}", g_timesync_endpoint, resp_str);
        }
        else
        {
            resp = nlohmann::json::parse(resp_str);            
            int64_t   epoch_ts    = resp["unixtime"];
            int64_t   current_ts  = std::chrono::duration_cast<std::chrono::seconds>(std::chrono::system_clock::now().time_since_epoch()).count();
            int64_t   ts_diff = epoch_ts - current_ts;
            if (abs(ts_diff) > 60)
            {
                SPDLOG_WARN("Time sync failed! Actual: {}, System: {}, Diff: {}", epoch_ts, current_ts, ts_diff);
                sync_ok = false;
            }
        }
        return sync_ok;
    }
} // namespace


namespace atomic_dex
{
    timesync_checker_service::timesync_checker_service(entt::registry& registry, QObject* parent) : QObject(parent), system(registry)
    {
        m_timesync_clock  = std::chrono::high_resolution_clock::now();
        m_timesync_status = true;
        fetch_timesync_status();
    }

    void timesync_checker_service::update() 
    {
        using namespace std::chrono_literals;

        int64_t m_timesync_clock_ts = std::chrono::duration_cast<std::chrono::seconds>(m_timesync_clock.time_since_epoch()).count();
        int64_t now_ts   = std::chrono::duration_cast<std::chrono::seconds>(std::chrono::system_clock::now().time_since_epoch()).count();
        int64_t ts_diff  = now_ts - m_timesync_clock_ts;
        if (abs(ts_diff) > 300)
        {
            if (!m_timesync_status)
            {
                fetch_timesync_status();
                m_timesync_clock = std::chrono::high_resolution_clock::now();
            }
        }
    }

    void timesync_checker_service::fetch_timesync_status() 
    {
        SPDLOG_INFO("Checking system time is in sync...");
        if (is_timesync_fetching)
        {
            SPDLOG_WARN("Already checking timesync, returning");
            return;
        }
        is_timesync_fetching = true;
        emit isTimesyncFetchingChanged();
        async_fetch_timesync()
            .then([this](web::http::http_response resp) {
                bool is_timesync_ok = get_timesync_info_rpc(resp);
                SPDLOG_INFO("System time is in sync: {}", is_timesync_ok);
                
                if (is_timesync_ok != *m_timesync_status)
                {
                    this->m_timesync_status = is_timesync_ok;
                    emit timesyncInfoChanged();
                }
            })
            .then(&handle_exception_pplx_task);
        is_timesync_fetching = false;
        emit isTimesyncFetchingChanged();
    }

    bool timesync_checker_service::get_timesync_info() const 
    {
        return *m_timesync_status;
    }

} // namespace atomic_dex

            

