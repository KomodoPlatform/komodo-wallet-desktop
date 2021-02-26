#pragma once

//! STD
#include <unordered_set>

#include "atomicdex/config/app.cfg.hpp"
#include "atomicdex/services/mm2/mm2.service.hpp"

namespace atomic_dex
{
    class global_price_service final : public ag::ecs::pre_update_system<global_price_service>
    {
        using t_supported_fiat_registry = std::unordered_set<std::string>;
        using t_json_synchronized       = boost::synchronized_value<nlohmann::json>;
        using t_providers_registry      = std::unordered_map<std::string, std::string>;
        using t_update_time_point       = std::chrono::high_resolution_clock::time_point;

        ag::ecs::system_manager&  m_system_manager;
        atomic_dex::cfg&          m_cfg;
        t_supported_fiat_registry m_supported_fiat_registry{"USD", "EUR", "BTC", "KMD", "GBP", "HKD", "IDR", "ILS", "DKK", "INR", "CHF", "MXN",
                                                            "CZK", "SGD", "THB", "HRK", "MYR", "NOK", "CNY", "BGN", "PHP", "PLN", "ZAR", "CAD",
                                                            "ISK", "BRL", "RON", "NZD", "TRY", "JPY", "RUB", "KRW", "AUD", "HUF", "SEK"};
        t_providers_registry      m_coin_rate_providers{};
        t_json_synchronized       m_other_fiats_rates;
        t_update_time_point       m_update_clock;
        mutable std::shared_mutex m_coin_rate_mutex;

        void refresh_other_coins_rates(const std::string& quote_id, const std::string& ticker, bool with_update_providers = false);

      public:
        explicit global_price_service(entt::registry& registry, ag::ecs::system_manager& system_manager, atomic_dex::cfg& cfg);
        ~global_price_service() noexcept final = default;

        //! Public override
        void update() noexcept final;

        //! Public API
        std::string get_price_as_currency_from_tx(const std::string& currency, const std::string& ticker, const tx_infos& tx) const noexcept;
        std::string get_price_in_fiat(const std::string& fiat, const std::string& ticker, std::error_code& ec, bool skip_precision = false) const noexcept;
        std::string get_price_in_fiat_all(const std::string& fiat, std::error_code& ec) const noexcept;
        std::string get_rate_conversion(const std::string& fiat, const std::string& ticker, bool adjusted = false) const noexcept;
        std::string get_price_as_currency_from_amount(const std::string& currency, const std::string& ticker, const std::string& amount) const noexcept;
        std::string get_cex_rates(const std::string& base, const std::string& rel) const noexcept;

        //! Events
        void on_force_update_providers([[maybe_unused]] const force_update_providers& evt);
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::global_price_service))
