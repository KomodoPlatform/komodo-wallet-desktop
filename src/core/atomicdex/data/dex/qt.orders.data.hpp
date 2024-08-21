#pragma once

#include <QJsonArray>
#include <QString>

//! STD
#include <optional>

//! deps
#include <nlohmann/json.hpp>

namespace atomic_dex::kdf
{
    struct order_swaps_data
    {
        //! eg: true / false
        bool is_maker;

        //! eg: RICK
        QString base_coin;

        //! eg: MORTY
        QString rel_coin;

        //! eg: RICK/MORTY
        QString ticker_pair;

        //! eg: 1
        QString base_amount;

        //! eg: 1 in fiat currency.
        QString base_amount_fiat;

        //! eg: 1
        QString rel_amount;

        //! eg: 1 in fiat currency.
        QString rel_amount_fiat;

        //! eg: taker/maker order;
        QString order_type;

        //! eg: 2020-07-2020 17:23:36.625
        QString human_date;

        //! eg: 1595406178
        unsigned long long unix_timestamp;

        unsigned long long paymentLock;
        
        //! eg: b741646a-5738-4012-b5b0-dcd1375affd1
        QString order_id;

        //! eg: Successful / On Going / Matched / Matching
        QString order_status;

        QString maker_payment_id;

        QString taker_payment_id;

        //! eg: true / false
        bool is_swap;

        //! eg: true / false
        bool is_cancellable;

        //! eg: true / false
        bool is_recoverable;

        //! Order error state
        QString order_error_state;

        //! Order error message
        QString order_error_message;

        //! Events
        QJsonArray events;

        //! error events
        QStringList error_events;

        //! success events
        QStringList success_events;

        bool is_swap_active{false};

        //! Only available for maker order
        QString        min_volume;
        QString        max_volume;
        std::optional<nlohmann::json> conf_settings{std::nullopt};
    };
} // namespace atomic_dex::kdf

namespace atomic_dex
{
    using t_order_swaps_data = kdf::order_swaps_data;
}