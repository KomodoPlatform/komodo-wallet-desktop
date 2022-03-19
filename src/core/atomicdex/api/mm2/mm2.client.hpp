#pragma once

// Std Headers
#include <functional>

// Deps Headers
#include <entt/core/attribute.h>

// Project Headers
#include "atomicdex/utilities/cpprestsdk.utilities.hpp"
#include "rpc.disable.hpp"
#include "rpc.recover.funds.hpp"
#include "rpc.hpp"

namespace atomic_dex
{
    class ENTT_API mm2_client
    {
        pplx::cancellation_token_source m_token_source;

      public:
        mm2_client()  = default;
        ~mm2_client() = default;

        //! Create the client
        void stop();

        //! API
        pplx::task<web::http::http_response> async_rpc_batch_standalone(nlohmann::json batch_array);

        template <mm2::api::rpc Rpc>
        void process_rpc_async(const std::function<void(typename Rpc::expected_answer_type)>& on_rpc_processed);

        //! Synced
        template <typename TRequest, typename TAnswer>
        TAnswer process_rpc(TRequest&& request, std::string rpc_command);

        template <typename RpcReturnType>
        RpcReturnType rpc_process_answer(const web::http::http_response& resp, const std::string& rpc_command);

        t_disable_coin_answer          rpc_disable_coin(t_disable_coin_request&& request);
        t_recover_funds_of_swap_answer rpc_recover_funds(t_recover_funds_of_swap_request&& request);
    };
} // namespace atomic_dex