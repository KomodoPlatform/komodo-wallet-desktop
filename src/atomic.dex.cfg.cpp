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

#include "atomic.dex.cfg.hpp"

namespace
{
    void
    upgrade_cfg(atomic_dex::cfg& config)
    {
        fs::path       cfg_path = ag::core::assets_real_path() / "config";
        std::ifstream  ifs((cfg_path / "cfg.json").c_str());
        nlohmann::json config_json_data;

        assert(ifs.is_open());
        ifs >> config_json_data;
        config_json_data["lang"] = config.current_lang;
        config_json_data["current_fiat"] = config.current_fiat;

        ifs.close();

        //! Write contents
        std::ofstream ofs((cfg_path / "cfg.json").c_str(), std::ios::trunc);
        assert(ofs.is_open());
        ofs << config_json_data;
    }
}

namespace atomic_dex
{
    void
    from_json(const nlohmann::json& j, atomic_dex::cfg& config)
    {
        j.at("lang").get_to(config.current_lang);
        j.at("available_lang").get_to(config.available_lang);
        j.at("current_fiat").get_to(config.current_fiat);
        j.at("available_fiat").get_to(config.available_fiat);
    }

    void
    change_lang(cfg& config, const std::string& new_lang)
    {
        config.current_lang = new_lang;
        upgrade_cfg(config);
    }

    cfg
    load_cfg()
    {
        cfg            out;
        fs::path       cfg_path = ag::core::assets_real_path() / "config";
        std::ifstream  ifs((cfg_path / "cfg.json").c_str());
        nlohmann::json config_json_data;

        assert(ifs.is_open());
        ifs >> config_json_data;

        from_json(config_json_data, out);
        return out;
    }

    void
    change_fiat(cfg& config, const std::string& new_fiat)
    {
        config.current_fiat = new_fiat;
        upgrade_cfg(config);
    }
} // namespace atomic_dex
