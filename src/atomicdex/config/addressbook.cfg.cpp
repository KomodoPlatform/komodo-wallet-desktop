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
 
//! STD
#include <fstream> //> std::ifstream, std::ofstream.

//! Project Headers
#include "addressbook.cfg.hpp"
#include "atomicdex/utilities/global.utilities.hpp"

namespace atomic_dex
{
    nlohmann::json load_addressbook_cfg(const std::string& wallet_name)
    {
        nlohmann::json out;
        fs::path       source_folder{utils::get_atomic_dex_addressbook_folder()};
        fs::path       in_path      {source_folder / wallet_name};
        
        utils::create_if_doesnt_exist(source_folder);
        {
            std::ifstream input{in_path.string()};
            
            assert(input.is_open());
            input >> out;
            return out;
        }
    }
    
    void update_addressbook_cfg(const nlohmann::json& in, const std::string& wallet_name)
    {
        fs::path out_folder{utils::get_atomic_dex_data_folder()};
        fs::path out_path  {out_folder / wallet_name};
        
        utils::create_if_doesnt_exist(out_path);
        {
            std::ofstream output{out_path.string(), std::ios::trunc};
            
            assert(output.is_open());
            output << in;
        }
    }
}