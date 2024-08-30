// komodo-wallet
// Author(s): syl

#pragma once

#include "atomicdex/api/kdf/rpc.hpp"

namespace atomic_dex::kdf
{
    struct my_tx_history_v1_rpc
    {
        static constexpr auto endpoint = "my_tx_history";
        static constexpr bool is_v2     = false;
        
        using expected_request_type = tx_history_request;
        
        using expected_result_type = tx_history_answer_success;
        
        using expected_error_type = rpc_basic_error_type;
        
        expected_request_type                   request;
        std::optional<expected_result_type>     result;
        std::optional<expected_error_type>      error;
        std::string                             raw_result;
    };
    
    using my_tx_history_request_v1_rpc    = my_tx_history_v1_rpc::expected_request_type;
    using my_tx_history_result_v1_rpc     = my_tx_history_v1_rpc::expected_result_type;
    using my_tx_history_error_v1_rpc      = my_tx_history_v1_rpc::expected_error_type;
}