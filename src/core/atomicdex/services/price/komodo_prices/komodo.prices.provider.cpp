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
    void
    komodo_prices_provider::process_update()
    {
        SPDLOG_INFO("komodo price service tick loop");
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