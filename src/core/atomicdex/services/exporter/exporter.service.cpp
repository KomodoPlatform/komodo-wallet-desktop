/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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

//! Deps
#include <nlohmann/json.hpp>

//! Project
#include "atomicdex/api/mm2/mm2.hpp"
#include "atomicdex/services/exporter/exporter.service.hpp"
#include "atomicdex/services/mm2/mm2.service.hpp"

//! Constructor
namespace atomic_dex
{
    exporter_service::exporter_service(entt::registry& registry, ag::ecs::system_manager& system_manager, QObject* parent) :
        QObject(parent), system(registry), m_system_manager(system_manager)
    {
        //! Event driven system
        this->disable();
    }
} // namespace atomic_dex

//! Public override
namespace atomic_dex
{
    void
    exporter_service::update()
    {
    }
} // namespace atomic_dex

//! QML API
namespace atomic_dex
{
    void
    exporter_service::export_swaps_history_to_csv(const QString& path)
    {
        std::string str_path = path.toStdString();
        fs::path    csv_path = str_path;

        if (not csv_path.has_extension())
        {
            SPDLOG_WARN("csv path doesn't contains file extensions adding it");
            str_path += ".csv";
            csv_path = str_path;
            SPDLOG_INFO("new csv path is: {}", csv_path.string());
        }
        nlohmann::json            batch           = nlohmann::json::array();
        nlohmann::json            my_recent_swaps = ::mm2::api::template_request("my_recent_swaps");
        auto&                     mm2             = m_system_manager.get_system<mm2_service>();
        const auto                swaps_data      = mm2.get_orders_and_swaps();
        t_my_recent_swaps_request request{
            .limit          = swaps_data.total_finished_swaps,
            .page_number    = 1,
            .my_coin        = swaps_data.filtering_infos.my_coin,
            .other_coin     = swaps_data.filtering_infos.other_coin,
            .from_timestamp = swaps_data.filtering_infos.from_timestamp,
            .to_timestamp   = swaps_data.filtering_infos.to_timestamp};
        to_json(my_recent_swaps, request);
        batch.push_back(my_recent_swaps);

        auto answer_functor = [csv_path](web::http::http_response resp) {
            auto       answers     = ::mm2::api::basic_batch_answer(resp);
            const auto swap_answer = ::mm2::api::rpc_process_answer_batch<t_my_recent_swaps_answer>(answers[0], "my_recent_swaps");
            if (swap_answer.result.has_value())
            {
                const auto result = swap_answer.result.value();
                SPDLOG_INFO("exporting csv with path: {}", csv_path.string());
                std::ofstream ofs(csv_path.string(), std::ios::out | std::ios::trunc);
                ofs << "Date, BaseCoin, BaseAmount, Status, RelCoin, RelAmount, UUID, ErrorState" << std::endl;
                for (auto&& cur_swap: result.swaps)
                {
                    ofs << cur_swap.human_date.toStdString() << ",";
                    ofs << cur_swap.base_coin.toStdString() << ",";
                    ofs << cur_swap.base_amount.toStdString() << ",";
                    const auto status = cur_swap.order_status.toStdString();
                    ofs << status << ",";
                    ofs << cur_swap.rel_coin.toStdString() << ",";
                    ofs << cur_swap.rel_amount.toStdString() << ",";
                    ofs << cur_swap.order_id.toStdString();
                    if (status == "failed")
                    {
                        ofs << "," << cur_swap.order_error_state.toStdString() << std::endl;
                    }
                    else
                    {
                        ofs << ",Success" << std::endl;
                    }
                }
                ofs.close();
            }
            else
            {
                if (swap_answer.error.has_value())
                {
                    SPDLOG_ERROR("error during swap request: {}", swap_answer.error.value());
                }
            }
        };

        mm2.get_mm2_client().async_rpc_batch_standalone(batch).then(answer_functor).then(&handle_exception_pplx_task);
    }
} // namespace atomic_dex