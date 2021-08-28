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

//! Qt
#include <QFile>

//! Project Headers
#include "addressbook.cfg.hpp"
#include "atomicdex/utilities/global.utilities.hpp"
#include "atomicdex/utilities/qt.utilities.hpp"

namespace atomic_dex
{
    nlohmann::json load_addressbook_cfg(const std::string& wallet_name)
    {
        const fs::path source_folder{utils::get_atomic_dex_addressbook_folder()};
        const fs::path in_path      {source_folder / wallet_name};
        QFile          ifs;
        QString        content;
        nlohmann::json out;
        
        utils::create_if_doesnt_exist(source_folder);
        {
            ifs.setFileName(std_path_to_qstring(in_path));
            try
            {
                ifs.open(QIODevice::ReadOnly | QIODevice::Text);
                content = ifs.readAll();
                ifs.close();
                out = nlohmann::json::parse(content.toStdString());
                SPDLOG_INFO("Addressbook configuration file read.");
            }
            catch ([[maybe_unused]] nlohmann::json::parse_error& ex)
            {
                SPDLOG_WARN("Addressbook config file was invalid, use empty configuration: {}. Content was: {}", ex.what(), content.toStdString());
                out = nlohmann::json::array();
            }
            catch (std::exception& ex)
            {
                SPDLOG_ERROR(ex.what());
                out = nlohmann::json::array();
            }
            return out;
        }
    }
    
    void update_addressbook_cfg(const nlohmann::json& in, const std::string& wallet_name)
    {
        const fs::path      out_folder{utils::get_atomic_dex_addressbook_folder()};
        const fs::path      out_path  {out_folder / wallet_name};
        QFile output;

        utils::create_if_doesnt_exist(out_folder);
        {
            output.setFileName(std_path_to_qstring(out_path));
            try
            {
                output.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text);
                output.write(QString::fromStdString(in.dump()).toUtf8());
                SPDLOG_INFO("Addressbook data successfully wrote in persistent data !");
            }
            catch (std::exception& ex)
            {
                SPDLOG_ERROR(ex.what());
            }
        }
    }
}