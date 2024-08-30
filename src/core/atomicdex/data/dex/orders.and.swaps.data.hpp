#pragma once

//! Deps
#include "atomicdex/data/dex/qt.orders.data.hpp"

namespace atomic_dex
{
    struct filtering_infos
    {
        //! Filtering
        std::optional<std::string> my_coin;        ///< base_coin
        std::optional<std::string> other_coin;     ///< rel_coin
        std::optional<std::size_t> from_timestamp; ///< start date
        std::optional<std::size_t> to_timestamp;   ///< end date
    };

    using t_filtering_infos = filtering_infos;

    // todo: please change the logic of this and its usage in kdf service and other places.
    // not happy with the current implementation we can do better
    struct orders_and_swaps
    {
        //! Registries
        std::unordered_set<std::string> orders_registry; ///< UUID orders registry
        std::unordered_set<std::string> swaps_registry;  ///< UUID swaps registry

        //! Helpers to navigate into the vector
        std::size_t active_swaps{0}; ///< total_number of active swaps (ongoing/matching/refuding/matched)
        std::size_t nb_orders;       ///< current nb_orders

        ///! Metrics
        nlohmann::json average_events_time;     ///< Time registry for each events
        std::size_t    total_finished_swaps{0}; ///< total number of finished swaps


        //! Pagination
        std::size_t nb_pages{1};     ///< number of page
        std::size_t current_page{1}; ///< index of the current page
        std::size_t total_swaps{0};  ///< total number of available swaps
        std::size_t limit{50};       ///< nb_elements / page

        t_filtering_infos filtering_infos;

        /**
         * orders_and_swaps in the following order
         *
         * - 1st part from 0 to nb_orders -> orders
         * - 2nd part from nb_orders to active_swaps -> active_swaps
         * - 3rd part from (nb_orders + active_swaps) to the end -> finished swaps
         */
        std::vector<t_order_swaps_data> orders_and_swaps;
    };
} // namespace atomic_dex