//! PCH Headers
#include "src/atomicdex/pch.hpp"

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
        j.at("timestamp").get_to(result.timestamp);
        j.at("reference").get_to(result.reference);
        for (auto&& [key, value]: j.at("prices").items())
        {
            t_float_50 price   = value.get<double>();
            result.prices[key] = price;
            t_float_50 rates   = t_float_50("1") / price;
            result.rates[key]  = rates;
        }
    }
} // namespace atomic_dex

namespace atomic_dex
{
    pplx::task<web::http::http_response>
    band_oracle_price_service::async_fetch_oracle_result() noexcept
    {
        web::http::http_request req;
        req.set_method(web::http::methods::GET);
        return m_band_http_client->request(req);
    }

    void
    band_oracle_price_service::fetch_oracle() noexcept
    {
        spdlog::info("start fetching oracle");
        async_fetch_oracle_result()
            .then([this](web::http::http_response resp) {
                if (resp.status_code() == 200)
                {
                    spdlog::info("band oracle successfully fetched");
                    auto                     body = TO_STD_STR(resp.extract_string(true).get());
                    nlohmann::json           j    = nlohmann::json::parse(body);
                    band_oracle_price_result result;
                    from_json(j, result);
                    this->m_oracle_price_result.insert_or_assign("result", result);
                    using namespace std::chrono_literals;
                    auto       last_oracle_timestamp     = result.timestamp;
                    const auto now                       = std::chrono::system_clock::now();
                    const auto last_oracle_timestamp_std = std::chrono::system_clock::from_time_t(last_oracle_timestamp);
                    const auto s                         = std::chrono::duration_cast<std::chrono::seconds>(now - last_oracle_timestamp_std);
                    this->m_oracle_ready                 = s > 20min ? false : true;
                    if (s > 20min)
                    {
                        spdlog::warn(
                            "last oracle too much outdated: {}, fallback to coinpaprika",
                            to_human_date<std::chrono::seconds>(last_oracle_timestamp, "%e %b %Y, %H:%M"));
                    }
                    this->dispatcher_.trigger<band_oracle_refreshed>();
                }
            })
            .then(&handle_exception_pplx_task);
    }
} // namespace atomic_dex

namespace atomic_dex
{
    void
    band_oracle_price_service::update() noexcept
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
    band_oracle_price_service::is_oracle_ready() const noexcept
    {
        return this->m_oracle_ready.load();
    }

    std::string
    band_oracle_price_service::retrieve_if_this_ticker_supported(const std::string& ticker) const noexcept
    {
        std::string current_price = "";
        if (is_oracle_ready())
        {
            auto& result = m_oracle_price_result.at("result");
            auto  it     = result.prices.find(ticker);
            if (it != result.prices.end())
            {
                current_price = it->second.str();
            }
        }
        return current_price;
    }

    t_float_50
    band_oracle_price_service::retrieve_rates(const std::string& fiat) const noexcept
    {
        auto& result = m_oracle_price_result.at("result");
        return result.rates.at(fiat);
    }

    std::vector<std::string>
    band_oracle_price_service::supported_pair() const noexcept
    {
        std::vector<std::string> out;
        if (is_oracle_ready())
        {
            auto& result = m_oracle_price_result.at("result");
            for (auto&& cur: result.prices) { out.emplace_back(cur.first + "/USD"); }
        }
        else
        {
            if (m_oracle_price_result.find("result") != m_oracle_price_result.end())
            {
                auto& result = m_oracle_price_result.at("result");
                for (auto&& cur: result.prices) { out.emplace_back(cur.first + "/USD"); }
            }
        }
        return out;
    }

    std::string
    band_oracle_price_service::last_oracle_reference() const noexcept
    {
        std::string out;
        if (is_oracle_ready())
        {
            auto& result = m_oracle_price_result.at("result");
            out          = result.reference;
        }
        else
        {
            if (m_oracle_price_result.find("result") != m_oracle_price_result.end())
            {
                auto& result = m_oracle_price_result.at("result");
                out          = result.reference;
            }
        }
        return out;
    }
} // namespace atomic_dex
