//! Deps
#include <nlohmann/json.hpp>

//! Project Headers
#include "atomicdex/services/price/komodo_prices/komodo.prices.provider.hpp"

//! Constructor
namespace atomic_dex
{
    komodo_prices_provider::komodo_prices_provider(entt::registry& registry) : system(registry)
    {
        SPDLOG_INFO("komodo_prices_provider created");
        m_clock = std::chrono::high_resolution_clock::now();
        process_update();
    }
} // namespace atomic_dex

//! Private functions
namespace atomic_dex
{
    komodo_prices::api::komodo_ticker_infos
    komodo_prices_provider::get_info_answer(const std::string& ticker) const
    {
        std::shared_lock lock(m_market_mutex);
        SPDLOG_INFO("Looking for ticker: {}", ticker);
        const auto it = m_market_registry.find(ticker);
        return it != m_market_registry.cend() ? it->second : komodo_prices::api::komodo_ticker_infos{.ticker = ticker};
    }

    void
    komodo_prices_provider::process_update()
    {
        SPDLOG_INFO("komodo price service tick loop");

        auto answer_functor = [this](web::http::http_response resp) {
            std::string body = TO_STD_STR(resp.extract_string(true).get());
            if (resp.status_code() == 200)
            {
                nlohmann::json j = nlohmann::json::parse(body);
                t_market_registry answer;
                answer = j.get<t_market_registry>();
                {
                    std::unique_lock lock(m_market_mutex);
                    m_market_registry = std::move(answer);
                    SPDLOG_INFO("komodo price registry size: {}", m_market_registry.size());
                }
            }
            else
            {
                SPDLOG_ERROR("Error during the rpc call to komodo price provider: {}", body);
            }
        };

        auto error_functor = [](pplx::task<void> previous_task){
            try
            {
                previous_task.wait();
            }
            catch (const std::exception& e)
            {
                SPDLOG_ERROR("error occured when fetching price: {}", e.what());
            };
        };

        atomic_dex::komodo_prices::api::async_market_infos().then(answer_functor).then(error_functor);
    }
} // namespace atomic_dex

//! Public Functions
namespace atomic_dex
{
    void
    komodo_prices_provider::update()
    {
        using namespace std::chrono_literals;

        const auto now    = std::chrono::high_resolution_clock::now();
        const auto s      = std::chrono::duration_cast<std::chrono::seconds>(now - m_clock);

        if (s >= 30s)
        {
            process_update();
            m_clock = std::chrono::high_resolution_clock::now();
        }
    }
} // namespace atomic_dex