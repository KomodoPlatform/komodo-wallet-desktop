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

//! Std
#include <sstream>

//! Qt
#include <QFile>

//! Deps
#include <nlohmann/json.hpp>

//! Project
#include "atomicdex/api/kdf/kdf.hpp"
#include "atomicdex/services/exporter/exporter.service.hpp"
#include "atomicdex/services/kdf/kdf.service.hpp"
#include "atomicdex/utilities/qt.utilities.hpp"

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
        std::filesystem::path    csv_path = str_path;

        if (not csv_path.has_extension())
        {
            SPDLOG_WARN("csv path doesn't contains file extensions adding it");
            str_path += ".csv";
            csv_path = str_path;
            LOG_PATH("new csv path is: {}", csv_path);
        }
        nlohmann::json            batch           = nlohmann::json::array();
        nlohmann::json            my_recent_swaps = kdf::template_request("my_recent_swaps");
        auto&                     kdf             = m_system_manager.get_system<kdf_service>();
        const auto                swaps_data      = kdf.get_orders_and_swaps();
        t_my_recent_swaps_request request{
            .limit          = swaps_data.total_finished_swaps,
            .page_number    = 1,
            .my_coin        = swaps_data.filtering_infos.my_coin,
            .other_coin     = swaps_data.filtering_infos.other_coin,
            .from_timestamp = swaps_data.filtering_infos.from_timestamp,
            .to_timestamp   = swaps_data.filtering_infos.to_timestamp};
        to_json(my_recent_swaps, request);
        batch.push_back(my_recent_swaps);
        // SPDLOG_INFO("my_recent_swaps req: {}", my_recent_swaps.dump(4));

        auto answer_functor = [csv_path](web::http::http_response resp) {
            auto       answers     = kdf::basic_batch_answer(resp);
            const auto swap_answer = kdf::rpc_process_answer_batch<t_my_recent_swaps_answer>(answers[0], "my_recent_swaps");
            if (swap_answer.result.has_value())
            {
                const auto result = swap_answer.result.value();
                LOG_PATH("exporting csv with path: {}", csv_path);
                QFile ofs;
                ofs.setFileName(std_path_to_qstring(csv_path));
                ofs.open(QIODevice::Text | QIODevice::WriteOnly | QIODevice::Truncate);
                std::stringstream ss;
                ss << "Date,BaseCoin,BaseAmount,Status,RelCoin,RelAmount,UUID,ErrorState" << std::endl;
                for (auto&& cur_swap: result.swaps)
                {
                    ss << cur_swap.human_date.toStdString() << ",";
                    ss << cur_swap.base_coin.toStdString() << ",";
                    ss << cur_swap.base_amount.toStdString() << ",";
                    const auto status = cur_swap.order_status.toStdString();
                    ss << status << ",";
                    ss << cur_swap.rel_coin.toStdString() << ",";
                    ss << cur_swap.rel_amount.toStdString() << ",";
                    ss << cur_swap.order_id.toStdString();
                    if (status == "failed")
                    {
                        ss << "," << cur_swap.order_error_state.toStdString() << std::endl;
                    }
                    else
                    {
                        ss << ",Success" << std::endl;
                    }
                }
                ofs.write(QString::fromStdString(ss.str()).toUtf8());
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

        kdf.get_kdf_client().async_rpc_batch_standalone(batch).then(answer_functor).then(&handle_exception_pplx_task);
    }
} // namespace atomic_dex