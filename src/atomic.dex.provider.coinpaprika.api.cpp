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
#include "atomic.dex.provider.coinpaprika.api.hpp"
#include "atomic.dex.http.code.hpp"
#include "atomic.dex.utilities.hpp"

namespace
{
    //! Constants
    constexpr const char* g_coinpaprika_endpoint = "https://api.coinpaprika.com/v1/";
} // namespace

namespace atomic_dex
{
    namespace coinpaprika::api
    {
        void
        to_json(nlohmann::json& j, const price_converter_request& evt)
        {
            spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

            j["base_currency_id"]  = evt.base_currency_id;
            j["quote_currency_id"] = evt.quote_currency_id;
            j["amount"]            = 1;
        }

        void
        from_json(const nlohmann::json& j, price_converter_answer& evt)
        {
            spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

            utils::my_json_sax sx;
            nlohmann::json::sax_parse(j.dump(), &sx);

            evt.base_currency_id         = j.at("base_currency_id").get<std::string>();
            evt.base_currency_name       = j.at("base_currency_name").get<std::string>();
            evt.base_price_last_updated  = j.at("base_price_last_updated").get<std::string>();
            evt.quote_currency_id        = j.at("quote_currency_id").get<std::string>();
            evt.quote_currency_name      = j.at("quote_currency_name").get<std::string>();
            evt.quote_price_last_updated = j.at("quote_price_last_updated").get<std::string>();
            evt.amount                   = j.at("amount").get<int64_t>();
            evt.price                    = sx.float_as_string;

            std::replace(evt.price.begin(), evt.price.end(), ',', '.');
        }

        void
        from_json(const nlohmann::json& j, ticker_info_answer& evt)
        {
            evt.answer = j.at("quotes");
        }

        void
        from_json(const nlohmann::json& j, ticker_historical_answer& evt)
        {
            evt.answer = j;
        }

        price_converter_answer
        price_converter(const price_converter_request& request)
        {
            using namespace std::string_literals;

            spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

            auto&& [base_id, quote_id] = request;
            const auto url  = g_coinpaprika_endpoint + "price-converter?base_currency_id="s + base_id + "&quote_currency_id="s + quote_id + "&amount=1"s;
            const auto resp = RestClient::get(url);
            price_converter_answer answer;

            spdlog::info("url: {}", url);
            spdlog::info("{} l{} resp code: {}", __FUNCTION__, __LINE__, resp.code);

            if (resp.code == e_http_code::bad_request)
            {
                spdlog::warn("rpc answer code is 400 (Bad Parameters), body: {}", resp.body);
                answer.rpc_result_code = resp.code;
                answer.raw_result      = resp.body;
                return answer;
            }
            if (resp.code == e_http_code::too_many_requests)
            {
                spdlog::warn("rpc answer code is 429 (Too Many requests), body: {}", resp.body);
                answer.rpc_result_code = resp.code;
                answer.raw_result      = resp.body;
                return answer;
            }
            try
            {
                const auto json_answer = nlohmann::json::parse(resp.body);
                from_json(json_answer, answer);
                answer.rpc_result_code = resp.code;
                answer.raw_result      = resp.body;
            }
            catch (const std::exception& error)
            {
                spdlog::warn("{}", error.what());
                answer.rpc_result_code = -1;
                answer.raw_result      = error.what();
            }

            return answer;
        }

        ticker_info_answer
        tickers_info(const ticker_infos_request& request)
        {
            using ranges::views::ints;
            using ranges::views::zip;
            using namespace std::string_literals;

            spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

            auto&& [ticker_id, quotes] = request;
            auto url                   = g_coinpaprika_endpoint + "tickers/"s + ticker_id + "?quotes=";

            for (auto&& [cur_quote, idx]: zip(quotes, ints(0u, ranges::unreachable)))
            {
                url.append(cur_quote);

                //! Append only if not last element, idx start at 0, if idx + 1 == quotes.size(), we are on the last elemnt, we don't append.
                if (idx < quotes.size() - 1)
                {
                    url.append(",");
                }
            }

            const auto         resp = RestClient::get(url);
            ticker_info_answer answer;

            spdlog::info("url: {}", url);
            spdlog::info("{} l{} resp code: {}", __FUNCTION__, __LINE__, resp.code);

            if (resp.code == e_http_code::bad_request)
            {
                spdlog::warn("rpc answer code is 400 (Bad Parameters), body: {}", resp.body);
                answer.rpc_result_code = resp.code;
                answer.raw_result      = resp.body;
                return answer;
            }
            if (resp.code == e_http_code::too_many_requests)
            {
                spdlog::warn("rpc answer code is 429 (Too Many requests), body: {}", resp.body);
                answer.rpc_result_code = resp.code;
                answer.raw_result      = resp.body;
                return answer;
            }

            try
            {
                const auto json_answer = nlohmann::json::parse(resp.body);
                from_json(json_answer, answer);
                answer.rpc_result_code = resp.code;
                answer.raw_result      = resp.body;
            }
            catch (const std::exception& error)
            {
                spdlog::warn("{}", error.what());
                answer.rpc_result_code = -1;
                answer.raw_result      = error.what();
            }

            return answer;
        }

        ticker_historical_answer
        ticker_historical(const ticker_historical_request& request)
        {
            using namespace std::string_literals;

            spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

            auto&& [ticker_id, timestamp, interval] = request;
            auto url = g_coinpaprika_endpoint + "tickers/"s + ticker_id + "/historical?start="s + std::to_string(timestamp) + "&interval="s + interval;

            const auto               resp = RestClient::get(url);
            ticker_historical_answer answer;

            spdlog::info("url: {}", url);
            spdlog::info("{} l{} resp code: {}", __FUNCTION__, __LINE__, resp.code);

            if (resp.code == e_http_code::bad_request)
            {
                spdlog::warn("rpc answer code is 400 (Bad Parameters), body: {}", resp.body);
                answer.rpc_result_code = resp.code;
                answer.raw_result      = resp.body;
                return answer;
            }
            if (resp.code == e_http_code::too_many_requests)
            {
                spdlog::warn("rpc answer code is 429 (Too Many requests), body: {}", resp.body);
                answer.rpc_result_code = resp.code;
                answer.raw_result      = resp.body;
                return answer;
            }

            try
            {
                const auto json_answer = nlohmann::json::parse(resp.body);
                from_json(json_answer, answer);
                answer.rpc_result_code = resp.code;
                answer.raw_result      = resp.body;
            }
            catch (const std::exception& error)
            {
                spdlog::warn("{}", error.what());
                answer.rpc_result_code = -1;
                answer.raw_result      = error.what();
            }

            return answer;
        }
    } // namespace coinpaprika::api
} // namespace atomic_dex