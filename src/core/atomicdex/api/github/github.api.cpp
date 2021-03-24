// Deps headers
#include <nlohmann/json.hpp>
#include <antara/app/net/http.code.hpp>

// Project headers
#include "github.api.hpp"

namespace atomic_dex::github_api
{
    const std::string base_remote_url{"https://api.github.com/"};
    const auto api_client = std::make_unique<web::http::client::http_client>(FROM_STD_STR(base_remote_url));

    pplx::task<web::http::http_response> get_repository_releases_async(const repository_releases_request& request)
    {
        web::http::http_request http_request;
        web::uri_builder        uri_builder;
    
        uri_builder.append_path(FROM_STD_STR(request.owner));
        uri_builder.append_path(FROM_STD_STR(request.repository));
        uri_builder.append_path(FROM_STD_STR("releases"));
        http_request.set_request_uri(uri_builder.to_uri());
        http_request.set_method(web::http::methods::GET);
        return api_client->request(http_request);
    }
    
    std::vector<repository_release> get_repository_releases_from_http_response(const web::http::http_response& resp)
    {
        std::vector<repository_release> result;
        const auto json_answer = nlohmann::json::parse(TO_STD_STR(resp.extract_string(true).get()));
        
        result.reserve(json_answer.size());
        for (auto& release_obj : json_answer)
        {
            result.push_back(repository_release{
                                .url        = release_obj.at("url"),
                                .assets_url = release_obj.at("assets_url"),
                                .name       = release_obj.at("name"),
                                .tag_name   = release_obj.at("tag_name")});
        }
        return result;
    }
    
    repository_release get_last_repository_release_from_http_response(const web::http::http_response& resp)
    {
        const auto json_answer = nlohmann::json::parse(TO_STD_STR(resp.extract_string(true).get()));
        
        return json_answer.empty() ? repository_release{} :
                                     repository_release{.url        = json_answer.at(0).at("url"), .assets_url = json_answer.at(0).at("assets_url"),
                                                        .name       = json_answer.at(0).at("name"), .tag_name   = json_answer.at(0).at("tag_name")};
    }
}
