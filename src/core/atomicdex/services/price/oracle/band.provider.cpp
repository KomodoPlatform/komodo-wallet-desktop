//! Project Headers
#include "band.provider.hpp"

namespace atomic_dex
{
    band_oracle_price_service::band_oracle_price_service(entt::registry& registry) : system(registry)
    {
        m_update_clock = std::chrono::high_resolution_clock::now();
        fetch_oracle();
    }

    void
    from_json(const nlohmann::json& j, band_oracle_price_result& result)
    {
        for (auto&& obj: j.at("result"))
        {
            std::string       symbol     = obj.at("symbol").get<std::string>();
            t_float_50        px         = t_float_50(obj.at("px").get<std::string>());
            t_float_50        multiplier = t_float_50(obj.at("multiplier").get<std::string>());
            t_float_50        price      = px / multiplier;
            std::stringstream sstream(obj.at("resolve_time").get<std::string>());
            std::size_t       timestamp;
            sstream >> timestamp;
            result.band_oracle_data[symbol].timestamp = timestamp;
            result.band_oracle_data[symbol].reference = "https://guanyu-poa.cosmoscan.io/request/" + obj.at("request_id").get<std::string>();
            result.band_oracle_data[symbol].price     = price;
            t_float_50 rates                          = t_float_50("1") / price;
            result.band_oracle_data[symbol].rate      = rates;
        }
    }
} // namespace atomic_dex

namespace atomic_dex
{
    pplx::task<web::http::http_response>
    band_oracle_price_service::async_fetch_oracle_result() 
    {
        web::http::http_request req;
        req.set_method(web::http::methods::POST);
        nlohmann::json json_body;
        json_body["min_count"] = 10;
        json_body["ask_count"] = 16;
        json_body["symbols"]   = nlohmann::json::array();
        for (auto&& cur_symbol: this->m_supported_tickers) { json_body["symbols"].push_back(cur_symbol); }
        req.headers().set_content_type(FROM_STD_STR("application/json"));
        // SPDLOG_INFO("req: {}", json_body.dump(4));
        req.set_body(json_body.dump());
        return m_band_http_client->request(req);
    }

    void
    band_oracle_price_service::fetch_oracle() 
    {
        SPDLOG_INFO("start fetching oracle");
        async_fetch_oracle_result()
            .then([this](web::http::http_response resp) {
                auto body = TO_STD_STR(resp.extract_string(true).get());
                if (resp.status_code() == 200)
                {
                    nlohmann::json           j = nlohmann::json::parse(body);
                    band_oracle_price_result result;
                    from_json(j, result);
                    this->m_oracle_price_result = result;
                    using namespace std::chrono_literals;
                    auto       last_oracle_timestamp     = result.band_oracle_data.at("BAND").timestamp;
                    const auto now                       = std::chrono::system_clock::now();
                    const auto last_oracle_timestamp_std = std::chrono::system_clock::from_time_t(last_oracle_timestamp);
                    const auto s                         = std::chrono::duration_cast<std::chrono::seconds>(now - last_oracle_timestamp_std);
                    this->m_oracle_ready                 = s > 20min ? false : true;
                    if (s > 20min)
                    {
                        SPDLOG_WARN(
                            "last oracle too much outdated: {}, fallback to coinpaprika",
                            utils::to_human_date<std::chrono::seconds>(last_oracle_timestamp, "%e %b %Y, %H:%M"));
                    }
                    this->dispatcher_.trigger<band_oracle_refreshed>();
                }
                else
                {
                    SPDLOG_ERROR("Cannot fetch oracle price: {}", body);
                }
            })
            .then(&handle_exception_pplx_task);
    }
} // namespace atomic_dex

namespace atomic_dex
{
    void
    band_oracle_price_service::update() 
    {
        using namespace std::chrono_literals;

        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - m_update_clock);
        if (s >= 5min)
        {
            fetch_oracle();
            m_update_clock = std::chrono::high_resolution_clock::now();
        }
    }

    bool
    band_oracle_price_service::is_oracle_ready() const 
    {
        return this->m_oracle_ready.load();
    }

    std::string
    band_oracle_price_service::retrieve_if_this_ticker_supported(const std::string& ticker) const 
    {
        std::string current_price = "";
        if (is_oracle_ready())
        {
            const auto result = m_oracle_price_result.synchronize();
            const auto it     = result->band_oracle_data.find(ticker);
            if (it != result->band_oracle_data.end())
            {
                current_price = it->second.price.str();
            }
        }
        return current_price;
    }

    t_float_50
    band_oracle_price_service::retrieve_rates(const std::string& fiat) const 
    {
        const auto synchronized = m_oracle_price_result.synchronize();
        return synchronized->band_oracle_data.at(fiat).rate;
    }

    std::vector<std::string>
    band_oracle_price_service::supported_pair() const 
    {
        std::vector<std::string> out;
        out.reserve(this->m_supported_tickers.size());
        for (auto&& cur_symbol: this->m_supported_tickers) { out.emplace_back(cur_symbol + "/USD"); }
        return out;
    }

    std::string
    band_oracle_price_service::last_oracle_reference() const 
    {
        return "";
    }
} // namespace atomic_dex
