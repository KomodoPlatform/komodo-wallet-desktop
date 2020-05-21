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
#include "atomic.dex.qt.current.coin.infos.hpp"
#include "atomic.dex.events.hpp"

namespace atomic_dex
{
    //! Constructor
    atomic_dex::current_coin_info::current_coin_info(entt::dispatcher& dispatcher, QObject* pParent) noexcept : QObject(pParent), m_dispatcher(dispatcher) {}

    //! Properties
    void
    atomic_dex::current_coin_info::set_name(QString name) noexcept
    {
        this->selected_coin_fname = std::move(name);
        emit name_changed();
    }

    QString
    atomic_dex::current_coin_info::get_name() const noexcept
    {
        return this->selected_coin_fname;
    }

    QString
    atomic_dex::current_coin_info::get_balance() const noexcept
    {
        return selected_coin_balance;
    }

    void
    atomic_dex::current_coin_info::set_balance(QString balance) noexcept
    {
        this->selected_coin_balance = std::move(balance);
        emit balance_changed();
    }

    QString
    atomic_dex::current_coin_info::get_ticker() const noexcept
    {
        return selected_coin_name;
    }

    void
    atomic_dex::current_coin_info::set_ticker(QString ticker) noexcept
    {
        selected_coin_name = std::move(ticker);
        this->m_dispatcher.trigger<change_ticker_event>();
        emit ticker_changed();
    }

    QString
    atomic_dex::current_coin_info::get_explorer_url() const noexcept
    {
        return selected_coin_url;
    }

    QString
    current_coin_info::get_fiat_amount() const noexcept
    {
        return this->selected_coin_fiat_amount;
    }

    void
    current_coin_info::set_claimable(bool claimable) noexcept
    {
        this->selected_coin_is_claimable = claimable;
        emit claimable_changed();
    }

    bool
    current_coin_info::is_claimable_ticker() const noexcept
    {
        return this->selected_coin_is_claimable;
    }


    void
    current_coin_info::set_fiat_amount(QString fiat_amount) noexcept
    {
        this->selected_coin_fiat_amount = std::move(fiat_amount);
        emit fiat_amount_changed();
    }
    QObjectList
    current_coin_info::get_transactions() const noexcept
    {
        return this->selected_coin_transactions;
    }

    void
    current_coin_info::set_transactions(QObjectList transactions) noexcept
    {
        this->selected_coin_transactions.clear();
        this->selected_coin_transactions = std::move(transactions);
        emit transactionsChanged();
    }
    QString
    current_coin_info::get_address() const noexcept
    {
        return selected_coin_address;
    }

    void
    current_coin_info::set_address(QString address) noexcept
    {
        this->selected_coin_address = std::move(address);
        emit address_changed();
    }

    void
    current_coin_info::set_explorer_url(QString url) noexcept
    {
        this->selected_coin_url = std::move(url);
        emit explorer_url_changed();
    }

    void
    current_coin_info::set_tx_state(QString state) noexcept
    {
        this->selected_coin_state = std::move(state);
        emit tx_state_changed();
    }

    QString
    current_coin_info::get_tx_state() const noexcept
    {
        return this->selected_coin_state;
    }

    unsigned int
    current_coin_info::get_tx_current_block() const noexcept
    {
        return this->selected_coin_block;
    }

    void
    current_coin_info::set_tx_current_block(unsigned int block) noexcept
    {
        this->selected_coin_block = std::move(block);
        emit tx_current_block_changed();
    }

    unsigned int
    atomic_dex::current_coin_info::get_txs_left() const noexcept
    {
        return this->selected_coin_txs_left;
    }

    void
    atomic_dex::current_coin_info::set_txs_left(unsigned int txs) noexcept
    {
        this->selected_coin_txs_left = txs;
        emit txs_left_changed();
    }

    unsigned int
    atomic_dex::current_coin_info::get_blocks_left() const noexcept
    {
        return this->selected_coin_blocks_left;
    }

    void
    atomic_dex::current_coin_info::set_blocks_left(unsigned int blocks) noexcept
    {
        this->selected_coin_blocks_left = blocks;
        emit blocks_left_changed();
    }

    QString
    current_coin_info::get_minimal_balance_for_asking_rewards() const noexcept
    {
        return this->selected_coin_minimal_balance_for_asking_rewards;
    }

    void
    current_coin_info::set_minimal_balance_for_asking_rewards(QString amount) noexcept
    {
        this->selected_coin_minimal_balance_for_asking_rewards = std::move(amount);
        emit minimal_balance_for_asking_rewards_changed();
    }

    QString
    atomic_dex::current_coin_info::get_type() const noexcept
    {
        return this->selected_coin_type;
    }

    void
    atomic_dex::current_coin_info::set_type(QString type) noexcept
    {
        this->selected_coin_type = std::move(type);
        emit type_changed();
    }

    QString
    atomic_dex::current_coin_info::get_paprika_id() const noexcept
    {
       return this->selected_coin_paprika_id;
    }

    void
    atomic_dex::current_coin_info::set_paprika_id(QString paprika_id) noexcept
    {
        this->selected_coin_paprika_id = std::move(paprika_id);
        emit coinpaprika_id_changed();
    }
} // namespace atomic_dex