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

//! PCH
#include "src/atomicdex/pch.hpp"

//! Deps
#include <nlohmann/json.hpp>

//! Our project
#include "atomicdex/utilities/cpprestsdk.utilities.hpp"
#include "internet.checker.service.hpp"
#include "src/atomicdex/utilities/qt.utilities.hpp"

namespace
{
    web::http::client::http_client_config g_cfg{[]() {
        web::http::client::http_client_config cfg;
        cfg.set_timeout(std::chrono::seconds(5));
        return cfg;
    }()};
    t_http_client_ptr g_google_proxy_http_client{std::make_unique<web::http::client::http_client>(FROM_STD_STR("https://www.google.com"), g_cfg)};
    t_http_client_ptr g_paprika_proxy_http_client{std::make_unique<web::http::client::http_client>(FROM_STD_STR("https://api.coinpaprika.com"), g_cfg)};
    t_http_client_ptr g_ohlc_proxy_http_client{std::make_unique<web::http::client::http_client>(FROM_STD_STR("https://komodo.live:3333"), g_cfg)};

    pplx::task<web::http::http_response>
    async_check_retrieve(t_http_client_ptr& client, const std::string& uri)
    {
        web::http::http_request req;
        req.set_method(web::http::methods::GET);
        if (not uri.empty())
        {
            req.set_request_uri(FROM_STD_STR(uri));
        }
        return client->request(req);
    }
} // namespace

//! QT Properties
namespace atomic_dex
{
    void
    atomic_dex::internet_service_checker::set_internet_alive(bool internet_status) noexcept
    {
        if (internet_status == true)
        {
            spdlog::info("fetching internet status finished, internet status is: {}", true);
        }
        if (internet_status != is_internet_reacheable)
        {
            is_internet_reacheable = internet_status;
            emit internetStatusChanged();
        }
    }

    bool
    atomic_dex::internet_service_checker::is_internet_alive() const noexcept
    {
        return is_internet_reacheable.load();
    }

    double
    atomic_dex::internet_service_checker::get_seconds_left_to_auto_retry() const noexcept
    {
        return m_timer;
    }

    void
    atomic_dex::internet_service_checker::set_seconds_left_to_auto_retry(double time_left) noexcept
    {
        m_timer = time_left;
        emit secondsLeftToAutoRetryChanged();
    }
} // namespace atomic_dex

namespace atomic_dex
{
    internet_service_checker::internet_service_checker(entt::registry& registry, QObject* parent) : QObject(parent), system(registry)
    {
        //! Init
        retry();
    }

    void
    atomic_dex::internet_service_checker::retry() noexcept
    {
        using namespace std::chrono_literals;
        m_update_clock = std::chrono::high_resolution_clock::now();
        set_seconds_left_to_auto_retry(15.0);
        this->fetch_internet_connection();
    }

    void
    internet_service_checker::update() noexcept
    {
        using namespace std::chrono_literals;

        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - m_update_clock);
        set_seconds_left_to_auto_retry(15.0 - s.count());
        if (s >= 15s)
        {
            this->fetch_internet_connection();
            m_update_clock = std::chrono::high_resolution_clock::now();
            set_seconds_left_to_auto_retry(15.0);
        }
    }

    void
    internet_service_checker::query_internet(t_http_client_ptr& client, const std::string uri, std::atomic_bool internet_service_checker::*p) noexcept
    {
        async_check_retrieve(client, uri)
            .then([this, p](web::http::http_response resp) {
                bool res = resp.status_code() == 200;
                this->*p = res;
                if (res)
                {
                    this->set_internet_alive(true);
                }
            })
            .then([this](pplx::task<void> previous_task) {
                try
                {
                    previous_task.wait();
                }
                catch (const std::exception& e)
                {
                    spdlog::error("pplx task error: {}, setting internet to false", e.what());
                    this->set_internet_alive(false);
                }
            });
    }


    void
    internet_service_checker::fetch_internet_connection()
    {
        spdlog::info("fetching internet status begin");

        query_internet(g_google_proxy_http_client, "", &internet_service_checker::is_google_reacheable);
        query_internet(g_paprika_proxy_http_client, "/v1/coins/btc-bitcoin", &internet_service_checker::is_paprika_provider_alive);
        query_internet(g_ohlc_proxy_http_client, "/api/v1/ohlc/tickers_list", &internet_service_checker::is_our_private_endpoint_reacheable);
    }
} // namespace atomic_dex
