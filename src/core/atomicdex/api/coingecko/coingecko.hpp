#pragma once

#include <string>
#include <unordered_map>
#include <vector>

//! Deps
#include <entt/core/attribute.h>

//! Project Headers
#include "atomicdex/config/coins.cfg.hpp"
#include "atomicdex/utilities/cpprestsdk.utilities.hpp"

namespace atomic_dex::coingecko::api
{
    struct market_chart_request
    {
        std::string                id;
        std::string                vs_currency{"usd"};
        std::string                days;
        std::optional<std::string> interval{std::nullopt};
    };

    struct market_chart_request_range
    {
        std::string id;
        std::string vs_currency{"usd"};
        std::string from;
        std::string to;
    };

    struct market_infos_request
    {
        std::string              vs_currency{"usd"};
        std::vector<std::string> ids; ///< eg: ["bitcoin", "komodo"]
        std::string              order{"market_cap_desc"};
        std::size_t              per_page{250};
        std::size_t              current_page{1};
        bool                     with_sparkline{true};
        std::string              price_change_percentage{"24h"};
    };

    struct single_infos_answer
    {
        std::string    price_change_24h;
        std::string    current_price;
        std::string    total_volume;
        nlohmann::json sparkline_in_7d{nlohmann::json::array()};
    };

    void from_json(const nlohmann::json& j, single_infos_answer& answer);

    struct market_infos_answer
    {
        std::unordered_map<std::string, single_infos_answer> result;
        int                                                  rpc_result_code;
        std::string                                          raw_result;
    };

    using t_coingecko_registry = std::unordered_map<std::string, std::string>;
    void from_json(const nlohmann::json& j, market_infos_answer& answer, const t_coingecko_registry& registry);

    ENTT_API std::string to_coingecko_uri(market_infos_request&& request);
    ENTT_API std::string to_coingecko_uri(market_chart_request&& request);
    ENTT_API std::string to_coingecko_uri(market_chart_request_range&& request);
    using t_coins_registry = std::unordered_map<std::string, coin_config>;
    ENTT_API std::pair<std::vector<std::string>, t_coingecko_registry> from_enabled_coins(const std::vector<coin_config>& coins);

    ENTT_API pplx::task<web::http::http_response> async_market_infos(market_infos_request&& request);
    ENTT_API pplx::task<web::http::http_response> async_market_charts(market_chart_request&& request);
    ENTT_API pplx::task<web::http::http_response> async_market_charts_range(market_chart_request_range&& request);

} // namespace atomic_dex::coingecko::api

namespace atomic_dex
{
    using t_coingecko_market_infos_request       = coingecko::api::market_infos_request;
    using t_coingecko_market_chart_request       = coingecko::api::market_chart_request;
    using t_coingecko_market_chart_range_request = coingecko::api::market_chart_request_range;
    using t_coingecko_market_infos_answer        = coingecko::api::market_infos_answer;
} // namespace atomic_dex