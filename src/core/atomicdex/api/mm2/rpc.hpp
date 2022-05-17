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

#pragma once

// Std Headers
#include <type_traits>

// Project Headers
#include "../api.call.hpp"

namespace mm2::api
{
    template <typename Rpc>
    concept rpc = requires(Rpc rpc)
    {
        atomic_dex::api_call<Rpc> && Rpc::is_v2 && std::is_same_v<decltype(Rpc::is_v2), bool>;
    };
}
