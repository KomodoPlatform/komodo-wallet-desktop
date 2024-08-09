#pragma once

//! STD
#include <shared_mutex>

//! Deps
#include <antara/gaming/ecs/system.manager.hpp>

#include "atomicdex/api/coingecko/coingecko.hpp"
#include "atomicdex/events/events.hpp"

namespace atomic_dex
{
    class coingecko_provider final : public ag::ecs::pre_update_system<coingecko_provider>
    {
        using t_market_registry = std::unordered_map<std::string, coingecko::api::single_infos_answer>;
        //! ag::system_manager
        ag::ecs::system_manager&  m_system_manager;
        t_market_registry         m_market_registry;
        mutable std::shared_mutex m_market_mutex;

        void internal_update(
            const std::vector<std::string>& ids, const std::unordered_map<std::string, std::string>& registry, bool should_move = true,
            std::vector<std::string> tickers = {});

        coingecko::api::single_infos_answer get_info_answer(const std::string& ticker) const;

      public:
        //! Constructor
        coingecko_provider(entt::registry& registry, ag::ecs::system_manager& system_manager) ;

        //! Destructor
        ~coingecko_provider()  final;

        //! Override ag::system functions
        void update()  final;

        void update_ticker_and_provider();

        //! Event that occur when the kdf process is launched correctly.
        void on_kdf_started(const kdf_started& evt) ;

        //! Event that occur when a coin is correctly enabled.
        void on_coin_enabled(const coin_enabled& evt) ;

        //! Event that occur when a coin is correctly disabled.
        void on_coin_disabled(const coin_disabled& evt) ;

        //! Get the rate conversion for the given fiat.
        [[nodiscard]] std::string get_rate_conversion(const std::string& ticker) const ;

        //! Get the ticker informations.
        [[nodiscard]] std::string get_change_24h(const std::string& ticker) const ;

        //! Get the volume information
        [[nodiscard]] std::string get_total_volume(const std::string& ticker) const;

        //! Get the ticker informations.
        [[nodiscard]] nlohmann::json get_ticker_historical(const std::string& ticker) const ;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::coingecko_provider))
