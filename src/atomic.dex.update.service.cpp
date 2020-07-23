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

//! Project headers
#include "atomic.dex.pch.hpp"
#include "atomic.dex.update.service.hpp"
#include "atomic.dex.events.hpp"
#include "atomic.dex.version.hpp"
#include "atomic.threadpool.hpp"

namespace
{
    constexpr const char* g_komodolive_endpoint = "https://komodo.live/adexproversion";

    nlohmann::json
    get_update_status_rpc(const char* version)
    {
        using namespace std::string_literals;
        nlohmann::json resp;

        nlohmann::json req{{"currentVersion", version}};
        auto           answer = RestClient::post(g_komodolive_endpoint, "application/json", req.dump());
        if (answer.code != 200)
        {
            resp["status"] = "cannot reach the endpoint: "s + g_komodolive_endpoint;
        }
        else
        {
            resp = nlohmann::json::parse(answer.body);
        }
        resp["rpc_code"]        = answer.code;
        resp["current_version"] = version;
        if (answer.code == 200) {
            bool update_needed = false;
            std::string current_version_str = version;
            std::string endpoint_version = resp.at("new_version").get<std::string>();
            boost::algorithm::replace_all(current_version_str, ".", "");
            boost::algorithm::replace_all(endpoint_version, ".", "");
            boost::algorithm::trim_left_if(current_version_str, boost::is_any_of("0"));
            boost::algorithm::trim_left_if(endpoint_version, boost::is_any_of("0"));
            update_needed = std::stoi(current_version_str) < std::stoi(endpoint_version);
            resp["update_needed"] = update_needed;
        }
        return resp;
    }
} // namespace
namespace atomic_dex
{
    //! Constructor
    update_system_service::update_system_service(entt::registry& registry) : system(registry)
    {
        m_update_clock        = std::chrono::high_resolution_clock::now();
        this->m_update_status = nlohmann::json::object();
        this->fetch_update_status();
    }

    //! Public override
    void
    update_system_service::update() noexcept
    {
        using namespace std::chrono_literals;

        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - m_update_clock);
        if (s >= 1h)
        {
            this->fetch_update_status();
            m_update_clock = std::chrono::high_resolution_clock::now();
        }
    }

    //! Private api
    void
    update_system_service::fetch_update_status() noexcept
    {
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        spdlog::info("fetching update status");
        spawn([this]() {
            this->m_update_status = get_update_status_rpc(atomic_dex::get_raw_version());
            //spdlog::trace("-> {}", this->m_update_status->dump(4));
            this->dispatcher_.trigger<refresh_update_status>();
        });
    }

    const nlohmann::json
    update_system_service::get_update_status() const noexcept
    {
        return *m_update_status;
    }
} // namespace atomic_dex