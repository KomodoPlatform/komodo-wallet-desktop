/******************************************************************************
 * Copyright © 2013-2024 The Komodo Platform Developers.                      *
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

#include <filesystem>

#include <meta/detection/detection.hpp>

#include "kdf.hpp"
#include "atomicdex/api/kdf/rpc.hpp"
#include "kdf.client.hpp"
#include "rpc.tx.history.hpp"
#include "atomicdex/constants/dex.constants.hpp"
#include "atomicdex/api/kdf/rpc_v1/rpc.my_tx_history.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.get_public_key.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.my_tx_history.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.orderbook.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.bestorders.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.enable_tendermint_token.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.enable_tendermint_with_assets.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.enable_erc20.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.enable_eth_with_tokens.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.enable_slp_rpc.hpp"
#include "atomicdex/api/kdf/rpc_v2/rpc2.enable_bch_with_tokens_rpc.hpp"

namespace
{
    template <typename T>
    using have_error_field = decltype(std::declval<T&>().error.has_value());

    t_http_client generate_client()
    {
        using namespace std::chrono_literals;
        
        //constexpr auto                          client_timeout = 30s;
        web::http::client::http_client_config   cfg;

        //cfg.set_timeout(client_timeout);
        return {FROM_STD_STR(atomic_dex::g_dex_rpc), cfg};
    }

    template <atomic_dex::kdf::rpc Rpc>
    web::http::http_request make_request(typename Rpc::expected_request_type data_req = {})
    {
        web::http::http_request request;
        nlohmann::json json_req = {{"method", Rpc::endpoint}, {"userpass", atomic_dex::kdf::get_rpc_password()}};
        nlohmann::json json_data;

        nlohmann::to_json(json_data, data_req);
        request.set_method(web::http::methods::POST);
        if (Rpc::is_v2)
        {
            json_req["mmrpc"] = "2.0";
            json_req["id"] = 42;
            json_req.push_back({"params", json_data});
        }
        else
        {
            json_req.insert(json_req.end(), json_data);
        }
        request.set_body(json_req.dump());
        // SPDLOG_DEBUG("request: {}", json_req.dump());
        return request;
    }



    template <atomic_dex::kdf::rpc Rpc>
    Rpc process_rpc_answer(const web::http::http_response& answer)
    {
        Rpc rpc;
        std::string body;

        try
        {
            body = TO_STD_STR(answer.extract_string(true).get());
            nlohmann::json json_answer = nlohmann::json::parse(body);
            // SPDLOG_DEBUG("json_answer: {}", json_answer.dump(4));

            if (Rpc::is_v2)
            {
                handle_v2_response(answer, json_answer, rpc);
            }
            else
            {
                handle_v1_response(json_answer, rpc);
            }
        }
        catch (const nlohmann::json::parse_error& error)
        {
            SPDLOG_ERROR("RPC answer JSON parsing error: {}", error.what());
            rpc.raw_result = body;
        }
        catch (const std::exception& e)
        {
            SPDLOG_ERROR("Exception in RPC processing: {}", e.what());
            rpc.raw_result = body;
        }

        return rpc;
    }
} // namespace

namespace atomic_dex::kdf
{
    template <typename RpcReturnType>
    RpcReturnType kdf_client::rpc_process_answer(const web::http::http_response& resp, const std::string& rpc_command)
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
                "{} l{} f[{}], exception caught {} for rpc {}, body: {}", __FUNCTION__, __LINE__, std::filesystem::path(__FILE__).filename().string(), error.what(),
                rpc_command, body);
            answer.rpc_result_code = -1;
            answer.raw_result      = error.what();
        }

        return answer;
    }

    pplx::task<web::http::http_response>
    kdf_client::async_rpc_batch_standalone(nlohmann::json batch_array)
    {
        // Create the HTTP request object
        web::http::http_request request;
        request.set_method(web::http::methods::POST);

        try
        {
            // Serialize the batch array to a string and set it as the body
            std::string body = batch_array.dump();
            request.set_body(body);
            
            // Log the outgoing request for debugging
            // auto json_copy        = batch_array[0];
            // json_copy["userpass"] = "*******";
            // SPDLOG_INFO("Sending RPC batch request with {} commands. Body of first request: {}", batch_array.size(), json_copy.dump());

            // Generate the client and send the request, passing the cancellation token
            auto resp = generate_client().request(request, m_token_source.get_token());

            // Return the response task to the caller, handling errors asynchronously
            return resp.then([body](pplx::task<web::http::http_response> previousTask)
            {
                try
                {
                    // Retrieve the HTTP response from the task
                    auto response = previousTask.get();
                    // Extract the response body as a string
                    // auto resp_status = response.status_code();
                    // Log the response body
                    // SPDLOG_INFO("Body: {} \nHTTP status: {}", body, resp_status);
                    return response;
                }
                catch (const web::http::http_exception& e)
                {
                    SPDLOG_ERROR("HTTP exception caught during batch request: {}", e.what());
                    throw;  // Re-throw or return an appropriate error response
                }
                catch (const std::exception& e)
                {
                    SPDLOG_ERROR("General exception caught during batch request: {}", e.what());
                    throw;  // Re-throw to allow the caller to handle it
                }
            });
        }
        catch (const std::exception& e)
        {
            // Catch any exceptions from batch_array.dump() or request creation
            SPDLOG_ERROR("Exception caught during batch request creation: {}", e.what());
            throw;  // Re-throw or handle the exception appropriately
        }
    }

    template <rpc Rpc>
    void kdf_client::process_rpc_async(const std::function<void(Rpc)>& on_rpc_processed)
    {
        using request_type = typename Rpc::expected_request_type;
        process_rpc_async(request_type{}, on_rpc_processed);
    }

    // template void kdf_client::process_rpc_async<my_balance_rpc>(const std::function<void(orderbook_rpc)>&);
    template void kdf_client::process_rpc_async<orderbook_rpc>(const std::function<void(orderbook_rpc)>&);
    template void kdf_client::process_rpc_async<bestorders_rpc>(const std::function<void(bestorders_rpc)>&);
    template void kdf_client::process_rpc_async<enable_slp_rpc>(const std::function<void(enable_slp_rpc)>&);
    template void kdf_client::process_rpc_async<enable_erc20_rpc>(const std::function<void(enable_erc20_rpc)>&);
    template void kdf_client::process_rpc_async<get_public_key_rpc>(const std::function<void(get_public_key_rpc)>&);
    template void kdf_client::process_rpc_async<my_tx_history_v1_rpc>(const std::function<void(my_tx_history_v1_rpc)>&);
    template void kdf_client::process_rpc_async<my_tx_history_v2_rpc>(const std::function<void(my_tx_history_v2_rpc)>&);
    template void kdf_client::process_rpc_async<enable_eth_with_tokens_rpc>(const std::function<void(enable_eth_with_tokens_rpc)>&);
    template void kdf_client::process_rpc_async<enable_bch_with_tokens_rpc>(const std::function<void(enable_bch_with_tokens_rpc)>&);
    template void kdf_client::process_rpc_async<enable_tendermint_token_rpc>(const std::function<void(enable_tendermint_token_rpc)>&);
    template void kdf_client::process_rpc_async<enable_tendermint_with_assets_rpc>(const std::function<void(enable_tendermint_with_assets_rpc)>&);
    
    template <kdf::rpc Rpc>
    void kdf_client::process_rpc_async(typename Rpc::expected_request_type request, const std::function<void(Rpc)>& on_rpc_processed)
    {
        auto http_request = make_request<Rpc>(request);
        generate_client()
            .request(http_request, m_token_source.get_token())
            .template then([on_rpc_processed, request](const web::http::http_response& resp)
                {
                    try
                    {
                        auto rpc = process_rpc_answer<Rpc>(resp);
                        rpc.request = request;
                        on_rpc_processed(rpc);
                    }
                    catch (const std::exception& ex)
                    {
                        SPDLOG_ERROR(ex.what());
                    }
                }
            );
    }

    void
    kdf_client::stop()
    {
        m_token_source.cancel();
    }

    template <typename TRequest, typename TAnswer>
    TAnswer
    kdf_client::process_rpc(TRequest&& request, std::string rpc_command, bool is_v2)
    {
        SPDLOG_DEBUG("Processing rpc call: {}", rpc_command);

        nlohmann::json json_data = kdf::template_request(rpc_command, is_v2);

        kdf::to_json(json_data, request);

        auto json_copy        = json_data;
        json_copy["userpass"] = "*******";
        SPDLOG_DEBUG("request: {}", json_copy.dump());

        web::http::http_request rpc_request(web::http::methods::POST);
        rpc_request.headers().set_content_type(FROM_STD_STR("application/json"));
        rpc_request.set_body(json_data.dump());
        auto resp = generate_client().request(rpc_request).get();
        return rpc_process_answer<TAnswer>(resp, rpc_command);
    }

    t_enable_z_coin_cancel_answer
    kdf_client::rpc_enable_z_coin_cancel(t_enable_z_coin_cancel_request&& request)
    {
        return process_rpc<t_enable_z_coin_cancel_request, t_enable_z_coin_cancel_answer>(std::forward<t_enable_z_coin_cancel_request>(request), "task::enable_z_coin::cancel", true);
    }

    t_disable_coin_answer
    kdf_client::rpc_disable_coin(t_disable_coin_request&& request)
    {
        return process_rpc<t_disable_coin_request, t_disable_coin_answer>(std::forward<t_disable_coin_request>(request), "disable_coin");
    }

    t_recover_funds_of_swap_answer
    kdf_client::rpc_recover_funds(t_recover_funds_of_swap_request&& request)
    {
        return process_rpc<t_recover_funds_of_swap_request, t_recover_funds_of_swap_answer>(
            std::forward<t_recover_funds_of_swap_request>(request), "recover_funds_of_swap");
    }

    // Helper functions to reduce code duplication and improve clarity
    template <atomic_dex::kdf::rpc Rpc>
    void handle_v2_response(const web::http::http_response& answer, const nlohmann::json& json_answer, Rpc& rpc)
    {
        if (answer.status_code() == 200)
        {
            if (json_answer.contains("result"))
            {
                rpc.result = json_answer.at("result").get<typename Rpc::expected_result_type>();
                rpc.raw_result = json_answer.at("result").dump();
            }
            else
            {
                SPDLOG_WARN("Expected 'result' field missing in v2 response");
            }
        }
        else
        {
            if (json_answer.contains("error"))
            {
                rpc.error = json_answer.get<typename Rpc::expected_error_type>();
            }
            else
            {
                SPDLOG_WARN("Expected 'error' field missing in v2 error response");
            }
            rpc.raw_result = json_answer.dump();
            SPDLOG_DEBUG("RPC v2 error {} answer: {}", answer.status_code(), rpc.raw_result);
        }
    }

    template <atomic_dex::kdf::rpc Rpc>
    void handle_v1_response(const nlohmann::json& json_answer, Rpc& rpc)
    {
        if (json_answer.contains("result"))
        {
            rpc.result = json_answer.get<typename Rpc::expected_result_type>();
        }
        else
        {
            SPDLOG_DEBUG("RPC v1 error: {}", json_answer.dump());
            SPDLOG_WARN("Expected 'result' field missing in v1 response");
        }
    }
} // namespace atomic_dex

template atomic_dex::kdf::tx_history_answer   atomic_dex::kdf::kdf_client::rpc_process_answer(const web::http::http_response& resp, const std::string& rpc_command);
template atomic_dex::kdf::disable_coin_answer atomic_dex::kdf::kdf_client::rpc_process_answer(const web::http::http_response& resp, const std::string& rpc_command);
