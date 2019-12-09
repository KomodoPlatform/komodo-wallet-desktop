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

#include "atomic.dex.provider.coinpaprika.hpp"

namespace atomic_dex {
    atomic_dex::coinpaprika_provider::coinpaprika_provider(entt::registry &registry) : system(registry) {
        disable();
        this->dispatcher_.sink<atomic_dex::mm2_started>().connect<&coinpaprika_provider::on_mm2_started>(*this);

    }

    void coinpaprika_provider::update() noexcept {

    }

    coinpaprika_provider::~coinpaprika_provider() noexcept {
        provider_thread_timer_.interrupt();
        provider_rates_thread_.join();
    }

    void coinpaprika_provider::on_mm2_started([[maybe_unused]] const atomic_dex::mm2_started &evt) noexcept {
        LOG_SCOPE_FUNCTION(INFO);
        provider_rates_thread_ = std::thread([this]() {
            loguru::set_thread_name("paprika thread");
            LOG_SCOPE_F(INFO, "paprika thread started");
            using namespace std::chrono_literals;
            do {
                DLOG_F(INFO, "refreshing rate conversion from coinpaprika");
            } while (not provider_thread_timer_.wait_for(30s));
        });
    }
}