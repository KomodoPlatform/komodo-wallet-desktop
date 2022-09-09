// atomicdex-desktop
// Author(s): syl

#pragma once

#include <string>

#include "atomicdex/api/mm2/transaction.data.hpp"

namespace atomic_dex::mm2
{
    struct transactions_fetched_event
    {
        std::string                     ticker;
        std::vector<transaction_data>   transactions;
    };
}