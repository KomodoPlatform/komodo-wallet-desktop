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

//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "faucet.hpp"

namespace
{
    inline constexpr const char*    g_faucet_api_endpoint   = "https://faucet.komodo.live/faucet/";
    inline auto                     g_faucet_api_client     = std::make_unique<web::http::client::http_client>(FROM_STD_STR(g_faucet_api_endpoint));
}

namespace atomic_dex::faucet::api
{
    pplx::task<web::http::http_response>
    claim(claim_request& claim_req)
    {
        web::http::http_request http_request;
        web::uri_builder        uri_builder;
    
        uri_builder.append_path(FROM_STD_STR(claim_req.coin_name));
        uri_builder.append_path(FROM_STD_STR(claim_req.wallet_address));
        http_request.set_request_uri(uri_builder.to_uri());
        http_request.set_method(web::http::methods::GET);
        return g_faucet_api_client->request(http_request);
    }
}