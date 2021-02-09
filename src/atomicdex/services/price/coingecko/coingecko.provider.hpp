#pragma once


//! Deps
#include <antara/gaming/ecs/system.manager.hpp>

namespace atomic_dex
{
    class coingecko_provider final : public ag::ecs::pre_update_system<coingecko_provider>
    {
        //! ag::system_manager
        ag::ecs::system_manager& m_system_manager;
        
      public:
        //! Constructor
        coingecko_provider(entt::registry& registry, ag::ecs::system_manager& system_manager) noexcept;

        //! Destructor
        ~coingecko_provider() noexcept final;

        //! Override ag::system functions
        void update() noexcept final;
    };
}

REFL_AUTO(type(atomic_dex::coingecko_provider))