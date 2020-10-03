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
#include "atomic.dex.pch.hpp"

//! Project headers
#include "atomic.dex.qt.ip.checker.service.hpp"

namespace
{
    web::http::client::http_client_config g_cfg{[]() {
        web::http::client::http_client_config cfg;
        cfg.set_timeout(std::chrono::seconds(5));
        return cfg;
    }()};

    t_http_client_ptr g_ip_proxy_client{std::make_unique<web::http::client::http_client>(FROM_STD_STR("https://komodo.live:3335"), g_cfg)};
    t_http_client_ptr g_ipify_client{std::make_unique<web::http::client::http_client>(FROM_STD_STR("https://api.ipify.org"), g_cfg)};

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

//! Constructor
namespace atomic_dex
{
    ip_service_checker::ip_service_checker(entt::registry& registry, QObject* parent) : QObject(parent), system(registry) {}
} // namespace atomic_dex

//! Override
namespace atomic_dex
{
    void
    ip_service_checker::update() noexcept
    {
    }

    bool
    ip_service_checker::is_my_ip_authorized() const noexcept
    {
        return m_external_ip_authorized.load();
    }
} // namespace atomic_dex