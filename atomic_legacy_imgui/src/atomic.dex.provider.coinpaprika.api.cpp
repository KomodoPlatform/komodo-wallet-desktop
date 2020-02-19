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
            LOG_SCOPE_FUNCTION(INFO);

            j["base_currency_id"]  = evt.base_currency_id;
            j["quote_currency_id"] = evt.quote_currency_id;
            j["amount"]            = 1;
        }

        void
        from_json(const nlohmann::json& j, price_converter_answer& evt)
        {
            LOG_SCOPE_FUNCTION(INFO);

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

        price_converter_answer
        price_converter(const price_converter_request& request)
        {
            using namespace std::string_literals;

            LOG_SCOPE_FUNCTION(INFO);

            auto&& [base_id, quote_id] = request;
            const auto url  = g_coinpaprika_endpoint + "price-converter?base_currency_id="s + base_id + "&quote_currency_id="s + quote_id + "&amount=1"s;
            const auto resp = RestClient::get(url);
            price_converter_answer answer;

            DVLOG_F(loguru::Verbosity_INFO, "url: {}", url);
            DVLOG_F(loguru::Verbosity_INFO, "resp: {}", resp.body);

            if (resp.code == e_http_code::bad_request)
            {
                DVLOG_F(loguru::Verbosity_WARNING, "rpc answer code is 400 (Bad Parameters)");
                answer.rpc_result_code = resp.code;
                answer.raw_result      = resp.body;
                return answer;
            }
            if (resp.code == e_http_code::too_many_requests)
            {
                DVLOG_F(loguru::Verbosity_WARNING, "rpc answer code is 429 (Too Many requests)");
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
                VLOG_F(loguru::Verbosity_ERROR, "{}", error.what());
                answer.rpc_result_code = -1;
                answer.raw_result      = error.what();
            }

            return answer;
        }
    } // namespace coinpaprika::api
} // namespace atomic_dex