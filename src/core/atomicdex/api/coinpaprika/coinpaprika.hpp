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
#include <nlohmann/json.hpp>
#include <spdlog/spdlog.h>
#include <antara/app/net/http.code.hpp>

//! Project Headers
#include "atomicdex/utilities/cpprestsdk.utilities.hpp"

namespace
{
    constexpr const std::size_t g_nb_hours_in_a_week{168};
}

namespace atomic_dex
{
    namespace coinpaprika::api
    {
        struct ticker_historical_request
        {
            std::string ticker_currency_id;
            std::size_t timestamp{static_cast<size_t>(
                std::chrono::duration_cast<std::chrono::seconds>((std::chrono::system_clock::now() - std::chrono::hours(g_nb_hours_in_a_week)).time_since_epoch()).count())};
            std::string interval{"1d"};
        };

        struct ticker_historical_answer
        {
            nlohmann::json answer{nlohmann::json::array()};
            int            rpc_result_code;
            std::string    raw_result;
        };

        struct ticker_infos_request
        {
            std::string              ticker_currency_id;
            std::vector<std::string> ticker_quotes;
        };

        struct ticker_info_answer
        {
            nlohmann::json answer;
            int            rpc_result_code;
            std::string    raw_result;
        };

        struct price_converter_request
        {
            std::string base_currency_id;
            std::string quote_currency_id;
        };

        struct price_converter_answer
        {
            std::string base_currency_id;
            std::string base_currency_name;
            std::string base_price_last_updated;
            std::string quote_currency_id;
            std::string quote_currency_name;
            std::string quote_price_last_updated;
            std::size_t amount;
            std::string price{"0.00"}; ///< we need trick here
            int         rpc_result_code;
            std::string raw_result;
        };

        void to_json(nlohmann::json& j, const price_converter_request& evt);

        void from_json(const nlohmann::json& j, price_converter_answer& evt);

        void from_json(const nlohmann::json& j, ticker_info_answer& evt);

        void from_json(const nlohmann::json& j, ticker_historical_answer& evt);

        pplx::task<web::http::http_response> async_price_converter(const price_converter_request& request);
        pplx::task<web::http::http_response> async_ticker_info(const ticker_infos_request& request);
        pplx::task<web::http::http_response> async_ticker_historical(const ticker_historical_request& request);

        template <typename TAnswer>
        TAnswer static inline process_generic_resp(web::http::http_response resp)
        {
            TAnswer     answer;
            std::string body = TO_STD_STR(resp.extract_string(true).get());
            if (resp.status_code() == static_cast<web::http::status_code>(antara::app::http_code::bad_request))
            {
                SPDLOG_WARN("rpc answer code is 400 (Bad Parameters), body: {}", body);
                answer.rpc_result_code = resp.status_code();
                answer.raw_result      = body;
                return answer;
            }
            if (resp.status_code() == static_cast<web::http::status_code>(antara::app::http_code::too_many_requests))
            {
                SPDLOG_WARN("rpc answer code is 429 (Too Many requests), body: {}", body);
                answer.rpc_result_code = resp.status_code();
                answer.raw_result      = body;
                return answer;
            }
            try
            {
                const auto json_answer = nlohmann::json::parse(body);
                from_json(json_answer, answer);
                answer.rpc_result_code = resp.status_code();
                answer.raw_result      = body;
            }
            catch (const std::exception& error)
            {
                SPDLOG_ERROR("exception caught: error[{}], body: {}", error.what(), body);
                answer.rpc_result_code = -1;
                answer.raw_result      = error.what();
            }
            return answer;
        }
    } // namespace coinpaprika::api


    using t_price_converter_answer    = coinpaprika::api::price_converter_answer;
    using t_price_converter_request   = coinpaprika::api::price_converter_request;
    using t_ticker_info_answer        = coinpaprika::api::ticker_info_answer;
    using t_ticker_infos_request      = coinpaprika::api::ticker_infos_request;
    using t_ticker_historical_answer  = coinpaprika::api::ticker_historical_answer;
    using t_ticker_historical_request = coinpaprika::api::ticker_historical_request;
} // namespace atomic_dex
