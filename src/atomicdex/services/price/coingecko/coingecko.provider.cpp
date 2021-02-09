#include "atomicdex/services/price/coingecko/coingecko.provider.hpp"

namespace atomic_dex
{
    coingecko_provider::coingecko_provider(entt::registry& registry, ag::ecs::system_manager& system_manager) noexcept :
        system(registry), m_system_manager(system_manager)
    {
        SPDLOG_INFO("coingecko_provider created");
    }

    coingecko_provider::~coingecko_provider() noexcept { SPDLOG_INFO("coingecko_provider destroyed"); }
} // namespace atomic_dex

//! Override functions
namespace atomic_dex
{
    void
    coingecko_provider::update() noexcept
    {
    }
} // namespace atomic_dex