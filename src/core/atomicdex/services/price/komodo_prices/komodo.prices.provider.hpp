#pragma once

//! STD
#include <shared_mutex>

//! Deps
#include <antara/gaming/ecs/system.manager.hpp>

//! Project Headers
#include "atomicdex/api/komodo_prices/komodo.prices.hpp"

namespace atomic_dex
{
    class komodo_prices_provider final : public ag::ecs::pre_update_system<komodo_prices_provider>
    {
        //! private type definition
        using t_market_registry = atomicdex::komodo_prices::api::t_komodo_tickers_price_registry;

        //! private fields
        t_market_registry         m_market_registry;
        mutable std::shared_mutex m_market_mutex;

      public:
        //! Constructor
        komodo_prices_provider(entt::registry& registry);

        //! Destructor
        ~komodo_prices_provider() final = default;

        //! Override ag::system functions
        void update() final;
    };
}

REFL_AUTO(type(atomic_dex::komodo_prices_provider))