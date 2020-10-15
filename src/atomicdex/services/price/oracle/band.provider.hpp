#pragma once

#include "atomicdex/services/mm2/mm2.service.hpp"

namespace atomic_dex
{
    struct band_oracle_price_result
    {
        std::size_t                                 timestamp;
        std::string                                 human_date;
        std::unordered_map<std::string, t_float_50> prices;
        std::unordered_map<std::string, t_float_50> rates;
        std::string                                 reference;
    };

    void from_json(const nlohmann::json& j, band_oracle_price_result& result);

    class band_oracle_price_service final : public ag::ecs::pre_update_system<band_oracle_price_service>
    {
        using t_update_time_point         = std::chrono::high_resolution_clock::time_point;
        using t_oracle_price_synchronized = t_concurrent_reg<std::string, band_oracle_price_result>;

        static constexpr const char* m_band_endpoint{"https://feeds.bandprotocol.com"};
        t_http_client_ptr            m_band_http_client{std::make_unique<t_http_client>(FROM_STD_STR(m_band_endpoint))};
        t_update_time_point          m_update_clock;
        t_oracle_price_synchronized  m_oracle_price_result;
        std::atomic_bool             m_oracle_ready{false};

        void                                 fetch_oracle() noexcept;
        pplx::task<web::http::http_response> async_fetch_oracle_result() noexcept;

      public:
        explicit band_oracle_price_service(entt::registry& registry);
        ~band_oracle_price_service() noexcept final = default;

        void update() noexcept final;

        //! Public API
        bool                     is_oracle_ready() const noexcept;
        std::string              retrieve_if_this_ticker_supported(const std::string& ticker) const noexcept;
        t_float_50               retrieve_rates(const std::string& fiat) const noexcept;
        std::vector<std::string> supported_pair() const noexcept;
        std::string              last_oracle_reference() const noexcept;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::band_oracle_price_service))
