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
#include "atomic.dex.update.service.hpp"
#include "atomic.dex.events.hpp"

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
        this->dispatcher_.trigger<refresh_update_status>();
    }

    const nlohmann::json
    update_system_service::get_update_status() const noexcept
    {
        return *m_update_status;
    }
} // namespace atomic_dex