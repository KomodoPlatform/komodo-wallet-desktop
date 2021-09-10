#pragma once

#include <nlohmann/json.hpp>

#ifndef NLOHMANN_OPT_HELPER_SHARED_PTR
#    define NLOHMANN_OPT_HELPER_SHARED_PTR
namespace nlohmann
{
    template <typename T>
    struct adl_serializer<std::shared_ptr<T>>
    {
        static void
        to_json(json& j, const std::shared_ptr<T>& opt)
        {
            if (!opt)
                j = nullptr;
            else
                j = *opt;
        }

        static std::shared_ptr<T>
        from_json(const json& j)
        {
            if (j.is_null())
                return std::unique_ptr<T>();
            else
                return std::unique_ptr<T>(new T(j.get<T>()));
        }
    };
} // namespace nlohmann
#endif

namespace atomicdex::komodo_prices::api
{
    using nlohmann::json;

    inline json
    get_untyped(const json& j, const char* property)
    {
        if (j.find(property) != j.end())
        {
            return j.at(property).get<json>();
        }
        return json();
    }

    inline json
    get_untyped(const json& j, std::string property)
    {
        return get_untyped(j, property.data());
    }

    template <typename T>
    inline std::shared_ptr<T>
    get_optional(const json& j, const char* property)
    {
        if (j.find(property) != j.end())
        {
            return j.at(property).get<std::shared_ptr<T>>();
        }
        return std::shared_ptr<T>();
    }

    template <typename T>
    inline std::shared_ptr<T>
    get_optional(const json& j, std::string property)
    {
        return get_optional<T>(j, property.data());
    }

    enum class provider : int
    {
        binance,
        coingecko,
        coinpaprika,
        unknown
    };

    struct komodo_ticker_infos
    {
        std::string                          ticker;
        std::string                          last_price;
        std::string                          last_updated;
        int64_t                              last_updated_timestamp;
        std::string                          volume24_h;
        provider                             price_provider;
        provider                             volume_provider;
        std::shared_ptr<std::vector<double>> sparkline_7_d;
        provider                             sparkline_provider;
        std::string                          change_24_h;
        provider                             change_24_h_provider;
    };

    using t_komodo_tickers_price_registry = std::unordered_map<std::string, komodo_ticker_infos>;
} // namespace atomicdex

namespace nlohmann
{
    void from_json(const json& j, atomicdex::komodo_prices::api::komodo_ticker_infos& x);
    void from_json(const json& j, atomicdex::komodo_prices::api::provider& x);

    inline void
    from_json(const json& j, atomicdex::komodo_prices::api::komodo_ticker_infos& x)
    {
        x.ticker                 = j.at("ticker").get<std::string>();
        x.last_price             = j.at("last_price").get<std::string>();
        x.last_updated           = j.at("last_updated").get<std::string>();
        x.last_updated_timestamp = j.at("last_updated_timestamp").get<int64_t>();
        x.volume24_h             = j.at("volume24h").get<std::string>();
        x.price_provider         = j.at("price_provider").get<atomicdex::komodo_prices::api::provider>();
        x.volume_provider        = j.at("volume_provider").get<atomicdex::komodo_prices::api::provider>();
        x.sparkline_7_d          = atomicdex::komodo_prices::api::get_optional<std::vector<double>>(j, "sparkline_7d");
        x.sparkline_provider     = j.at("sparkline_provider").get<atomicdex::komodo_prices::api::provider>();
        x.change_24_h            = j.at("change_24h").get<std::string>();
        x.change_24_h_provider   = j.at("change_24h_provider").get<atomicdex::komodo_prices::api::provider>();
    }

    inline void
    from_json(const json& j, atomicdex::komodo_prices::api::provider& x)
    {
        if (j == "binance")
        {
            x = atomicdex::komodo_prices::api::provider::binance;
        }
        else if (j == "coingecko")
        {
            x = atomicdex::komodo_prices::api::provider::coingecko;
        }
        else if (j == "coinpaprika")
        {
            x = atomicdex::komodo_prices::api::provider::coinpaprika;
        }
        else
        {
            x = atomicdex::komodo_prices::api::provider::unknown;
        }
    }
} // namespace nlohmann

namespace atomic_dex::komodo_prices::api
{
    ENTT_API pplx::task<web::http::http_response> async_market_infos();
}