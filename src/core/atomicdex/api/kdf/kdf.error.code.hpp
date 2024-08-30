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

#pragma once

enum class dextop_error
{
    success,
    balance_of_a_non_enabled_coin,
    tx_history_of_a_non_enabled_coin,
    rpc_withdraw_error,
    rpc_send_raw_transaction_error,
    rpc_buy_error,
    rpc_sell_error,
    derive_password_failed,
    wrong_password,
    disable_unknown_coin,
    active_swap_is_using_the_coin,
    order_is_matched_at_the_moment,
    corrupted_file_or_wrong_password,
    invalid_fiat_for_rate_conversion,
    unknown_ticker,
    unknown_ticker_for_rate_conversion,
    orderbook_empty,
    balance_not_enough_found,
    claim_not_enough_funds,
    ticker_is_not_claimable,
    order_not_available_yet,
    orderbook_ticker_not_found,
    unknown_error
};

namespace std
{
    template <>
    struct is_error_code_enum<dextop_error> : true_type
    {
    };
} // namespace std

std::error_code make_error_code(dextop_error error) ;

namespace atomic_dex
{
    using t_kdf_ec = std::error_code;
} // namespace atomic_dex
