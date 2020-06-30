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

#include "atomic.dex.provider.cex.prices.provider.api.hpp"

namespace atomic_dex
{
    inline constexpr const char* g_cex_endpoint = "http://komodo.live:3333/";
}

//! Json Serialization / Deserialization functions
namespace atomic_dex
{
    void
    from_json(const nlohmann::json& j, ohlc_answer_success& answer)
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

        for (const auto& [key, value]: j.items())
        {
            ohlc_answer_success::t_ohlc_contents contents;
            for (const auto& c_value: value.items())
            {
                auto cur_value = c_value.value();

                contents.emplace_back(ohlc_contents{
                    .close_time_timestamp         = cur_value.at("timestamp").get<std::size_t>(),
                    .human_readeable_closing_time = "todo",
                    .open                         = std::to_string(cur_value.at("open").get<float>()),
                    .high                         = std::to_string(cur_value.at("high").get<float>()),
                    .low                          = std::to_string(cur_value.at("low").get<float>()),
                    .close                        = std::to_string(cur_value.at("close").get<float>()),
                    .volume                       = std::to_string(cur_value.at("volume").get<float>()),
                    .quote_volume                 = std::to_string(cur_value.at("quote_volume").get<float>())});
            }
            answer.result.insert({key, contents});
        }
    }

    void
    from_json(const nlohmann::json& j, ohlc_answer& answer)
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

        if (j.contains("60"))
        {
            answer.result = ohlc_answer_success{};
            from_json(j, answer.result.value());
        }
    }
} // namespace atomic_dex