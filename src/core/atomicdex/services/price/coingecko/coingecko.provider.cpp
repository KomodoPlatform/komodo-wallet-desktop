#include <boost/algorithm/string/case_conv.hpp>


//! Project Headers
#include "atomicdex/api/coingecko/coingecko.hpp"
#include "atomicdex/pages/qt.portfolio.page.hpp"
#include "atomicdex/pages/qt.settings.page.hpp"
#include "atomicdex/services/price/coingecko/coingecko.provider.hpp"

namespace atomic_dex
{
    coingecko_provider::coingecko_provider(entt::registry& registry, ag::ecs::system_manager& system_manager) :
        system(registry), m_system_manager(system_manager)
    {
        SPDLOG_INFO("coingecko_provider created");
        this->disable();
        dispatcher_.sink<kdf_started>().connect<&coingecko_provider::on_kdf_started>(*this);
        dispatcher_.sink<coin_enabled>().connect<&coingecko_provider::on_coin_enabled>(*this);
        dispatcher_.sink<coin_disabled>().connect<&coingecko_provider::on_coin_disabled>(*this);
    }

    coingecko_provider::~coingecko_provider()
    {
        SPDLOG_INFO("coingecko_provider destroyed");
        dispatcher_.sink<kdf_started>().disconnect<&coingecko_provider::on_kdf_started>(*this);
        dispatcher_.sink<coin_enabled>().disconnect<&coingecko_provider::on_coin_enabled>(*this);
        dispatcher_.sink<coin_disabled>().disconnect<&coingecko_provider::on_coin_disabled>(*this);
    }
} // namespace atomic_dex

//! Override functions
namespace atomic_dex
{
    void
    coingecko_provider::update()
    {
    }
} // namespace atomic_dex

//! Events
namespace atomic_dex
{
    void
    coingecko_provider::on_kdf_started([[maybe_unused]] const kdf_started& evt)
    {
        SPDLOG_INFO("on_kdf_started");
        update_ticker_and_provider();
    }

    void
    coingecko_provider::on_coin_enabled(const coin_enabled& evt)
    {
        SPDLOG_INFO("coin_enabled: {}", fmt::join(evt.tickers, ", "));
        dispatcher_.trigger<coin_fully_initialized>(evt.tickers);
        if (evt.tickers.size() > 1)
        {
            SPDLOG_INFO("on_coin_enabled size() > 1");
            this->update_ticker_and_provider();
        }
    }

    void
    coingecko_provider::on_coin_disabled([[maybe_unused]] const coin_disabled& evt)
    {
        // SPDLOG_INFO("{} disabled, removing from coingecko provider", evt.ticker);
        // std::unique_lock lock(m_market_mutex);
        // m_market_registry.erase(evt.ticker);
    }

} // namespace atomic_dex

namespace atomic_dex
{
    void
    coingecko_provider::update_ticker_and_provider()
    {
        SPDLOG_INFO("update_ticker_and_provider");
        if (m_system_manager.has_system<kdf_service>() && m_system_manager.get_system<kdf_service>().is_kdf_running())
        {
            const auto coins       = this->m_system_manager.get_system<portfolio_page>().get_global_cfg()->get_model_data();
            auto&& [ids, registry] = coingecko::api::from_enabled_coins(coins);
            internal_update(ids, registry);
        }
        else
        {
            SPDLOG_WARN("kdf not running - skipping update_ticker_and_provider");
        }
    }

    std::string
    coingecko_provider::get_change_24h(const std::string& ticker) const
    {
        //SPDLOG_INFO("ticker change 24h: {}", ticker);
        return get_info_answer(ticker).price_change_24h;
    }


    nlohmann::json
    coingecko_provider::get_ticker_historical(const std::string& ticker) const
    {
        return get_info_answer(ticker).sparkline_in_7d;
    }

    std::string
    coingecko_provider::get_rate_conversion(const std::string& ticker) const
    {
        return get_info_answer(ticker).current_price;
    }

    std::string
    coingecko_provider::get_total_volume(const std::string& ticker) const
    {
        return get_info_answer(ticker).total_volume;
    }
} // namespace atomic_dex

//! Private member functions
namespace atomic_dex
{
    void
    coingecko_provider::internal_update(
        const std::vector<std::string>& ids, const std::unordered_map<std::string, std::string>& registry, bool should_move, std::vector<std::string> tickers)
    {
        static std::atomic_uint16_t nb_try = 0;
        nb_try += 1;
        if (!ids.empty())
        {
            SPDLOG_INFO("Processing internal_update");

            auto error_functor = [this, ids, registry, should_move, tickers](pplx::task<void> previous_task)
            {
              try
              {
                  previous_task.wait();
              }
              catch (const std::exception& e)
              {
                  SPDLOG_ERROR("pplx task error from coingecko::api::async_market_infos: {} - nb_try {}", e.what(), nb_try.load());
                  using namespace std::chrono_literals;
                  std::this_thread::sleep_for(1s);
                  this->internal_update(ids, registry, should_move, tickers);
              };
            };
            t_coingecko_market_infos_request request{.ids = std::move(ids)};
            const auto                       answer_functor = [this, registry, should_move, tickers](web::http::http_response resp) {
                std::string body = TO_STD_STR(resp.extract_string(true).get());
                if (resp.status_code() == 200)
                {
                    nlohmann::json                  j = nlohmann::json::parse(body);
                    t_coingecko_market_infos_answer answer;
                    coingecko::api::from_json(j, answer, registry);
                    std::size_t nb_coins = 0;
                    /*if (answer.raw_result.empty())
                    {
                        SPDLOG_ERROR("Coingecko answer not available - skipping");
                        return;
                    }*/
                    {
                        std::unique_lock lock(m_market_mutex);
                        if (should_move) ///< Override
                        {
                            m_market_registry = std::move(answer.result);
                        }
                        else ///< When we enable a coin we don't want to move
                        {
                            for (auto&& [key, value]: answer.result) { m_market_registry[key] = value; }
                        }
                        nb_coins = m_market_registry.size();
                    }
                    SPDLOG_INFO("nb of parsed market infos is {} coins", nb_coins);
                    if (!tickers.empty())
                    {
                        ///< it's on enabled coins
                        dispatcher_.trigger<coin_fully_initialized>(tickers);
                    }
                    else
                    {
                        dispatcher_.trigger<fiat_rate_updated>("");
                    }
                    SPDLOG_INFO("Coingecko rates successfully updated after nb_try: {}", nb_try.load());
                    nb_try = 0;
                }
                else
                {
                    SPDLOG_ERROR("Error during the rpc call to coingecko: {}", body);
                }
            };
            coingecko::api::async_market_infos(std::move(request)).then(answer_functor).then(error_functor);
        }
        else
        {
            //! If it's only test coin
            dispatcher_.trigger<coin_fully_initialized>(tickers);
            nb_try = 0;
        }
    }

    coingecko::api::single_infos_answer
    coingecko_provider::get_info_answer(const std::string& ticker) const
    {
        const auto       final_ticker = atomic_dex::utils::retrieve_main_ticker(ticker);
        std::shared_lock lock(m_market_mutex);
        // SPDLOG_INFO("Looking for ticker: {}", ticker);
        const auto it = m_market_registry.find(final_ticker);
        return it != m_market_registry.cend() ? it->second : coingecko::api::single_infos_answer{.price_change_24h = "0.00", .current_price = "0.00", .total_volume = "0.00"};
    }
} // namespace atomic_dex
