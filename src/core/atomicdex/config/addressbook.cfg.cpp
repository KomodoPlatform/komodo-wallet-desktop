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
        const fs::path       source_folder{utils::get_atomic_dex_addressbook_folder()};
        const fs::path       in_path      {source_folder / wallet_name};
        QFile                input;
        input.setFileName(std_path_to_qstring(in_path));
        //std::fstream   input;
        nlohmann::json out;
        
        utils::create_if_doesnt_exist(source_folder);
        {
            input.open(QIODevice::ReadOnly | QIODevice::Append | QIODevice::Text);
            try
            {
                QString val = input.readAll();
                out = nlohmann::json::parse(val.toStdString());
            }
            catch ([[maybe_unused]] nlohmann::json::parse_error& ex)
            {
                //spdlog::warn("Addressbook config file was invalid, its content will be cleaned.");
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
        output.setFileName(std_path_to_qstring(out_path));

        utils::create_if_doesnt_exist(out_path);
        {
            output.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text);
            output.write(QString::fromStdString(in.dump()).toUtf8());
        }
    }
}