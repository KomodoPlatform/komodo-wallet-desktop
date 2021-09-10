#pragma once

#include <nlohmann/json_fwd.hpp>
#include <entt/core/attribute.h>

#include "atomicdex/utilities/cpprestsdk.utilities.hpp"

namespace atomic_dex::komodo_prices::api
{
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
        std::string                          change_24_h;
        provider                             change_24_h_provider;
    };

    void from_json(const nlohmann::json& j, komodo_ticker_infos& x);
    void from_json(const nlohmann::json& j, provider& x);

    using t_komodo_tickers_price_registry = std::unordered_map<std::string, komodo_ticker_infos>;
} // namespace atomicdex::komodo_prices::api

namespace atomic_dex::komodo_prices::api
{
    ENTT_API pplx::task<web::http::http_response> async_market_infos();
}