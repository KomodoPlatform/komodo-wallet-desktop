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

//! Project Headers
#include "kdf.error.code.hpp"

namespace
{
    class kdf_error_category_impl final : public std::error_category
    {
      public:
        [[nodiscard]] const char* name() const noexcept final;

        [[nodiscard]] std::string message(int code) const  final;
    };

    const char*
    kdf_error_category_impl::name() const noexcept
    {
        return "kdf";
    }

    std::string
    kdf_error_category_impl::message(int code) const 
    {
        switch (static_cast<dextop_error>(code))
        {
        case dextop_error::success:
            return "";
        case dextop_error::balance_of_a_non_enabled_coin:
            return "You try to retrieve the balance of an unactivated coin";
        case dextop_error::unknown_error:
            return "Unknown error happened";
        case dextop_error::tx_history_of_a_non_enabled_coin:
            return "You try to retrieve the transaction history of an unactivated coin";
        case dextop_error::rpc_withdraw_error:
            return "An RPC error occur when processing the withdraw request, please check your request or the "
                   "application log.";
        case dextop_error::rpc_send_raw_transaction_error:
            return "An RPC error occur when processing the send_raw_transaction request, please check your tx_hex or "
                   "the application log.";
        case dextop_error::invalid_fiat_for_rate_conversion:
            return "You try to convert to a fiat that is not supported, only USD and EUR supported";
        case dextop_error::unknown_ticker_for_rate_conversion:
            return "You try to convert from an unknown ticker, are you trying to convert from a test-coin ?";
        case dextop_error::orderbook_empty:
            return "You try to retrieve an orderbook but you didn't load any coin (base / rel)";
        case dextop_error::balance_not_enough_found:
            return "You don't have enough funds for this operation, sorry.";
        case dextop_error::rpc_buy_error:
            return "An RPC error occur when processing the buy request, please check your request or the application "
                   "log.";
        case dextop_error::unknown_ticker:
            return "You try to retrieve information from an Unknown ticker.";
        case dextop_error::rpc_sell_error:
            return "An RPC error occur when processing the sell request, please check your request or the application "
                   "log.";
        case dextop_error::derive_password_failed:
            return "Derivation of the password using libsodium failed.";
        case dextop_error::wrong_password:
            return "Wrong password";
        case dextop_error::corrupted_file_or_wrong_password:
            return "Wrong password, or the seed file is corrupted.";
        case dextop_error::disable_unknown_coin:
            return "You try to disable un unknown ticker, did you enable it before ?";
        case dextop_error::active_swap_is_using_the_coin:
            return "There're active swaps, try disabling it later.";
        case dextop_error::order_is_matched_at_the_moment:
            return "There're currently matching orders, try disabling it later.";
        case dextop_error::claim_not_enough_funds:
            return "You try to claim rewards but you don't have enough funds.";
        case dextop_error::ticker_is_not_claimable:
            return "You try to claim rewards from a ticker that don't have rewards feature";
        case dextop_error::order_not_available_yet:
            return "You try to retrieve orders, but it's not fetched yet, please try again later.";
        case dextop_error::orderbook_ticker_not_found:
            return "Ticker for this orderbook not found, maybe currently fetching it.";
        }
        return "";
    }

    const kdf_error_category_impl g_err_categ{};
} // namespace

std::error_code
make_error_code(dextop_error error) 
{
    return {static_cast<int>(error), g_err_categ};
}
