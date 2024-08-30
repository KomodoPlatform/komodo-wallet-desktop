#pragma once

//! C Headers
#include <cstddef>

//! C++ System Headers
#include <string>
#include <vector>

//! Project Headers
#include "atomicdex/api/kdf/kdf.error.code.hpp"

namespace atomic_dex
{
    struct tx_infos
    {
        bool                     am_i_sender;
        std::size_t              confirmations;
        std::vector<std::string> from;
        std::vector<std::string> to;
        std::string              date;
        std::size_t              timestamp;
        std::string              tx_hash;
        std::string              fees;
        std::string              my_balance_change;
        std::string              total_amount;
        std::size_t              block_height;
        t_kdf_ec                 ec{dextop_error::success};
        bool                     unconfirmed{false};
        std::string              transaction_note{""};
    };

    struct tx_state
    {
        std::string state;
        std::size_t current_block;
        std::size_t blocks_left;
        std::size_t transactions_left;
    };

    using t_transactions = std::vector<tx_infos>;
    using t_tx_state     = tx_state;
} // namespace atomic_dex