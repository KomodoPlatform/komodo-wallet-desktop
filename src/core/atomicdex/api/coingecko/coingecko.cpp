//
// Created by Roman Szterg on 09/02/2021.
//

//! Deps
#include <boost/algorithm/string/case_conv.hpp>
#include <boost/algorithm/string/replace.hpp>
#include <range/v3/view.hpp>
#include <spdlog/spdlog.h>

//! Project headers
#include "atomicdex/api/coingecko/coingecko.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

namespace
{
    //! Constants
    constexpr const char*                 g_coingecko_endpoint = "https://api.coingecko.com/api/v3";
    constexpr const char*                 g_coingecko_base_uri{"/coins/markets"};
    web::http::client::http_client_config g_cfg{[]()
                                                {
                                                    web::http::client::http_client_config cfg;
                                                    cfg.set_validate_certificates(false);
                                                    cfg.set_timeout(std::chrono::seconds(30));
                                                    return cfg;
                                                }()};
    t_http_client_ptr                     g_coingecko_client = std::make_unique<web::http::client::http_client>(FROM_STD_STR(g_coingecko_endpoint), g_cfg);

} // namespace

namespace atomic_dex::coingecko::api
{
    std::string
    to_coingecko_uri(market_chart_request&& request)
    {
        std::string uri = "/coins/" + request.id + "/market_chart?vs_currency=" + request.vs_currency + "&days=" + request.days;
        if (request.interval.has_value())
        {
            uri.append("&interval=");
            uri.append(request.interval.value());
        }
        return uri;
    }

    std::string
    to_coingecko_uri(market_chart_request_range&& request)
    {
        // https://api.coingecko.com/api/v3/coins/bitcoin/market_chart/range?vs_currency=usd&from=1392577232&to=1422577232
        std::string uri = "/coins/" + request.id + "/market_chart/range?vs_currency=" + request.vs_currency + "&from=" + request.from + "&to=" + request.to;
        return uri;
    }

    ENTT_API std::string
             to_coingecko_uri(market_infos_request&& request)
    {
        std::string uri = g_coingecko_base_uri;
        uri.append("?vs_currency=");
        uri.append(request.vs_currency);
        uri.append("&ids=");
        using ranges::views::ints;
        using ranges::views::zip;
        auto fill_list_functor = [](auto&& container, auto& uri)
        {
            for (auto&& [cur_quote, idx]: zip(container, ints(0u, ranges::unreachable)))
            {
                uri.append(cur_quote);

                //! Append only if not last element, idx start at 0, if idx + 1 == quotes.size(), we are on the last elemnt, we don't append.
                if (idx < container.size() - 1)
                {
                    uri.append(",");
                }
            }
        };

        auto fill_single_field_functor = [&uri](const std::string& field_name, auto&& value)
        {
            uri.append(field_name);
            if constexpr (std::is_same_v<std::string, std::remove_cv_t<std::remove_reference_t<decltype(value)>>>)
            {
                uri.append(value);
            }
            else if constexpr (std::is_same_v<bool, std::remove_cv_t<std::remove_reference_t<decltype(value)>>>)
            {
                std::string underlying_value = value ? "true" : "false";
                uri.append(underlying_value);
            }
            else if constexpr (std::is_same_v<std::size_t, std::remove_cv_t<std::remove_reference_t<decltype(value)>>>)
            {
                std::string underlying_value = std::to_string(value);
                uri.append(underlying_value);
            }
        };

        fill_list_functor(request.ids, uri);
        fill_single_field_functor("&order=", request.order);
        // fill_single_field_functor("&per_page=", request.per_page);
        // fill_single_field_functor("&page=", request.current_page);
        fill_single_field_functor("&sparkline=", request.with_sparkline);
        fill_single_field_functor("&price_change_percentage=", request.price_change_percentage);
        // SPDLOG_TRACE("atomic_dex::coingecko::api uri: {}", uri);
        return uri;
    }

    std::pair<std::vector<std::string>, t_coingecko_registry>
    from_enabled_coins(const std::vector<coin_config>& coins)
    {
        std::vector<std::string> out;
        t_coingecko_registry     registry;

        for (auto&& coin: coins)
        {
            // SPDLOG_INFO("coin: {}", coin.coingecko_id);
            if (coin.coingecko_id != "test-coin")
            {
                if (registry.find(coin.coingecko_id) == registry.end())
                {
                    registry[coin.coingecko_id] = ::atomic_dex::utils::retrieve_main_ticker(coin.ticker);
                    out.emplace_back(coin.coingecko_id);
                }
            }
        }

        return {out, registry};
    }

    void
    from_json(const nlohmann::json& j, single_infos_answer& answer)
    {
        if (!j.at("current_price").is_null())
        {
            answer.current_price = std::to_string(j.at("current_price").get<double>());
        }
        else
        {
            answer.current_price = "0";
        }
        boost::algorithm::replace_all(answer.current_price, ",", ".");
        if (!j.at("total_volume").is_null())
        {
            answer.total_volume = std::to_string(j.at("total_volume").get<double>());
        }
        else
        {
            answer.total_volume = "0";
        }
        boost::algorithm::replace_all(answer.total_volume, ",", ".");
        if (!j.at("price_change_percentage_24h").is_null())
        {
            std::ostringstream ss;
            ss << std::setprecision(2) << j.at("price_change_percentage_24h").get<double>();
            answer.price_change_24h = ss.str();
        }
        else
        {
            answer.price_change_24h = "0";
        }
        boost::algorithm::replace_all(answer.price_change_24h, ",", ".");
        j.at("sparkline_in_7d").at("price").get_to(answer.sparkline_in_7d);
    }

    void
    from_json(const nlohmann::json& j, market_infos_answer& answer, const t_coingecko_registry& registry)
    {
        answer.result.reserve(j.size());
        for (auto&& cur_json_obj: j)
        {
            try
            {
                answer.result[registry.at(cur_json_obj.at("id").get<std::string>())] = cur_json_obj.get<single_infos_answer>();
            }
            catch (const std::exception& error)
            {
                SPDLOG_ERROR("Error when treating coingecko answer: {} - error: {}", cur_json_obj.dump(1), error.what());
            }
        }
    }

    ENTT_API pplx::task<web::http::http_response>
             async_market_infos(market_infos_request&& request)
    {
        web::http::http_request req;
        req.set_method(web::http::methods::GET);
        std::string url = to_coingecko_uri(std::move(request));
        SPDLOG_INFO("url: {}", TO_STD_STR(g_coingecko_client->base_uri().to_string()) + url);
        // SPDLOG_INFO("processing coingecko prices");
        req.set_request_uri(FROM_STD_STR(url));
        return g_coingecko_client->request(req);
    }

    pplx::task<web::http::http_response>
    async_market_charts(market_chart_request&& request)
    {
        web::http::http_request req;
        req.set_method(web::http::methods::GET);
        std::string url = to_coingecko_uri(std::move(request));
        SPDLOG_INFO("url: {}", TO_STD_STR(g_coingecko_client->base_uri().to_string()) + url);
        req.set_request_uri(FROM_STD_STR(url));
        return g_coingecko_client->request(req);
    }

    pplx::task<web::http::http_response>
    async_market_charts_range(market_chart_request_range&& request)
    {
        web::http::http_request req;
        req.set_method(web::http::methods::GET);
        std::string url = to_coingecko_uri(std::move(request));
        SPDLOG_INFO("url: {}", TO_STD_STR(g_coingecko_client->base_uri().to_string()) + url);
        req.set_request_uri(FROM_STD_STR(url));
        return g_coingecko_client->request(req);
    }
} // namespace atomic_dex::coingecko::api
