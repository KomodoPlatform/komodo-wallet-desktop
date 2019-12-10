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

#include <restclient-cpp/restclient.h>
#include <boost/multiprecision/cpp_dec_float.hpp>
#include "atomic.dex.provider.coinpaprika.hpp"

namespace {
    using namespace std::chrono_literals;
    constexpr const char *coinpaprika_endpoint = "https://api.coinpaprika.com/v1/";
    using namespace atomic_dex::coinpaprika::api;

    void retry(price_converter_answer &answer, const price_converter_request &request) {
        while (answer.rpc_result_code == 429) {
            DLOG_F(WARNING, "too many request retry");
            std::this_thread::sleep_for(1s);
            answer = price_converter(request);
        }
    }
}

namespace atomic_dex {
    atomic_dex::coinpaprika_provider::coinpaprika_provider(entt::registry &registry, mm2 &mm2_instance) : system(
            registry), instance_(mm2_instance) {
        disable();
        this->dispatcher_.sink<atomic_dex::mm2_started>().connect<&coinpaprika_provider::on_mm2_started>(*this);
    }

    void coinpaprika_provider::update() noexcept {
    }

    coinpaprika_provider::~coinpaprika_provider() noexcept {
        provider_thread_timer_.interrupt();
        provider_rates_thread_.join();
    }

    void coinpaprika_provider::on_mm2_started([[maybe_unused]] const atomic_dex::mm2_started &evt) noexcept {
        LOG_SCOPE_FUNCTION(INFO);
        provider_rates_thread_ = std::thread([this]() {
            loguru::set_thread_name("paprika thread");
            LOG_SCOPE_F(INFO, "paprika thread started");
            using namespace std::chrono_literals;
            do {
                DLOG_F(INFO, "refreshing rate conversion from coinpaprika");
                auto coins = instance_.get_enabled_coins();
                for (auto &&current_coin : coins) {
                    if (current_coin.coinpaprika_id == "test-coin")
                        continue;
                    auto base = current_coin.coinpaprika_id;
                    //! do usd first
                    coinpaprika::api::price_converter_request request{.base_currency_id = base,
                            .quote_currency_id = "usd-us-dollars",
                            .amount = 1};
                    auto answer = coinpaprika::api::price_converter(request);
                    retry(answer, request);
                    usd_rate_providers_.insert_or_assign(current_coin.ticker, answer.price);
                }
            } while (not provider_thread_timer_.wait_for(30s));
        });
    }

    std::string coinpaprika_provider::get_price_in_fiat(const std::string &fiat, const std::string &ticker,
                                                        std::error_code &ec) noexcept {
        if (!supported_fiat_.count(fiat)) {
            ec = mm2_error::invalid_fiat_for_rate_conversion;
            return "";
        }

        std::string price;
        if (fiat == "USD") {
            //! Do it as usd;
            if (usd_rate_providers_.find(ticker) == usd_rate_providers_.cend()) {
                ec = mm2_error::unknown_ticker_for_rate_conversion;
                return "";
            }
            price = usd_rate_providers_.at(ticker);
        } else if (fiat == "EUR") {
            if (eur_rate_providers_.find(ticker) == eur_rate_providers_.cend()) {
                ec = mm2_error::unknown_ticker_for_rate_conversion;
                return "";
            }
            price = eur_rate_providers_.at(ticker);
        }
        std::error_code t_ec;
        std::string amount = instance_.my_balance(ticker, t_ec);
        if (t_ec) {
            LOG_F(ERROR, "my_balance error: {}", t_ec.message());
            return "";
        }
        namespace bm = boost::multiprecision;
        bm::cpp_dec_float_50 price_f(price);
        bm::cpp_dec_float_50 amount_f(amount);
        auto final_price = price_f * amount_f;
        std::stringstream ss;
        ss.precision(2);
        ss << final_price;
        return ss.str();
    }

    namespace coinpaprika::api {
        void to_json(nlohmann::json &j, const price_converter_request &evt) {
            LOG_SCOPE_FUNCTION(INFO);
            j["base_currency_id"] = evt.base_currency_id;
            j["quote_currency_id"] = evt.quote_currency_id;
            j["amount"] = evt.amount;
        }

        void from_json(const nlohmann::json &j, coinpaprika::api::price_converter_answer &evt) {
            LOG_SCOPE_FUNCTION(INFO);
            evt.base_currency_id = j.at("base_currency_id").get<std::string>();
            evt.base_currency_name = j.at("base_currency_name").get<std::string>();
            evt.base_price_last_updated = j.at("base_price_last_updated").get<std::string>();
            evt.quote_currency_id = j.at("quote_currency_id").get<std::string>();
            evt.quote_currency_name = j.at("quote_currency_name").get<std::string>();
            evt.quote_price_last_updated = j.at("quote_price_last_updated").get<std::string>();
            evt.amount = j.at("amount").get<int64_t>();
            atomic_dex::utils::my_json_sax sx;
            nlohmann::json::sax_parse(j.dump(), &sx);
            evt.price = sx.float_as_string;
        }

        price_converter_answer price_converter(const price_converter_request &request) {
            LOG_SCOPE_FUNCTION(INFO);

            using namespace std::string_literals;
            std::string url = std::string(coinpaprika_endpoint) + "price-converter?base_currency_id="s +
                              request.base_currency_id +
                              "&quote_currency_id="s + request.quote_currency_id + "&amount=1";
            DVLOG_F(loguru::Verbosity_INFO, "url: {}", url);
            const auto resp = RestClient::get(url);
            DVLOG_F(loguru::Verbosity_INFO, "resp: {}", resp.body);
            price_converter_answer answer;
            if (resp.code == 400) {
                DVLOG_F(loguru::Verbosity_WARNING, "rpc answer code is 400 (Bad Parameters)");
                answer.rpc_result_code = resp.code;
                answer.raw_result = resp.body;
                return answer;
            } else if (resp.code == 429) {
                DVLOG_F(loguru::Verbosity_WARNING, "rpc answer code is 429 (Too Many requests)");
                answer.rpc_result_code = resp.code;
                answer.raw_result = resp.body;
                return answer;
            }
            try {
                auto json_answer = nlohmann::json::parse(resp.body);
                from_json(json_answer, answer);
                answer.rpc_result_code = resp.code;
                answer.raw_result = resp.body;
            } catch (const std::exception &error) {
                VLOG_F(loguru::Verbosity_ERROR, "{}", error.what());
                answer.rpc_result_code = -1;
                answer.raw_result = error.what();
            }
            return answer;
        }
    }
}