#pragma once

#include <QString>

namespace atomic_dex
{
    struct order_data
    {
        //! eg: true / false
        bool is_maker;

        //! eg: RICK
        QString base_coin;

        //! eg: MORTY
        QString rel_coin;

        //! eg: 1
        QString base_amount;

        //! eg: 1
        QString rel_amount;

        //! eg: Taker order;
        QString order_type;

        //! eg: 2020-07-2020 17:23:36.625
        QString human_date;

        //! eg: 1595406178
        int unix_timestamp;

        //! eg: b741646a-5738-4012-b5b0-dcd1375affd1
        QString order_id;

        //! eg: Successful / On Going / Matched / Matching
        QString order_status;

        QString maker_payment_spent_id;

        QString taker_payment_sent_id;

        //! eg: true / false
        bool is_swap;

        //! eg: true / false
        bool is_cancellable;

        //! eg: true / false
        bool is_recoverable;
    };
} // namespace atomic_dex