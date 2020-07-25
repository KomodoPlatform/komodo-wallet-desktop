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

#pragma once

#include "atomic.dex.pch.hpp"

//! Project header
#include "atomic.dex.ma.series.data.hpp"
#include "atomic.dex.mm2.hpp"

inline constexpr const std::size_t nb_pair_supported = 40_sz;

namespace atomic_dex
{
    enum class moving_average
    {
        twenty,
        fifty
    };

    namespace ag = antara::gaming;

    class cex_prices_provider final : public ag::ecs::pre_update_system<cex_prices_provider>
    {
        using t_supported_pairs               = std::array<std::string, nb_pair_supported>;
        using t_current_orderbook_ticker_pair = std::pair<std::string, std::string>;
        using t_synchronized_json             = boost::synchronized_value<nlohmann::json>;
        using t_synchronized_average_map      = boost::synchronized_value<std::unordered_map<std::string, std::vector<ma_series_data>>>;

        //! Private fields
        mm2& m_mm2_instance;

        //! OHLC Related
        t_current_orderbook_ticker_pair m_current_orderbook_ticker_pair{"", ""};
        t_supported_pairs               m_supported_pair{"eth-btc",  "eth-usdc", "btc-usdc", "btc-busd", "btc-tusd", "bat-btc",  "bat-eth",  "bat-usdc",
                                           "bat-tusd", "bat-busd", "bch-btc",  "bch-eth",  "bch-usdc", "bch-tusd", "bch-busd", "dash-btc",
                                           "dash-eth", "dgb-btc",  "doge-btc", "kmd-btc",  "kmd-eth",  "ltc-btc",  "ltc-eth",  "ltc-usdc",
                                           "ltc-tusd", "ltc-busd", "nav-btc",  "nav-eth",  "pax-btc",  "pax-eth",  "qtum-btc", "qtum-eth",
                                           "rvn-btc",  "xzc-btc",  "xzc-eth",  "zec-btc",  "zec-eth",  "zec-usdc", "zec-tusd", "zec-busd"};

        //! OHLC Data
        t_synchronized_json        m_current_ohlc_data;
        t_synchronized_average_map m_ma_20_series_registry;
        t_synchronized_average_map m_ma_50_series_registry;

        //! Threads
        std::queue<std::future<void>> m_pending_tasks;
        std::thread                   m_provider_ohlc_fetcher_thread;
        timed_waiter                  m_provider_thread_timer;

        //! Private API
        void reverse_ohlc_data() noexcept;

      public:
        //! Constructor
        cex_prices_provider(entt::registry& registry, mm2& mm2_instance);

        //! Destructor
        ~cex_prices_provider() noexcept final;

        //! Queue
        void consume_pending_tasks();

        // Override
        void update() noexcept final;

        //! Process OHLC http rest request
        bool process_ohlc(const std::string& base, const std::string& rel, bool is_a_reset = false) noexcept;

        //! Return true if json ohlc data is not empty, otherwise return false
        bool is_ohlc_data_available() const noexcept;

        //! First boolean if it's supported as regular, second one if it's supported as quoted
        std::pair<bool, bool> is_pair_supported(const std::string& base, const std::string& rel) const noexcept;

        //! Event that occur when the mm2 process is launched correctly.
        void on_mm2_started(const mm2_started& evt) noexcept;

        nlohmann::json get_ohlc_data(const std::string& range) noexcept;

        std::vector<ma_series_data> get_ma_series_data(moving_average scope, const std::string& range) const noexcept;

        nlohmann::json get_all_ohlc_data() noexcept;

        //! Event that occur when the ticker pair is changed in the front end
        void on_current_orderbook_ticker_pair_changed(const orderbook_refresh& evt) noexcept;
        void compute_moving_average();
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::cex_prices_provider))