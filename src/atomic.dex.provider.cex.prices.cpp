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

#include "atomic.dex.provider.cex.prices.hpp"

namespace atomic_dex
{
    cex_prices_provider::cex_prices_provider(entt::registry& registry, mm2& mm2_instance) : system(registry), m_mm2_instance(mm2_instance)
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        disable();
        dispatcher_.sink<mm2_started>().connect<&cex_prices_provider::on_mm2_started>(*this);
        dispatcher_.sink<orderbook_refresh>().connect<&cex_prices_provider::on_current_orderbook_ticker_pair_changed>(*this);
    }

    void
    cex_prices_provider::update() noexcept
    {
    }

    cex_prices_provider::~cex_prices_provider() noexcept
    {
        //!
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

        m_provider_thread_timer.interrupt();

        if (m_provider_ohlc_fetcher_thread.joinable())
        {
            m_provider_ohlc_fetcher_thread.join();
        }

        dispatcher_.sink<mm2_started>().disconnect<&cex_prices_provider::on_mm2_started>(*this);
    }

    void
    cex_prices_provider::on_current_orderbook_ticker_pair_changed(const orderbook_refresh& evt) noexcept
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

        m_orderbook_tickers_data_mutex.lock();
        m_current_orderbook_ticker_pair = {evt.base, evt.rel};
        spdlog::debug("new orderbook pair for cex provider [{} / {}]", m_current_orderbook_ticker_pair.first, m_current_orderbook_ticker_pair.second);
        m_orderbook_tickers_data_mutex.unlock();
    }

    void
    cex_prices_provider::on_mm2_started([[maybe_unused]] const mm2_started& evt) noexcept
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

        m_provider_ohlc_fetcher_thread = std::thread([this]() {
            //
            spdlog::info("cex prices provider thread started");

            using namespace std::chrono_literals;
            do
            {
                spdlog::info("fetching ohlc value");
            } while (not m_provider_thread_timer.wait_for(1h));
        });
    }

} // namespace atomic_dex