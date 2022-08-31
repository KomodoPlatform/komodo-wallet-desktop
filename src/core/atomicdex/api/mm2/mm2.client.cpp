/******************************************************************************
 * Copyright © 2013-2022 The Komodo Platform Developers.                      *
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

// Deps Headers
#include <meta/detection/detection.hpp>

// Project Headers
#include "atomicdex/api/mm2/mm2.client.hpp"
#include "atomicdex/api/mm2/mm2.hpp"
#include "atomicdex/api/mm2/rpc.tx.history.hpp"
#include "atomicdex/constants/dex.constants.hpp"
#include "rpc.get.public.key.hpp"
#include "rpc.hpp"

namespace
{
    template <typename T>
    using have_error_field = decltype(std::declval<T&>().error.has_value());

    t_http_client generate_client()
    {
        web::http::client::http_client_config cfg;
        using namespace std::chrono_literals;
        cfg.set_timeout(30s);
        return web::http::client::http_client(FROM_STD_STR(atomic_dex::g_dex_rpc), cfg);
    }

    template <mm2::api::rpc Rpc>
    web::http::http_request make_request(typename Rpc::expected_request_type data_req = {})
    {
        web::http::http_request request;
        nlohmann::json json_req = {{"method", Rpc::endpoint}, {"userpass", mm2::api::get_rpc_password()}};

        request.set_method(web::http::methods::POST);
        if (Rpc::is_v2)
        {
            json_req["mmrpc"] = "2.0";
            json_req.push_back({"params", data_req});
        }
        else
        {
            json_req.insert(json_req.end(), nlohmann::json(data_req));
        }
        request.set_body(json_req.dump());
        return request;
    }

    template <mm2::api::rpc Rpc>
    typename Rpc::expected_answer_type make_answer(const web::http::http_response& answer)
    {
        auto json_answer = nlohmann::json::parse(TO_STD_STR(answer.extract_string(true).get()));
        if (Rpc::is_v2)
        {
            return json_answer.at("result").get<typename Rpc::expected_answer_type>();
        }
        return json_answer.get<typename Rpc::expected_answer_type>();
    }
} // namespace

namespace atomic_dex
{
    template <typename RpcReturnType>
    RpcReturnType
    mm2_client::rpc_process_answer(const web::http::http_response& resp, const std::string& rpc_command)
    {
        std::string body = TO_STD_STR(resp.extract_string(true).get());
        SPDLOG_INFO("resp code for rpc_command {} is {}", rpc_command, resp.status_code());
        RpcReturnType answer;

        try
        {
            if (resp.status_code() not_eq 200)
            {
                SPDLOG_WARN("rpc answer code is not 200, body : {}", body);
                if constexpr (doom::meta::is_detected_v<have_error_field, RpcReturnType>)
                {
                    SPDLOG_DEBUG("error field detected inside the RpcReturnType");
                    if constexpr (std::is_same_v<std::optional<std::string>, decltype(answer.error)>)
                    {
                        SPDLOG_DEBUG("The error field type is string, parsing it from the response body");
                        if (auto json_data = nlohmann::json::parse(body); json_data.at("error").is_string())
                        {
                            answer.error = json_data.at("error").get<std::string>();
                        }
                        else
                        {
                            answer.error = body;
                        }
                        SPDLOG_DEBUG("The error after getting extracted is: {}", answer.error.value());
                    }
                }
                answer.rpc_result_code = resp.status_code();
                answer.raw_result      = body;
                return answer;
            }


            assert(not body.empty());
            auto json_answer       = nlohmann::json::parse(body);
            answer.rpc_result_code = resp.status_code();
            answer.raw_result      = body;
            from_json(json_answer, answer);
        }
        catch (const std::exception& error)
        {
            SPDLOG_ERROR(
                "{} l{} f[{}], exception caught {} for rpc {}, body: {}", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string(), error.what(),
                rpc_command, body);
            answer.rpc_result_code = -1;
            answer.raw_result      = error.what();
        }

        return answer;
    }

    pplx::task<web::http::http_response>
    mm2_client::async_rpc_batch_standalone(nlohmann::json batch_array)
    {
        web::http::http_request request;
        request.set_method(web::http::methods::POST);
        request.set_body(batch_array.dump());
        auto resp = generate_client().request(request, m_token_source.get_token());
        return resp;
    }

    template <::mm2::api::rpc ApiCallType>
    void mm2_client::process_rpc_async(const std::function<void(typename ApiCallType::expected_answer_type)>& on_rpc_processed)
    {
        auto request = make_request<ApiCallType>();
        generate_client()
            .request(request, m_token_source.get_token())
            .template then([on_rpc_processed](const web::http::http_response& resp)
                           {
                               try
                               {
                                   auto answer = make_answer<ApiCallType>(resp);
                                   on_rpc_processed(answer);
                               }
                               catch (const std::exception& ex)
                               {
                                   SPDLOG_ERROR(ex.what());
                               }
                           });
    }

    template void mm2_client::process_rpc_async<atomic_dex::mm2::get_public_key>(const std::function<void(mm2::get_public_key_answer)>&);

    void
    mm2_client::stop()
    {
        m_token_source.cancel();
    }

    template <typename TRequest, typename TAnswer>
    TAnswer
    mm2_client::process_rpc(TRequest&& request, std::string rpc_command)
    {
        SPDLOG_INFO("Processing rpc call: {}", rpc_command);

        nlohmann::json json_data = ::mm2::api::template_request(rpc_command);

        ::mm2::api::to_json(json_data, request);

        auto json_copy        = json_data;
        json_copy["userpass"] = "*******";
        SPDLOG_DEBUG("request: {}", json_copy.dump());

        web::http::http_request rpc_request(web::http::methods::POST);
        rpc_request.headers().set_content_type(FROM_STD_STR("application/json"));
        rpc_request.set_body(json_data.dump());
        auto resp = generate_client().request(rpc_request).get();
        return rpc_process_answer<TAnswer>(resp, rpc_command);
    }

    t_disable_coin_answer
    mm2_client::rpc_disable_coin(t_disable_coin_request&& request)
    {
        return process_rpc<t_disable_coin_request, t_disable_coin_answer>(std::forward<t_disable_coin_request>(request), "disable_coin");
    }

    t_recover_funds_of_swap_answer
    mm2_client::rpc_recover_funds(t_recover_funds_of_swap_request&& request)
    {
        return process_rpc<t_recover_funds_of_swap_request, t_recover_funds_of_swap_answer>(
            std::forward<t_recover_funds_of_swap_request>(request), "recover_funds_of_swap");
    }
} // namespace atomic_dex

template mm2::api::tx_history_answer   atomic_dex::mm2_client::rpc_process_answer(const web::http::http_response& resp, const std::string& rpc_command);
template mm2::api::disable_coin_answer atomic_dex::mm2_client::rpc_process_answer(const web::http::http_response& resp, const std::string& rpc_command);