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

namespace atomic_dex
{
    namespace coinpaprika::api
    {
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
            std::string price; ///< we need trick here
            int         rpc_result_code;
            std::string raw_result;
        };

        void to_json(nlohmann::json& j, const price_converter_request& evt);

        void from_json(const nlohmann::json& j, price_converter_answer& evt);

        void from_json(const nlohmann::json& j, ticker_info_answer& evt);

        ticker_info_answer tickers_info(const ticker_infos_request& request);
        price_converter_answer price_converter(const price_converter_request& request);
    } // namespace coinpaprika::api


    using t_ticker_info_answer = coinpaprika::api::ticker_info_answer;
} // namespace atomic_dex