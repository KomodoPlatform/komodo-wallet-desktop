/******************************************************************************
 * Copyright © 2013-2019 The Komodo Platform Developers.                      *
 *                                                                            *
 * See the AUTHORS, DEVELOPER-AGREEMENT and LICENSE files at                  *
 * the top-level directory of this distribution for the individual copyright  *
 * holder information and the developer policies on copyright and licensing.  *
 *                                                                            *
 * Unless otherwise agreed in a custom licensing agreement, no part of the    *
 * Komodo Platform software, including this file may be copied, modified,     *
 * propagated or distributed except according to the terms contained in the   *
 * LICENSE file                                                               *
 *                                                                            *
 * Removal or modification of this copyright notice is prohibited.            *
 *                                                                            *
 ******************************************************************************/

//! Project Headers
#include "atomic.dex.provider.coinpaprika.hpp"
#include "atomic.dex.http.code.hpp"
#include "atomic.threadpool.hpp"

namespace
{
    //! Using namespace
    using namespace std::chrono_literals;
    using namespace atomic_dex;
    using namespace atomic_dex::coinpaprika::api;

    template <typename TAnswer, typename TRequest, typename TFunctorRequest>
    void
    retry(TAnswer& answer, const TRequest& request, TFunctorRequest&& functor)
    {
        while (answer.rpc_result_code == e_http_code::too_many_requests)
        {
            DLOG_F(WARNING, "too many request retry");
            std::this_thread::sleep_for(1s);
            functor(request);
            // answer = price_converter(request);
        }
    }

    void
    process_ticker_infos(const atomic_dex::coin_config& current_coin, atomic_dex::coinpaprika_provider::t_ticker_infos_registry& reg)
    {
        const ticker_infos_request request{.ticker_currency_id = current_coin.coinpaprika_id, .ticker_quotes = {"USD", "EUR"}};
        auto                       answer = tickers_info(request);

        retry(answer, request, [&answer](const ticker_infos_request& request) { answer = tickers_info(request); });
        reg.insert_or_assign(current_coin.ticker, answer);
    }

    void
    process_ticker_historical(const atomic_dex::coin_config& current_coin, atomic_dex::coinpaprika_provider::t_ticker_historical_registry& reg)
    {
        if (current_coin.coinpaprika_id == "test-coin")
        {
            return;
        }
        const ticker_historical_request request{.ticker_currency_id = current_coin.coinpaprika_id};
        auto                            answer = ticker_historical(request);
        retry(answer, request, [&answer](const ticker_historical_request& request) { answer = ticker_historical(request); });
        if (answer.raw_result.find("error") == std::string::npos)
        {
            reg.insert_or_assign(current_coin.ticker, answer);
        }
    }

    template <typename Provider>
    void
    process_provider(const atomic_dex::coin_config& current_coin, Provider& rate_providers, const std::string& fiat)
    {
        const auto                    base = current_coin.coinpaprika_id;
        const price_converter_request request{.base_currency_id = base, .quote_currency_id = fiat};
        auto                          answer = price_converter(request);

        retry(answer, request, [&answer](const price_converter_request& request) { answer = price_converter(request); });

        if (answer.raw_result.find("error") == std::string::npos)
        {
            if (not answer.price.empty())
            {
                rate_providers.insert_or_assign(current_coin.ticker, answer.price);
            }
        }
        else
            rate_providers.insert_or_assign(current_coin.ticker, "0.00");
    }
} // namespace

namespace atomic_dex
{
    namespace bm = boost::multiprecision;

    coinpaprika_provider::coinpaprika_provider(entt::registry& registry, mm2& mm2_instance) : system(registry), m_mm2_instance(mm2_instance)
    {
        LOG_SCOPE_FUNCTION(INFO);
        disable();
        dispatcher_.sink<mm2_started>().connect<&coinpaprika_provider::on_mm2_started>(*this);
        dispatcher_.sink<coin_enabled>().connect<&coinpaprika_provider::on_coin_enabled>(*this);
        dispatcher_.sink<coin_disabled>().connect<&coinpaprika_provider::on_coin_disabled>(*this);
    }

    void
    coinpaprika_provider::update() noexcept
    {
    }

    coinpaprika_provider::~coinpaprika_provider() noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        m_provider_thread_timer.interrupt();
        if (m_provider_rates_thread.joinable())
        {
            m_provider_rates_thread.join();
        }
        dispatcher_.sink<mm2_started>().disconnect<&coinpaprika_provider::on_mm2_started>(*this);
        dispatcher_.sink<coin_enabled>().disconnect<&coinpaprika_provider::on_coin_enabled>(*this);
        dispatcher_.sink<coin_disabled>().disconnect<&coinpaprika_provider::on_coin_disabled>(*this);
    }

    void
    coinpaprika_provider::on_mm2_started([[maybe_unused]] const mm2_started& evt) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);

        m_provider_rates_thread = std::thread([this]() {
            loguru::set_thread_name("paprika thread");
            LOG_SCOPE_F(INFO, "paprika thread started");

            using namespace std::chrono_literals;
            do
            {
                DLOG_F(INFO, "refreshing rate conversion from coinpaprika");

                t_coins coins = m_mm2_instance.get_enabled_coins();

                for (auto&& current_coin: coins)
                {
                    if (current_coin.coinpaprika_id == "test-coin")
                    {
                        continue;
                    }
                    spawn([this, cur_coin = current_coin]() { process_ticker_infos(cur_coin, this->m_ticker_infos_registry); });
                    spawn([this, cur_coin = current_coin]() { process_ticker_historical(cur_coin, this->m_ticker_historical_registry); });
                    process_provider(current_coin, m_usd_rate_providers, "usd-us-dollars");
                    process_provider(current_coin, m_eur_rate_providers, "eur-euro");
                }

            } while (not m_provider_thread_timer.wait_for(30s));
        });
    }

    std::string
    coinpaprika_provider::get_price_in_fiat(const std::string& fiat, const std::string& ticker, std::error_code& ec, bool skip_precision) const noexcept
    {
        if (m_supported_fiat_registry.count(fiat) == 0u)
        {
            ec = dextop_error::invalid_fiat_for_rate_conversion;
            return "0.00";
        }

        if (m_mm2_instance.get_coin_info(ticker).coinpaprika_id == "test-coin")
        {
            return "0.00";
        }

        const auto price = get_rate_conversion(fiat, ticker, ec);

        if (ec)
        {
            return "0.00";
        }

        std::error_code t_ec;
        const auto      amount = m_mm2_instance.my_balance(ticker, t_ec);

        if (t_ec)
        {
            ec = t_ec;
            LOG_F(ERROR, "my_balance error: {}", t_ec.message());
            return "0.00";
        }

        const bm::cpp_dec_float_50 price_f(price);
        const bm::cpp_dec_float_50 amount_f(amount);
        const auto                 final_price = price_f * amount_f;
        std::stringstream          ss;

        if (not skip_precision)
        {
            ss.precision(2);
        }
        ss << std::fixed << final_price;

        return ss.str() == "0" ? "0.00" : ss.str();
    }

    std::string
    coinpaprika_provider::get_price_in_fiat_all(const std::string& fiat, std::error_code& ec) const noexcept
    {
        t_coins              coins         = m_mm2_instance.get_enabled_coins();
        bm::cpp_dec_float_50 final_price_f = 0;
        std::string          current_price = "0.00";
        std::stringstream    ss;

        for (auto&& current_coin: coins)
        {
            if (current_coin.coinpaprika_id == "test-coin")
            {
                continue;
            }

            current_price = get_price_in_fiat(fiat, current_coin.ticker, ec, true);

            if (ec)
            {
                LOG_F(WARNING, "error when converting {} to {}, err: {}", current_coin.ticker, fiat, ec.message());
                ec.clear(); //! Reset
                continue;
            }

            if (not current_price.empty())
            {
                const auto current_price_f = bm::cpp_dec_float_50(current_price);
                final_price_f += current_price_f;
            }
        }

        ss.precision(2);
        ss << std::fixed << final_price_f;
        return ss.str();
    }

    std::string
    coinpaprika_provider::get_price_in_fiat_from_tx(const std::string& fiat, const std::string& ticker, const tx_infos& tx, std::error_code& ec) const noexcept
    {
        if (m_mm2_instance.get_coin_info(ticker).coinpaprika_id == "test-coin")
        {
            return "0.00";
        }
        const auto amount        = tx.am_i_sender ? tx.my_balance_change.substr(1) : tx.my_balance_change;
        const auto current_price = get_rate_conversion(fiat, ticker, ec);
        if (ec)
        {
            return "0.00";
        }
        const bm::cpp_dec_float_50 amount_f(amount);
        const bm::cpp_dec_float_50 current_price_f(current_price);
        const auto                 final_price = amount_f * current_price_f;
        std::stringstream          ss;
        ss.precision(2);
        ss << std::fixed << final_price;
        std::string final_price_str = ss.str();
        return final_price_str;
    }

    std::string
    coinpaprika_provider::get_rate_conversion(const std::string& fiat, const std::string& ticker, std::error_code& ec, bool adjusted) const noexcept
    {
        std::string current_price;

        if (fiat == "USD")
        {
            //! Do it as usd;
            if (m_usd_rate_providers.find(ticker) == m_usd_rate_providers.cend())
            {
                ec = dextop_error::unknown_ticker_for_rate_conversion;
                return "0.00";
            }
            current_price = m_usd_rate_providers.at(ticker);
        }
        else if (fiat == "EUR")
        {
            if (m_eur_rate_providers.find(ticker) == m_eur_rate_providers.cend())
            {
                ec = dextop_error::unknown_ticker_for_rate_conversion;
                return "0.00";
            }
            current_price = m_eur_rate_providers.at(ticker);
        }

        if (adjusted)
        {
            std::stringstream ss;
            ss << std::fixed << std::setprecision(2) << t_float_50(current_price);
            current_price = ss.str();
        }
        return current_price;
    }

    void
    coinpaprika_provider::on_coin_enabled(const coin_enabled& evt) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        const auto config = m_mm2_instance.get_coin_info(evt.ticker);

        if (config.coinpaprika_id != "test-coin")
        {
            process_provider(config, m_usd_rate_providers, "usd-us-dollars");
            process_provider(config, m_eur_rate_providers, "eur-euro");
            process_ticker_infos(config, m_ticker_infos_registry);
            process_ticker_historical(config, m_ticker_historical_registry);
        }
    }

    void
    coinpaprika_provider::on_coin_disabled(const coin_disabled& evt) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        const auto config = m_mm2_instance.get_coin_info(evt.ticker);

        m_usd_rate_providers.erase(config.ticker);
        m_eur_rate_providers.erase(config.ticker);
    }

    t_ticker_info_answer
    coinpaprika_provider::get_ticker_infos(const std::string& ticker) const noexcept
    {
        return m_ticker_infos_registry.find(ticker) != m_ticker_infos_registry.cend() ? m_ticker_infos_registry.at(ticker) : t_ticker_info_answer{};
    }

    t_ticker_historical_answer
    coinpaprika_provider::get_ticker_historical(const std::string& ticker) const noexcept
    {
        return m_ticker_historical_registry.find(ticker) != m_ticker_historical_registry.cend() ? m_ticker_historical_registry.at(ticker)
                                                                                                : t_ticker_historical_answer{.answer = nlohmann::json::array()};
    }
} // namespace atomic_dex
