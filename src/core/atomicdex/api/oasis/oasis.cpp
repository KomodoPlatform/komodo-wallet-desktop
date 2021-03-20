//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/api/oasis/oasis.hpp"

namespace
{
    const std::string g_oasis_testing_endpoint = "https://api-sandbox.nimiqoasis.com/v1";
    const std::string g_oasis_endpoint         = "https://api-sandbox.nimiqoasis.com/v1"; ///< will change when official API is released
    t_http_client_ptr g_oasis_testing_client   = std::make_unique<web::http::client::http_client>(FROM_STD_STR(g_oasis_testing_endpoint));
    t_http_client_ptr g_oasis_client           = std::make_unique<web::http::client::http_client>(FROM_STD_STR(g_oasis_endpoint));
} // namespace

namespace atomic_dex::oasis::api
{
    pplx::task<web::http::http_response>
    create_htlc(hashed_timed_lock_contract&& htlc_request, bool is_testing)
    {
        web::http::http_request req;
        req.set_method(web::http::methods::POST);
        nlohmann::json json_body;
        to_json(json_body, htlc_request);
        req.headers().set_content_type(FROM_STD_STR("application/json"));
        SPDLOG_INFO("req: {}", json_body.dump(4));
        req.set_body(json_body.dump());
        req.set_request_uri("/htlc");

        return is_testing ? g_oasis_testing_client->request(req) : g_oasis_client->request(req);
    }
} // namespace atomic_dex::oasis::api
