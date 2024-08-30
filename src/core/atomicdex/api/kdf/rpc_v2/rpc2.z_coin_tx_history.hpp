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

// Std Headers
#include <string>
#include <optional>

// Deps Headers
#include <nlohmann/json_fwd.hpp>

//! Our Headers
#include "atomicdex/api/kdf/transaction.data.hpp"

namespace atomic_dex::kdf
{
    struct z_tx_history_request
    {
        std::string                                 coin;
        std::size_t                                 limit;
        //std::string                               from_id{''};
        //std::size_t                               page_number{1};
    };

    void to_json(nlohmann::json& j, const z_tx_history_request& request);

    //"coin","current_block","transactions","sync_status","sync_status","id"
    struct sync_status_z_error
    {
        std::string message;
        int         code;
    };

    void from_json(const nlohmann::json& j, sync_status_z_error& answer);

    struct sync_status_z_coins
    {
        std::size_t transactions_left;
    };

    void from_json(const nlohmann::json& j, sync_status_z_coins& answer);

    struct sync_status_z_additional_infos
    {
        std::optional<sync_status_z_error>    error;
        std::optional<sync_status_z_coins>    z_infos;
    };

    void from_json(const nlohmann::json& j, sync_status_z_additional_infos& answer);

    struct t_z_sync_status
    {
        std::string                                      state; ///< NotEnabled, NotStarted, InProgress, Error, Finished
        std::optional<sync_status_z_additional_infos>    additional_info;
    };

    void from_json(const nlohmann::json& j, t_z_sync_status& answer);

    struct z_tx_history_answer_success
    {
        std::string                   from_id; // optional?
        std::size_t                   skipped; 
        std::size_t                   limit;
        std::size_t                   current_block;
        std::size_t                   total_pages;
        std::size_t                   page_number;
        std::size_t                   total;
        std::vector<transaction_data> transactions;
        t_z_sync_status               sync_status;
    };

    void from_json(const nlohmann::json& j, z_tx_history_answer_success& answer);

    struct z_tx_history_answer
    {
        std::optional<std::string>                 error;
        std::optional<z_tx_history_answer_success> result;
        std::string                                raw_result;      ///< internal
        int                                        rpc_result_code; ///< internal
    };

    void from_json(const nlohmann::json& j, z_tx_history_answer& answer);
} // namespace atomic_dex::kdf

namespace atomic_dex
{
    using t_z_tx_history_request = kdf::z_tx_history_request;
    using t_z_tx_history_answer = kdf::z_tx_history_answer;
} // namespace atomic_dex
