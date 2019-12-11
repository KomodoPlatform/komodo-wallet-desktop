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

#include <thread>
#include <folly/concurrency/ConcurrentHashMap.h>
#include <antara/gaming/ecs/system.hpp>
#include <nlohmann/json.hpp>
#include "atomic.dex.events.hpp"
#include "atomic.dex.utilities.hpp"
#include "atomic.dex.mm2.hpp"

namespace atomic_dex {
    namespace ag = antara::gaming;

    namespace coinpaprika::api {
        struct price_converter_request {
            std::string base_currency_id;
            std::string quote_currency_id;
            std::size_t amount{1};
        };

        struct price_converter_answer {
            std::string base_currency_id;
            std::string base_currency_name;
            std::string base_price_last_updated;
            std::string quote_currency_id;
            std::string quote_currency_name;
            std::string quote_price_last_updated;
            std::size_t amount;
            std::string price; ///< we need trick here
            int rpc_result_code;
            std::string raw_result;
        };

        void to_json(nlohmann::json &j, const price_converter_request &evt);

        void from_json(const nlohmann::json &j, price_converter_answer &evt);

        price_converter_answer price_converter(const price_converter_request &request);
    }


    class coinpaprika_provider final : public ag::ecs::pre_update_system<coinpaprika_provider> {
        //! use it like map.at(USD).at("BTC"); returns "8000" dollars for 1 btc
        using providers_registry = folly::ConcurrentHashMap<std::string, std::string>;
        providers_registry usd_rate_providers_{};
        providers_registry eur_rate_providers_{};
        std::unordered_set<std::string> supported_fiat_{"USD", "EUR"};
        std::thread provider_rates_thread_;
        timed_waiter provider_thread_timer_;
    public:
        coinpaprika_provider(entt::registry &registry, mm2 &mm2_instance);

        ~coinpaprika_provider() noexcept;

        std::string
        get_rate_conversion(const std::string &fiat, const std::string &ticker, std::error_code &ec) const noexcept;

        //! Fiat can be USD or EUR
        std::string get_price_in_fiat(const std::string &fiat, const std::string &ticker, std::error_code &ec,
                                      bool skip_precision = false) const noexcept;

        std::string get_price_in_fiat_all(const std::string &fiat, std::error_code &ec) const noexcept;

        std::string get_price_in_fiat_from_tx(const std::string &fiat, const std::string &ticker, const tx_infos &tx,
                                              std::error_code &ec) const noexcept;

        void on_mm2_started(const atomic_dex::mm2_started &evt) noexcept;
        void on_coin_enabled(const atomic_dex::coin_enabled &evt) noexcept;

        // ReSharper disable once CppFinalFunctionInFinalClass
        void update() noexcept final;

    private:
        mm2 &instance_;
    };
}

REFL_AUTO(type(atomic_dex::coinpaprika_provider))