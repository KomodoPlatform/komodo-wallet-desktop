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

//! Deps
#include <nlohmann/json_fwd.hpp>
#include <boost/thread/synchronized_value.hpp>

namespace atomic_dex
{
    struct addressbook_contact_wallet_info
    {
        std::string                                  type;      /// \brief The type of wallet (e.g. BTC, erc-20, LTC...).
        std::unordered_map<std::string, std::string> addresses; /// \brief Every address associated to a name (e.g. "Binance wallet":"address_value").
    };

    void to_json(nlohmann::json& j, const addressbook_contact_wallet_info& cfg);

    struct addressbook_contact
    {
        std::string                                  name;         /// \brief The name of the contact.
        std::vector<addressbook_contact_wallet_info> wallets_info; /// \brief Contains information about contact's wallets.
        std::vector<std::string>                     categories;   /// \brief Categories of the contact.
    };

    void to_json(nlohmann::json& j, const addressbook_contact& cfg);

    struct transactions_contents
    {
        std::string note;
        std::string category;
    };

    void to_json(nlohmann::json& j, const transactions_contents& cfg);
    void from_json(const nlohmann::json& j, transactions_contents& cfg);

    struct wallet_cfg
    {
        using t_synchronized_transactions_details = boost::synchronized_value<std::unordered_map<std::string, transactions_contents>>;
        std::string                         name{};
        std::string                         protection_pass{"default_protection_pass"};
        std::vector<addressbook_contact>    addressbook_contacts;
        t_synchronized_transactions_details transactions_details;
    };

    void from_json(const nlohmann::json& j, wallet_cfg& cfg);
    void to_json(nlohmann::json& j, const wallet_cfg& cfg);
} // namespace atomic_dex
