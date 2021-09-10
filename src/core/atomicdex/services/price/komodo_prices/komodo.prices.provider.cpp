//! Project Headers
#include "atomicdex/services/price/komodo_prices/komodo.prices.provider.hpp"

//! Constructor
namespace atomic_dex
{
    komodo_prices_provider::komodo_prices_provider(entt::registry& registry) : system(registry)
    {
        SPDLOG_INFO("komodo_prices_provider created");
        this->disable();
    }
} // namespace atomic_dex

//! Functions
namespace atomic_dex
{
    void
    komodo_prices_provider::update()
    {
    }
} // namespace atomic_dex