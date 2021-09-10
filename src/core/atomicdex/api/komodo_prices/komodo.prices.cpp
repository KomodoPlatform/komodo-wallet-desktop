//
// Created by Sztergbaum Roman on 09/09/2021.
//

#include "atomicdex/api/komodo_prices/komodo.prices.hpp"

namespace
{
    constexpr const char* g_komodo_prices_endpoint = "http://95.217.208.239:1313";
    web::http::client::http_client_config g_komodo_prices_cfg{[]()
                                                {
                                                    web::http::client::http_client_config cfg;
                                                    cfg.set_validate_certificates(false);
                                                    cfg.set_timeout(std::chrono::seconds(30));
                                                    return cfg;
                                                }()};
    t_http_client_ptr                     g_komodo_prices_client = std::make_unique<web::http::client::http_client>(FROM_STD_STR(g_komodo_prices_endpoint), g_komodo_prices_cfg);
}

namespace atomic_dex::komodo_prices::api
{
    pplx::task<web::http::http_response>
    async_market_infos()
    {
        web::http::http_request req;
        req.set_method(web::http::methods::GET);
        SPDLOG_INFO("url: {}", TO_STD_STR(g_komodo_prices_client->base_uri().to_string()) + "/api/v1/tickers");
        req.set_request_uri(FROM_STD_STR("/api/v1/tickers"));
        return g_komodo_prices_client->request(req);
    }
}
