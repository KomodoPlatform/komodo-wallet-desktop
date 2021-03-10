/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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

//! Deps
#include <nlohmann/json_fwd.hpp>

//! Project header
#include "atomicdex/data/dex/ma.series.hpp"
#include "atomicdex/services/mm2/mm2.service.hpp"

inline constexpr const std::size_t nb_pair_supported = 40_sz;

namespace atomic_dex
{
    enum class moving_average
    {
        twenty,
        fifty
    };

    namespace ag = antara::gaming;

    class ohlc_provider final : public ag::ecs::pre_update_system<ohlc_provider>
    {
        using t_supported_pairs               = std::array<std::string, nb_pair_supported>;
        using t_current_orderbook_ticker_pair = std::pair<std::string, std::string>;
        using t_synchronized_json             = boost::synchronized_value<nlohmann::json>;

        //! Private fields
        mm2_service& m_mm2_instance;

        //! OHLC Related
        t_current_orderbook_ticker_pair m_current_orderbook_ticker_pair{"", ""};
        t_supported_pairs               m_supported_pair{"eth-btc",  "eth-usdc", "btc-usdc", "btc-busd", "btc-tusd", "bat-btc",  "bat-eth",  "bat-usdc",
                                           "bat-tusd", "bat-busd", "bch-btc",  "bch-eth",  "bch-usdc", "bch-tusd", "bch-busd", "dash-btc",
                                           "dash-eth", "dgb-btc",  "doge-btc", "kmd-btc",  "kmd-eth",  "ltc-btc",  "ltc-eth",  "ltc-usdc",
                                           "ltc-tusd", "ltc-busd", "nav-btc",  "nav-eth",  "pax-btc",  "pax-eth",  "qtum-btc", "qtum-eth",
                                           "rvn-btc",  "xzc-btc",  "xzc-eth",  "zec-btc",  "zec-eth",  "zec-usdc", "zec-tusd", "zec-busd"};

        //! OHLC Data
        t_synchronized_json m_current_ohlc_data;

        //! Timer
        std::atomic_bool m_mm2_started{false};
        using t_update_time_point = std::chrono::high_resolution_clock::time_point;
        t_update_time_point m_update_clock;

        //! Private API
        void reverse_ohlc_data(nlohmann::json& cur_range) noexcept;

      public:
        //! Constructor
        ohlc_provider(entt::registry& registry, mm2_service& mm2_instance);

        //! Destructor
        ~ohlc_provider() noexcept final;

        // Override
        void update() noexcept final;

        //! ohlc update
        void update_ohlc() noexcept;

        //! Process OHLC http rest request
        bool process_ohlc(const std::string& base, const std::string& rel, bool is_a_reset = false) noexcept;

        //! Return true if json ohlc data is not empty, otherwise return false
        bool is_ohlc_data_available() const noexcept;

        //! First boolean if it's supported as regular, second one if it's supported as quoted
        std::pair<bool, bool> is_pair_supported(const std::string& base, const std::string& rel) const noexcept;

        //! Event that occur when the mm2 process is launched correctly.
        void on_mm2_started(const mm2_started& evt) noexcept;

        nlohmann::json get_ohlc_data(const std::string& range) noexcept;

        nlohmann::json get_all_ohlc_data() noexcept;

        //! Event that occur when the ticker pair is changed in the front end
        void on_current_orderbook_ticker_pair_changed(const orderbook_refresh& evt) noexcept;
        void updating_quote_and_average(bool quoted);
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::ohlc_provider))
