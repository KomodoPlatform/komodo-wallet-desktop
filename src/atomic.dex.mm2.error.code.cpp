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

//! Project Headers
#include "atomic.dex.mm2.error.code.hpp"

namespace
{
    class mm2_error_category_impl final : public std::error_category
    {
      public:
        [[nodiscard]] const char* name() const noexcept final;

        [[nodiscard]] std::string message(int code) const noexcept final;
    };

    const char*
    mm2_error_category_impl::name() const noexcept
    {
        return "mm2";
    }

    std::string
    mm2_error_category_impl::message(int code) const noexcept
    {
        switch (static_cast<mm2_error>(code))
        {
        case mm2_error::success:
            return "";
        case mm2_error::balance_of_a_non_enabled_coin:
            return "You try to retrieve the balance of an unactivated coin";
        case mm2_error::unknown_error:
            return "Unknown error happened";
        case mm2_error::tx_history_of_a_non_enabled_coin:
            return "You try to retrieve the transaction history of an unactivated coin";
        case mm2_error::rpc_withdraw_error:
            return "An RPC error occur when processing the withdraw request, please check your request or the "
                   "application log.";
        case mm2_error::rpc_send_raw_transaction_error:
            return "An RPC error occur when processing the send_raw_transaction request, please check your tx_hex or "
                   "the application log.";
        case mm2_error::invalid_fiat_for_rate_conversion:
            return "You try to convert to a fiat that is not supported, only USD and EUR supported";
        case mm2_error::unknown_ticker_for_rate_conversion:
            return "You try to convert from an unknown ticker, are you trying to convert from a test-coin ?";
        case mm2_error::orderbook_empty:
            return "You try to retrieve an orderbook but you didn't load any coin (base / rel)";
        case mm2_error::balance_not_enough_found:
            return "You don't have enough funds for this operation, sorry.";
        case mm2_error::rpc_buy_error:
            return "An RPC error occur when processing the buy request, please check your request or the application "
                   "log.";
        }
        return "";
    }

    const mm2_error_category_impl g_err_categ{};
} // namespace

std::error_code
make_error_code(mm2_error error) noexcept
{
    return {static_cast<int>(error), g_err_categ};
}
