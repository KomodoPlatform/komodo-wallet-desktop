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

#pragma once

#include <system_error>
#include <type_traits>

enum class mm2_error
{
	success,
	balance_of_a_non_enabled_coin,
	tx_history_of_a_non_enabled_coin,
	rpc_withdraw_error,
	rpc_send_raw_transaction_error,
	invalid_fiat_for_rate_conversion,
	unknown_ticker_for_rate_conversion,
	orderbook_empty,
	unknown_error
};

namespace std
{
	template <>
	struct is_error_code_enum<mm2_error> : true_type
	{
	};
}

std::error_code make_error_code(mm2_error error) noexcept;
