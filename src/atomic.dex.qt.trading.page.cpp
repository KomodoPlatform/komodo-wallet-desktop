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

//! Project Headers
#include "atomic.dex.qt.trading.page.hpp"
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.cex.prices.hpp"

//! Consttructor / Destructor
namespace atomic_dex
{
    trading_page::trading_page(entt::registry& registry, ag::ecs::system_manager& system_manager, std::atomic_bool& exit_status, QObject* parent) :
        QObject(parent), system(registry), m_system_manager(system_manager),
        m_about_to_exit_the_app(exit_status), m_models{{new qt_orderbook_wrapper(m_system_manager, this), new candlestick_charts_model(m_system_manager, this)}}
    {
        //!
    }
} // namespace atomic_dex

//! Events callback
namespace atomic_dex
{
    void
    trading_page::on_process_orderbook_finished_event(const atomic_dex::process_orderbook_finished& evt) noexcept
    {
        if (not m_about_to_exit_the_app)
        {
            m_actions_queue.push(trading_actions::post_process_orderbook_finished);
            m_models_actions[orderbook_need_a_reset] = evt.is_a_reset;
        }
    }

    void
    trading_page::on_start_fetching_new_ohlc_data_event(const start_fetching_new_ohlc_data& evt)
    {
        get_candlestick_charts()->set_is_currently_fetching(evt.is_a_reset);
    }

    void
    atomic_dex::trading_page::on_refresh_ohlc_event(const atomic_dex::refresh_ohlc_needed& evt) noexcept
    {
        if (not m_about_to_exit_the_app)
        {
            m_actions_queue.push(trading_actions::refresh_ohlc);
            m_models_actions[candlestick_need_a_reset] = evt.is_a_reset;
        }
    }
} // namespace atomic_dex

//! Public QML API
namespace atomic_dex
{
    void
    atomic_dex::trading_page::set_current_orderbook(const QString& base, const QString& rel)
    {
        auto& provider        = m_system_manager.get_system<cex_prices_provider>();
        auto [normal, quoted] = provider.is_pair_supported(base.toStdString(), rel.toStdString());
        get_candlestick_charts()->set_is_pair_supported(normal || quoted);
        dispatcher_.trigger<orderbook_refresh>(base.toStdString(), rel.toStdString());
    }
} // namespace atomic_dex

//! Public API
namespace atomic_dex
{
    void
    trading_page::update() noexcept
    {
    }

    void
    trading_page::connect_signals()
    {
        dispatcher_.sink<process_orderbook_finished>().connect<&trading_page::on_process_orderbook_finished_event>(*this);
        dispatcher_.sink<start_fetching_new_ohlc_data>().connect<&trading_page::on_start_fetching_new_ohlc_data_event>(*this);
        dispatcher_.sink<refresh_ohlc_needed>().connect<&trading_page::on_refresh_ohlc_event>(*this);
    }

    void
    atomic_dex::trading_page::disconnect_signals()
    {
        dispatcher_.sink<process_orderbook_finished>().disconnect<&trading_page::on_process_orderbook_finished_event>(*this);
        dispatcher_.sink<start_fetching_new_ohlc_data>().disconnect<&trading_page::on_start_fetching_new_ohlc_data_event>(*this);
        dispatcher_.sink<refresh_ohlc_needed>().disconnect<&trading_page::on_refresh_ohlc_event>(*this);
    }

    void
    trading_page::process_action()
    {
        if (m_actions_queue.empty() || m_about_to_exit_the_app)
        {
            return;
        }
        const auto&     mm2_system = m_system_manager.get_system<mm2>();
        trading_actions last_action;
        this->m_actions_queue.pop(last_action);
        if (mm2_system.is_mm2_running())
        {
            switch (last_action)
            {
            case trading_actions::refresh_ohlc:
                m_models_actions[candlestick_need_a_reset] ? get_candlestick_charts()->init_data() : get_candlestick_charts()->update_data();
                break;
            case trading_actions::post_process_orderbook_finished:
            {
                std::error_code    ec;
                t_orderbook_answer result = mm2_system.get_orderbook(ec);
                if (!ec)
                {
                    auto* wrapper = get_orderbook_wrapper();
                    m_models_actions[orderbook_need_a_reset] ? wrapper->reset_orderbook(result) : wrapper->refresh_orderbook(result);
                }
                break;
            }
            default:
                break;
            }
        }
    }
} // namespace atomic_dex

//! Properties
namespace atomic_dex
{
    qt_orderbook_wrapper*
    trading_page::get_orderbook_wrapper() const noexcept
    {
        return qobject_cast<qt_orderbook_wrapper*>(m_models[models::orderbook]);
    }

    candlestick_charts_model*
    trading_page::get_candlestick_charts() const noexcept
    {
        return qobject_cast<candlestick_charts_model*>(m_models[models::ohlc]);
    }
} // namespace atomic_dex