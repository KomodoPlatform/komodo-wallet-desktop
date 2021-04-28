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

#include <QJsonDocument>
#include <QSettings>

//! Project Headers
#include "atomicdex/api/mm2/rpc.buy.hpp"
#include "atomicdex/api/mm2/rpc.sell.hpp"
#include "atomicdex/api/mm2/rpc.trade.preimage.hpp"
#include "atomicdex/pages/qt.portfolio.page.hpp"
#include "atomicdex/pages/qt.settings.page.hpp"
#include "atomicdex/pages/qt.trading.page.hpp"
#include "atomicdex/services/mm2/auto.update.maker.order.service.hpp"
#include "atomicdex/services/mm2/mm2.service.hpp"
#include "atomicdex/services/price/global.provider.hpp"
#include "atomicdex/utilities/qt.utilities.hpp"

//! Consttructor / Destructor
namespace atomic_dex
{
    trading_page::trading_page(
        entt::registry& registry, ag::ecs::system_manager& system_manager, std::atomic_bool& exit_status, portfolio_model* portfolio, QObject* parent) :
        QObject(parent),
        system(registry), m_system_manager(system_manager),
        m_about_to_exit_the_app(exit_status), m_models{
                                                  {new qt_orderbook_wrapper(m_system_manager, dispatcher_, this),
                                                   new market_pairs(m_system_manager, portfolio, this), new qt_orders_widget(m_system_manager, this)}}
    {
        //!
    }
} // namespace atomic_dex

//! Events callback
namespace atomic_dex
{
    void
    trading_page::on_process_orderbook_finished_event(const atomic_dex::process_orderbook_finished& evt)
    {
        if (not m_about_to_exit_the_app)
        {
            m_actions_queue.push(trading_actions::post_process_orderbook_finished);
            m_models_actions[orderbook_need_a_reset] = evt.is_a_reset;
            determine_max_volume();
        }
    }
} // namespace atomic_dex

//! Public QML API
namespace atomic_dex
{
    QVariant
    trading_page::get_raw_mm2_coin_cfg(const QString& ticker) const
    {
        QVariant       out;
        nlohmann::json j = m_system_manager.get_system<mm2_service>().get_raw_mm2_ticker_cfg(ticker.toStdString());
        out              = nlohmann_json_object_to_qt_json_object(j);
        return out;
    }

    void
    trading_page::set_current_orderbook(const QString& base, const QString& rel)
    {
        bool is_wallet_only = m_system_manager.get_system<mm2_service>().get_coin_info(base.toStdString()).wallet_only;
        if (is_wallet_only)
        {
            SPDLOG_WARN("{} is wallet only - skipping", base.toStdString());
            return;
        }
        SPDLOG_INFO("Setting current orderbook: {} / {}", base.toStdString(), rel.toStdString());
        auto* market_selector_mdl = get_market_pairs_mdl();

        const bool to_change = base != market_selector_mdl->get_left_selected_coin() || rel != market_selector_mdl->get_right_selected_coin();
        market_selector_mdl->set_left_selected_coin(base);
        market_selector_mdl->set_right_selected_coin(rel);
        market_selector_mdl->set_base_selected_coin(m_market_mode == MarketMode::Sell ? base : rel);
        market_selector_mdl->set_rel_selected_coin(m_market_mode == MarketMode::Sell ? rel : base);

        if (to_change)
        {
            this->get_orderbook_wrapper()->clear_orderbook();
            this->clear_forms();
        }

        emit mm2MinTradeVolChanged();
        dispatcher_.trigger<orderbook_refresh>(base.toStdString(), rel.toStdString());
    }

    void
    trading_page::swap_market_pair()
    {
        auto* market_selector_mdl = get_market_pairs_mdl();
        set_current_orderbook(market_selector_mdl->get_right_selected_coin(), market_selector_mdl->get_left_selected_coin());
    }

    void
    trading_page::on_gui_enter_dex()
    {
        SPDLOG_INFO("Enter DEX");
        dispatcher_.trigger<gui_enter_trading>();
        if (this->m_system_manager.has_system<auto_update_maker_order_service>() && !m_system_manager.get_system<mm2_service>().is_orderbook_thread_active())
        {
            this->m_system_manager.get_system<auto_update_maker_order_service>().force_update();
        }
    }

    void
    trading_page::on_gui_leave_dex()
    {
        m_system_manager.get_system<settings_page>().garbage_collect_qml();
        dispatcher_.trigger<gui_leave_trading>();
    }

    void
    trading_page::place_buy_order(const QString& base_nota, const QString& base_confs)
    {
        this->set_buy_sell_rpc_busy(true);
        this->set_buy_sell_last_rpc_data(QJsonObject{{}});

        const auto* market_selector   = get_market_pairs_mdl();
        const auto& base              = market_selector->get_left_selected_coin();
        const auto& rel               = market_selector->get_right_selected_coin();
        const bool  is_selected_order = m_preffered_order.has_value();
        const bool  is_selected_max =
            is_selected_order ? QString::fromStdString(utils::format_float(safe_float(m_preffered_order->at("quantity").get<std::string>()))) == m_volume
                               : false;
        const bool is_my_max = m_volume == m_max_volume;
        const bool is_exact_selected_order_volume =
            (is_selected_order && m_preffered_order->at("coin").get<std::string>() == base.toStdString()) ? is_selected_max : false;
        t_float_50 rel_min_trade    = safe_float(get_orderbook_wrapper()->get_rel_min_taker_vol().toStdString());
        t_float_50 rel_min_volume_f = safe_float(get_min_trade_vol().toStdString());
        // SPDLOG_INFO("base_min_trade: {}", rel_min_trade.str(50, std::ios::fixed));
        // SPDLOG_INFO("rel_min_volume: {} (will be use for mm2)", rel_min_volume_f.str(50, std::ios::fixed));

        t_buy_request req{
            .base                           = base.toStdString(),
            .rel                            = rel.toStdString(),
            .price                          = is_selected_order ? m_preffered_order->at("price").get<std::string>() : m_price.toStdString(),
            .volume                         = m_volume.toStdString(),
            .is_created_order               = not is_selected_order,
            .price_denom                    = is_selected_order ? m_preffered_order->at("price_denom").get<std::string>() : "",
            .price_numer                    = is_selected_order ? m_preffered_order->at("price_numer").get<std::string>() : "",
            .volume_denom                   = is_selected_order ? m_preffered_order->at("quantity_denom").get<std::string>() : "",
            .volume_numer                   = is_selected_order ? m_preffered_order->at("quantity_numer").get<std::string>() : "",
            .is_exact_selected_order_volume = is_exact_selected_order_volume,
            .base_nota                      = base_nota.isEmpty() ? std::optional<bool>{std::nullopt} : boost::lexical_cast<bool>(base_nota.toStdString()),
            .base_confs                     = base_confs.isEmpty() ? std::optional<std::size_t>{std::nullopt} : base_confs.toUInt(),
            .min_volume = (rel_min_volume_f <= rel_min_trade) ? std::optional<std::string>{std::nullopt} : get_min_trade_vol().toStdString()};

        if (m_preffered_order.has_value())
        {
            if (req.is_exact_selected_order_volume)
            {
                //! Selected order and we keep the exact volume (Basically swallow the order)
                SPDLOG_INFO("swallowing the order from the orderbook");
                req.volume_numer = m_preffered_order->at("quantity_numer").get<std::string>();
                req.volume_denom = m_preffered_order->at("quantity_denom").get<std::string>();
            }
            else if (is_my_max && !req.is_exact_selected_order_volume)
            {
                SPDLOG_INFO("cannot swallow the selected order from the orderbook, use our theorical max_volume for it");
                //! Selected order but we cannot swallow (not enough funds) set our theorical max_volume_numer and max_volume_denom
                req.volume_numer = m_preffered_order->at("max_volume_numer").get<std::string>();
                req.volume_denom = m_preffered_order->at("max_volume_denom").get<std::string>();
            }
            else
            {
                SPDLOG_INFO("Selected order, but changing manually the volume, use input_volume");
                req.selected_order_use_input_volume = true;
            }
        }
        nlohmann::json batch;
        nlohmann::json buy_request = ::mm2::api::template_request("buy");
        ::mm2::api::to_json(buy_request, req);
        batch.push_back(buy_request);
        auto& mm2_system = m_system_manager.get_system<mm2_service>();

        //! Answer
        // SPDLOG_INFO("buy_request is : {}", batch.dump(4));
        auto answer_functor = [this](web::http::http_response resp)
        {
            std::string body = TO_STD_STR(resp.extract_string(true).get());
            if (resp.status_code() == 200)
            {
                if (body.find("error") == std::string::npos)
                {
                    auto           answers = nlohmann::json::parse(body);
                    nlohmann::json answer  = answers[0];
                    this->set_buy_sell_last_rpc_data(nlohmann_json_object_to_qt_json_object(answer));
                    auto& mm2_system = m_system_manager.get_system<mm2_service>();
                    SPDLOG_DEBUG("order successfully placed, refreshing orders and swap");
                    mm2_system.batch_fetch_orders_and_swap();
                }
                else
                {
                    auto error_json = QJsonObject({{"error_code", -1}, {"error_message", QString::fromStdString(body)}});
                    SPDLOG_ERROR("error place_buy_order: {}", body);
                    this->set_buy_sell_last_rpc_data(error_json);
                }
            }
            else
            {
                auto error_json = QJsonObject({{"error_code", resp.status_code()}, {"error_message", QString::fromStdString(body)}});
                this->set_buy_sell_last_rpc_data(error_json);
            }
            this->set_buy_sell_rpc_busy(false);
            this->clear_forms();
        };

        //! Async call
        mm2_system.get_mm2_client()
            .async_rpc_batch_standalone(batch)
            .then(answer_functor)
            .then(
                [this]([[maybe_unused]] pplx::task<void> previous_task)
                {
                    try
                    {
                        previous_task.wait();
                    }
                    catch (const std::exception& e)
                    {
                        SPDLOG_ERROR("pplx task error: {}", e.what());
                        auto error_json = QJsonObject({{"error_code", 500}, {"error_message", e.what()}});
                        this->set_buy_sell_last_rpc_data(error_json);
                        this->set_buy_sell_rpc_busy(false);
                        this->clear_forms();
                    }
                });
    }

    void
    trading_page::place_sell_order(const QString& rel_nota, const QString& rel_confs)
    {
        this->set_buy_sell_rpc_busy(true);
        this->set_buy_sell_last_rpc_data(QJsonObject{{}});

        const auto* market_selector   = get_market_pairs_mdl();
        const auto& base              = market_selector->get_left_selected_coin();
        const auto& rel               = market_selector->get_right_selected_coin();
        const bool  is_selected_order = m_preffered_order.has_value();
        const bool  is_max            = m_max_volume == m_volume;
        const bool  is_selected_max =
            is_selected_order ? QString::fromStdString(utils::format_float(safe_float(m_preffered_order->at("quantity").get<std::string>()))) == m_volume
                               : false;
        t_float_50 base_min_trade = safe_float(get_orderbook_wrapper()->get_base_min_taker_vol().toStdString());
        t_float_50 cur_min_trade  = safe_float(get_min_trade_vol().toStdString());
        t_float_50 delta          = (cur_min_trade * 100) / safe_float(m_max_volume.toStdString());
        t_float_50 delta_cur      = (cur_min_trade * 100) / safe_float(m_volume.toStdString());
        SPDLOG_INFO("delta min_vol compare to max volume is: {}", utils::format_float(delta));
        SPDLOG_INFO("delta min_vol compare to current volume is: {}", utils::format_float(delta_cur));

        t_sell_request req{
            .base             = base.toStdString(),
            .rel              = rel.toStdString(),
            .price            = is_selected_order ? m_preffered_order->at("price").get<std::string>() : m_price.toStdString(),
            .volume           = m_volume.toStdString(),
            .is_created_order = not is_selected_order,
            .price_denom      = is_selected_order ? m_preffered_order->at("price_denom").get<std::string>() : "",
            .price_numer      = is_selected_order ? m_preffered_order->at("price_numer").get<std::string>() : "",
            .volume_denom     = is_selected_order ? m_preffered_order->at("quantity_denom").get<std::string>() : "",
            .volume_numer     = is_selected_order ? m_preffered_order->at("quantity_numer").get<std::string>() : "",
            .is_exact_selected_order_volume =
                (is_selected_order && m_preffered_order->at("coin").get<std::string>() == base.toStdString()) ? is_selected_max : false,
            .rel_nota   = rel_nota.isEmpty() ? std::optional<bool>{std::nullopt} : boost::lexical_cast<bool>(rel_nota.toStdString()),
            .rel_confs  = rel_confs.isEmpty() ? std::optional<std::size_t>{std::nullopt} : rel_confs.toUInt(),
            .is_max     = is_max,
            .min_volume = cur_min_trade <= base_min_trade ? std::optional<std::string>{std::nullopt} : m_minimal_trading_amount.toStdString()};

        auto max_taker_vol_json_obj = get_orderbook_wrapper()->get_base_max_taker_vol().toJsonObject();
        if (m_preffered_order.has_value())
        {
            if (req.is_exact_selected_order_volume)
            {
                //! Selected order and we keep the exact volume (Basically swallow the order)
                SPDLOG_INFO("swallowing the order from the orderbook");
                req.volume_numer = m_preffered_order->at("quantity_numer").get<std::string>();
                req.volume_denom = m_preffered_order->at("quantity_denom").get<std::string>();
            }
            else if (is_max && !req.is_exact_selected_order_volume)
            {
                SPDLOG_INFO("cannot swallow the selected order from the orderbook, use max_taker_volume for it");
                //! Selected order but we cannot swallow (not enough funds) set our max_volume_numer and max_volume_denom
                req.volume_denom = max_taker_vol_json_obj["denom"].toString().toStdString();
                req.volume_numer = max_taker_vol_json_obj["numer"].toString().toStdString();
            }
            else
            {
                SPDLOG_INFO("Selected order, but changing manually the volume, use input_volume");
                req.selected_order_use_input_volume = true;
            }
        }
        else
        {
            if (is_max)
            {
                req.volume_denom = max_taker_vol_json_obj["denom"].toString().toStdString();
                req.volume_numer = max_taker_vol_json_obj["numer"].toString().toStdString();
            }
        }

        nlohmann::json batch;
        nlohmann::json sell_request = ::mm2::api::template_request("sell");
        ::mm2::api::to_json(sell_request, req);
        batch.push_back(sell_request);
        auto& mm2_system = m_system_manager.get_system<mm2_service>();

        // SPDLOG_INFO("batch sell request: {}", batch.dump(4));
        //! Answer
        auto answer_functor = [this](web::http::http_response resp)
        {
            std::string body = TO_STD_STR(resp.extract_string(true).get());
            if (resp.status_code() == 200)
            {
                if (body.find("error") == std::string::npos)
                {
                    auto           answers = nlohmann::json::parse(body);
                    nlohmann::json answer  = answers[0];
                    this->set_buy_sell_last_rpc_data(nlohmann_json_object_to_qt_json_object(answer));
                    auto& mm2_system = m_system_manager.get_system<mm2_service>();
                    SPDLOG_DEBUG("order successfully placed, refreshing orders and swap");
                    mm2_system.batch_fetch_orders_and_swap();
                }
                else
                {
                    auto error_json = QJsonObject({{"error_code", -1}, {"error_message", QString::fromStdString(body)}});
                    this->set_buy_sell_last_rpc_data(error_json);
                }
            }
            else
            {
                auto error_json = QJsonObject({{"error_code", resp.status_code()}, {"error_message", QString::fromStdString(body)}});
                this->set_buy_sell_last_rpc_data(error_json);
            }
            this->clear_forms();
            this->set_buy_sell_rpc_busy(false);
        };

        //! Async call
        mm2_system.get_mm2_client()
            .async_rpc_batch_standalone(batch)
            .then(answer_functor)
            .then(
                [this]([[maybe_unused]] pplx::task<void> previous_task)
                {
                    try
                    {
                        previous_task.wait();
                    }
                    catch (const std::exception& e)
                    {
                        SPDLOG_ERROR("pplx task error: {}", e.what());
                        auto error_json = QJsonObject({{"error_code", 500}, {"error_message", e.what()}});
                        this->set_buy_sell_last_rpc_data(error_json);
                        this->set_buy_sell_rpc_busy(false);
                        this->clear_forms();
                    }
                });
    }
} // namespace atomic_dex

//! Public API
namespace atomic_dex
{
    void
    trading_page::disable_coins(const QStringList& coins)
    {
        for (auto&& coin: coins)
        {
            auto* market_selector_mdl = get_market_pairs_mdl();
            if (market_selector_mdl->get_left_selected_coin() == coin)
            {
                market_selector_mdl->set_left_selected_coin(DEX_SECOND_PRIMARY_COIN);
                market_selector_mdl->set_right_selected_coin(DEX_PRIMARY_COIN);
            }
            else if (market_selector_mdl->get_right_selected_coin() == coin)
            {
                market_selector_mdl->set_left_selected_coin(DEX_SECOND_PRIMARY_COIN);
                market_selector_mdl->set_right_selected_coin(DEX_PRIMARY_COIN);
            }
            set_current_orderbook(market_selector_mdl->get_left_selected_coin(), market_selector_mdl->get_right_selected_coin());
        }
    }

    void
    trading_page::clear_models()
    {
        get_market_pairs_mdl()->reset();
    }

    void
    trading_page::update()
    {
    }

    void
    trading_page::connect_signals()
    {
        dispatcher_.sink<process_orderbook_finished>().connect<&trading_page::on_process_orderbook_finished_event>(*this);
    }

    void
    trading_page::disconnect_signals()
    {
        dispatcher_.sink<process_orderbook_finished>().disconnect<&trading_page::on_process_orderbook_finished_event>(*this);
    }

    void
    trading_page::process_action()
    {
        if (m_actions_queue.empty() || m_about_to_exit_the_app)
        {
            return;
        }
        const auto&     mm2_system = m_system_manager.get_system<mm2_service>();
        trading_actions last_action;
        this->m_actions_queue.pop(last_action);
        if (mm2_system.is_mm2_running())
        {
            switch (last_action)
            {
            case trading_actions::post_process_orderbook_finished:
            {
                std::error_code    ec;
                t_orderbook_answer result = mm2_system.get_orderbook(ec);
                if (!ec)
                {
                    auto* wrapper = get_orderbook_wrapper();
                    m_models_actions[orderbook_need_a_reset] ? wrapper->reset_orderbook(result) : wrapper->refresh_orderbook(result);

                    if (m_models_actions[orderbook_need_a_reset] && this->m_current_trading_mode == TradingModeGadget::Pro)
                    {
                        this->set_preffered_settings();
                    }
                    else
                    {
                        const auto base_max_taker_vol = safe_float(wrapper->get_base_max_taker_vol().toJsonObject()["decimal"].toString().toStdString());
                        const auto rel_max_taker_vol  = safe_float(wrapper->get_rel_max_taker_vol().toJsonObject()["decimal"].toString().toStdString());
                        t_float_50 min_vol            = safe_float(m_minimal_trading_amount.toStdString());
                        auto       adjust_functor     = [this, wrapper]()
                        {
                            if (m_post_clear_forms)
                            {
                                this->determine_max_volume();
                                this->set_volume(get_max_volume());
                                this->set_min_trade_vol(wrapper->get_current_min_taker_vol());
                                m_post_clear_forms = false;
                            }
                        };
                        if ((m_market_mode == MarketMode::Buy && rel_max_taker_vol > 0 && min_vol <= 0) ||
                            (m_market_mode == MarketMode::Sell && base_max_taker_vol > 0 && min_vol <= 0))
                        {
                            adjust_functor();
                        }
                    }

                    this->determine_error_cases();
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
    trading_page::get_orderbook_wrapper() const
    {
        return qobject_cast<qt_orderbook_wrapper*>(m_models[models::orderbook]);
    }

    qt_orders_widget*
    trading_page::get_orders_widget() const
    {
        return qobject_cast<qt_orders_widget*>(m_models[models::orders]);
    }

    market_pairs*
    trading_page::get_market_pairs_mdl() const
    {
        return qobject_cast<market_pairs*>(m_models[models::market_selector]);
    }

    bool
    trading_page::is_buy_sell_rpc_busy() const
    {
        return m_rpc_buy_sell_busy.load();
    }

    void
    trading_page::set_buy_sell_rpc_busy(bool status)
    {
        if (m_rpc_buy_sell_busy != status)
        {
            m_rpc_buy_sell_busy = status;
            emit buySellRpcStatusChanged();
        }
    }

    QVariant
    trading_page::get_buy_sell_last_rpc_data() const
    {
        return m_rpc_buy_sell_result.get();
    }

    void
    trading_page::set_buy_sell_last_rpc_data(QVariant rpc_data)
    {
        m_rpc_buy_sell_result = rpc_data.toJsonObject();
        emit buySellLastRpcDataChanged();
    }
} // namespace atomic_dex

//! Properties related to trading
namespace atomic_dex
{
    MarketMode
    trading_page::get_market_mode() const
    {
        return m_market_mode;
    }

    void
    trading_page::set_market_mode(MarketMode market_mode)
    {
        if (this->m_market_mode != market_mode)
        {
            this->m_market_mode = market_mode;
            SPDLOG_INFO("switching market_mode, new mode: {}", m_market_mode == MarketMode::Buy ? "buy" : "sell");
            this->clear_forms();
            auto* market_selector_mdl = get_market_pairs_mdl();
            set_current_orderbook(market_selector_mdl->get_left_selected_coin(), market_selector_mdl->get_right_selected_coin());
            emit marketModeChanged();
            if (m_market_mode == MarketMode::Buy)
            {
                this->get_orderbook_wrapper()->get_best_orders()->get_orderbook_proxy()->sort(0, Qt::AscendingOrder);
            }
            else
            {
                this->get_orderbook_wrapper()->get_best_orders()->get_orderbook_proxy()->sort(0, Qt::DescendingOrder);
            }
        }
    }

    QString
    trading_page::get_price() const
    {
        return m_price;
    }

    void
    trading_page::set_price(QString price)
    {
        if (price.isEmpty())
        {
            price = "0";
        }
        if (m_price != price)
        {
            m_price = std::move(price);
            if (this->m_preffered_order.has_value() && this->m_preffered_order->contains("locked"))
            {
                SPDLOG_WARN("releasing preffered order because price has been modified");
                this->m_preffered_order = std::nullopt;
                emit prefferedOrderChanged();
            }
            // SPDLOG_DEBUG("price is [{}]", m_price.toStdString());

            //! When price change in MarketMode::Buy you want to redetermine max_volume
            if (m_market_mode == MarketMode::Buy)
            {
                this->determine_max_volume();
            }
            if (this->m_current_trading_mode != TradingMode::Simple)
            {
                this->determine_total_amount();
            }

            if (this->m_preffered_order.has_value())
            {
                this->m_preffered_order.value()["locked"] = true;
            }
            this->determine_cex_rates();
            emit priceChanged();
            emit priceReversedChanged();
            emit get_orderbook_wrapper()->currentMinTakerVolChanged();
            get_orderbook_wrapper()->adjust_min_vol();
        }
    }

    void
    trading_page::clear_forms()
    {
        SPDLOG_INFO("clearing forms");
        // this->set_min_trade_vol("0");
        m_minimal_trading_amount = "0";
        emit minTradeVolChanged();
        this->set_price("0");
        this->set_volume("0");
        this->set_max_volume("0");
        this->set_total_amount("0");
        this->set_trading_error(TradingError::None);
        this->m_preffered_order  = std::nullopt;
        this->m_fees             = QVariantMap();
        this->m_cex_price        = "0";
        this->m_post_clear_forms = true;
        emit cexPriceChanged();
        emit invalidCexPriceChanged();
        emit cexPriceReversedChanged();
        emit feesChanged();
        emit prefferedOrderChanged();
    }

    QString
    trading_page::get_volume() const
    {
        return m_volume;
    }

    void
    trading_page::set_volume(QString volume)
    {
        if (m_volume != volume && not volume.isEmpty())
        {
            if (safe_float(volume.toStdString()) < 0)
            {
                volume = "0";
            }
            m_volume = std::move(volume);
            SPDLOG_INFO("volume is : [{}]", m_volume.toStdString());
            if (m_current_trading_mode != TradingMode::Simple)
            {
                this->determine_total_amount();
            }
            emit volumeChanged();
            this->cap_volume();
        }
    }

    QString
    trading_page::get_max_volume() const
    {
        return m_max_volume;
    }

    void
    trading_page::set_max_volume(QString max_volume)
    {
        if (m_max_volume != max_volume)
        {
            m_max_volume = std::move(max_volume);
            SPDLOG_DEBUG("max_volume is [{}]", m_max_volume.toStdString());
            emit maxVolumeChanged();
        }
    }

    void
    trading_page::determine_max_volume()
    {
        if (this->m_market_mode == MarketMode::Sell)
        {
            //! In MarketMode::Sell mode max volume is just the base_max_taker_vol
            const auto max_taker_vol = get_orderbook_wrapper()->get_base_max_taker_vol().toJsonObject()["decimal"].toString().toStdString();
            if (not max_taker_vol.empty())
            {
                // SPDLOG_INFO("max_taker_vol is valid, processing...");
                // SPDLOG_INFO("max_taker_vol is: [{}]", max_taker_vol);
                if (safe_float(max_taker_vol) <= 0)
                {
                    this->set_max_volume("0");
                }
                else
                {
                    const auto max_vol_str = utils::format_float(safe_float(max_taker_vol));

                    //! max_volume is max_taker_vol
                    this->set_max_volume(QString::fromStdString(max_vol_str));
                }

                //! Capping it
                this->cap_volume();
            }
            else
            {
                // SPDLOG_WARN("max_taker_vol cannot be empty, is it called before being determinated ?");
            }
        }
        else
        {
            //! In MarketMode::Buy mode the max volume is rel_max_taker_vol / price
            if (not m_price.isEmpty())
            {
                t_float_50 price_f = safe_float(m_price.toStdString());
                //! It's selected let's use rat price
                if (m_preffered_order.has_value())
                {
                    const auto& rel_max_taker_json_obj = get_orderbook_wrapper()->get_rel_max_taker_vol().toJsonObject();
                    const auto& denom                  = rel_max_taker_json_obj["denom"].toString().toStdString();
                    const auto& numer                  = rel_max_taker_json_obj["numer"].toString().toStdString();
                    t_float_50  res_f                  = safe_float(rel_max_taker_json_obj["decimal"].toString().toStdString());
                    if (res_f <= 0)
                    {
                        res_f = 0;
                    }
                    else
                    {
                        t_rational rel_max_taker_rat((boost::multiprecision::cpp_int(numer)), boost::multiprecision::cpp_int(denom));
                        if (price_f > t_float_50(0))
                        {
                            const auto price_denom = m_preffered_order->at("price_denom").get<std::string>();
                            const auto price_numer = m_preffered_order->at("price_numer").get<std::string>();
                            t_rational price_orderbook_rat((boost::multiprecision::cpp_int(price_numer)), (boost::multiprecision::cpp_int(price_denom)));

                            t_rational res = rel_max_taker_rat / price_orderbook_rat;
                            /*SPDLOG_INFO(
                                "rat should be: numerator {} denominator {}", boost::multiprecision::numerator(res).str(),
                                boost::multiprecision::denominator(res).str());*/
                            res_f                                               = res.convert_to<t_float_50>();
                            this->m_preffered_order.value()["max_volume_denom"] = boost::multiprecision::denominator(res).str();
                            this->m_preffered_order.value()["max_volume_numer"] = boost::multiprecision::numerator(res).str();
                        }
                    }
                    this->set_max_volume(QString::fromStdString(utils::format_float(res_f)));
                    this->cap_volume();
                }
                else
                {
                    t_float_50 max_vol = safe_float(get_orderbook_wrapper()->get_rel_max_taker_vol().toJsonObject()["decimal"].toString().toStdString());
                    max_vol            = std::max(t_float_50(0), max_vol);
                    t_float_50 res     = price_f > t_float_50(0) ? max_vol / price_f : t_float_50(0);
                    if (res < 0)
                    {
                        res = 0;
                    }
                    this->set_max_volume(QString::fromStdString(utils::format_float(res)));
                    this->cap_volume();
                }
            }
        }
    }

    void
    trading_page::cap_volume()
    {
        /*
         * cap_volume is called only in MarketMode::Buy, and in Sell mode if prefered order
         * if the current volume text field is > the new max_volume then set volume to max_volume
         */
        if (auto std_volume = this->get_volume().toStdString(); not std_volume.empty())
        {
            if (safe_float(std_volume) > safe_float(this->get_max_volume().toStdString()))
            {
                this->set_volume(this->get_max_volume());
            }
        }
    }

    TradingError
    trading_page::get_trading_error() const
    {
        return m_last_trading_error;
    }

    void
    trading_page::set_trading_error(TradingError trading_error)
    {
        if (m_last_trading_error != trading_error)
        {
            m_last_trading_error = trading_error;
            switch (m_last_trading_error)
            {
            case TradingErrorGadget::None:
                SPDLOG_INFO("last_trading_error is None");
                break;
            case TradingErrorGadget::TotalFeesNotEnoughFunds:
                SPDLOG_WARN("last_trading_error is TotalFeesNotEnoughFunds");
                break;
            case TradingErrorGadget::BalanceIsLessThanTheMinimalTradingAmount:
                SPDLOG_WARN("last_trading_error is BalanceIsLessThanTheMinimalTradingAmount");
                break;
            case TradingErrorGadget::PriceFieldNotFilled:
                SPDLOG_WARN("last_trading_error is PriceFieldNotFilled");
                break;
            case TradingErrorGadget::VolumeFieldNotFilled:
                SPDLOG_WARN("last_trading_error is VolumeFieldNotFilled");
                break;
            case TradingErrorGadget::VolumeIsLowerThanTheMinimum:
                SPDLOG_WARN("last_trading_error is VolumeIsLowerThanTheMinimum");
                break;
            case TradingErrorGadget::ReceiveVolumeIsLowerThanTheMinimum:
                SPDLOG_WARN("last_trading_error is ReceiveVolumeIsLowerThanTheMinimum");
                break;
            }
            emit tradingErrorChanged();
        }
    }

    TradingMode
    trading_page::get_current_trading_mode() const
    {
        return m_current_trading_mode;
    }

    void
    trading_page::set_current_trading_mode(TradingMode trading_mode)
    {
        if (m_current_trading_mode != trading_mode)
        {
            this->clear_forms();
            this->set_market_mode(MarketMode::Sell);
            m_current_trading_mode = trading_mode;
            SPDLOG_INFO("new trading mode: {}", QMetaEnum::fromType<TradingMode>().valueToKey(trading_mode));
            emit tradingModeChanged();
        }
    }

    bool
    trading_page::set_pair(bool is_left_side, QString changed_ticker)
    {
        SPDLOG_INFO("Changed ticker: {}", changed_ticker.toStdString());
        auto* const market_pair = get_market_pairs_mdl();
        auto        base        = market_pair->get_left_selected_coin();
        auto        rel         = market_pair->get_right_selected_coin();

        bool is_swap = false;
        if (not changed_ticker.isEmpty())
        {
            if (is_left_side)
            {
                if (base == changed_ticker)
                {
                    return false;
                }
                if (base != changed_ticker && rel == changed_ticker)
                {
                    is_swap = true;
                }
                else
                {
                    base = changed_ticker;
                }
            }
            else
            {
                if (rel == changed_ticker)
                {
                    return false;
                }
                if (rel != changed_ticker && base == changed_ticker)
                {
                    is_swap = true;
                }
                else
                {
                    rel = changed_ticker;
                }
            }
        }

        if (is_swap)
        {
            swap_market_pair();
            base = market_pair->get_left_selected_coin();
            rel  = market_pair->get_right_selected_coin();
        }
        else
        {
            if (base == rel || base.isEmpty() || rel.isEmpty())
            {
                set_current_orderbook(DEX_PRIMARY_COIN, DEX_SECOND_PRIMARY_COIN);
            }
            else
            {
                set_current_orderbook(base, rel);
            }
        }
        return true;
    }

    QVariantMap
    trading_page::get_preffered_order()
    {
        if (m_preffered_order.has_value())
        {
            return nlohmann_json_object_to_qt_json_object(m_preffered_order.value()).toVariantMap();
        }

        return QVariantMap();
    }

    void
    trading_page::set_preffered_order(QVariantMap price_object)
    {
        if (auto preffered_order = nlohmann::json::parse(QString(QJsonDocument(QJsonObject::fromVariantMap(price_object)).toJson()).toStdString());
            preffered_order != m_preffered_order)
        {
            m_preffered_order = std::move(preffered_order);
            emit prefferedOrderChanged();
            if (not m_preffered_order->empty() && m_preffered_order->contains("price"))
            {
                this->set_price(QString::fromStdString(utils::format_float(safe_float(m_preffered_order->at("price").get<std::string>()))));
                this->determine_max_volume();
                this->set_volume(QString::fromStdString(utils::format_float(safe_float(m_preffered_order->at("quantity").get<std::string>()))));
                this->get_orderbook_wrapper()->refresh_best_orders();
            }
        }
    }

    QString
    trading_page::get_total_amount() const
    {
        return m_total_amount;
    }

    void
    trading_page::set_total_amount(QString total_amount)
    {
        if (this->m_current_trading_mode != TradingMode::Simple)
        {
            if (m_total_amount != total_amount)
            {
                m_total_amount = std::move(total_amount);
                // SPDLOG_DEBUG("total_amount is [{}]", m_total_amount.toStdString());
                emit totalAmountChanged();
                emit baseAmountChanged();
                emit relAmountChanged();
            }
        }
        else
        {
            m_total_amount = total_amount;
            emit       totalAmountChanged();
            emit       baseAmountChanged();
            emit       relAmountChanged();
            t_float_50 price_f(0);
            t_float_50 total_amount_f(safe_float(total_amount.toStdString()));
            t_float_50 volume_f(safe_float(m_volume.toStdString()));
            if (volume_f > 0)
            {
                price_f = total_amount_f / volume_f;
            }
            this->set_price(QString::fromStdString(utils::format_float(price_f)));
        }
    }

    void
    trading_page::determine_total_amount()
    {
        if (not m_price.isEmpty() && not m_volume.isEmpty())
        {
            this->set_total_amount(calculate_total_amount(m_price, m_volume));
            // this->determine_fees();
            if (const std::string max_dust_str =
                    ((m_market_mode == MarketMode::Sell) ? get_orderbook_wrapper()->get_base_max_taker_vol() : get_orderbook_wrapper()->get_rel_max_taker_vol())
                        .toJsonObject()["decimal"]
                        .toString()
                        .toStdString();
                not max_dust_str.empty())
            {
                this->determine_error_cases();
            }
        }
    }

    QString
    trading_page::get_base_amount() const
    {
        return m_market_mode == MarketMode::Sell ? m_volume : m_total_amount;
    }

    QString
    trading_page::get_rel_amount() const
    {
        return m_market_mode == MarketMode::Sell ? m_total_amount : m_volume;
    }

    QVariantMap
    trading_page::get_fees() const
    {
        return m_fees.get();
    }

    void
    trading_page::set_fees(QVariantMap fees)
    {
        if (fees != m_fees)
        {
            m_fees = std::move(fees);
            // qDebug() << "fees are: [" << m_fees << "]";
            emit feesChanged();
        }
    }

    void
    trading_page::determine_fees()
    {
        using namespace std::string_literals;
        const auto* market_pair = get_market_pairs_mdl();
        auto&       mm2         = this->m_system_manager.get_system<mm2_service>();
        const auto  base        = market_pair->get_left_selected_coin().toStdString();
        const auto  rel         = market_pair->get_right_selected_coin().toStdString();
        // const bool  is_max      = m_market_mode == MarketMode::Sell && m_volume == m_max_volume;
        const auto swap_method = m_market_mode == MarketMode::Sell ? "sell"s : "buy"s;

        t_trade_preimage_request req{
            .base_coin = base, .rel_coin = rel, .swap_method = swap_method, .volume = get_volume().toStdString(), .price = get_price().toStdString()};

        nlohmann::json batch;
        nlohmann::json preimage_request = ::mm2::api::template_request("trade_preimage");
        ::mm2::api::to_json(preimage_request, req);
        // SPDLOG_INFO("request: {}", preimage_request.dump(4));
        batch.push_back(preimage_request);

        this->set_preimage_busy(true);
        auto answer_functor = [this, &mm2](web::http::http_response resp)
        {
            std::string body = TO_STD_STR(resp.extract_string(true).get());
            if (resp.status_code() == 200)
            {
                auto           answers = nlohmann::json::parse(body);
                nlohmann::json answer  = answers[0];
                // SPDLOG_INFO("preimage answer: {}", answer.dump(4));
                auto trade_preimage_answer = ::mm2::api::rpc_process_answer_batch<t_trade_preimage_answer>(answer, "trade_preimage");
                if (trade_preimage_answer.result.has_value())
                {
                    auto        success_answer = trade_preimage_answer.result.value();
                    QVariantMap fees;

                    const auto trading_fee_ticker = QString::fromStdString(success_answer.taker_fee.value().coin);

                    //! Trading fee are taker_fee
                    fees["trading_fee"]        = QString::fromStdString(utils::adjust_precision(success_answer.taker_fee.value().amount));
                    fees["trading_fee_ticker"] = trading_fee_ticker;

                    fees["base_transaction_fees"]        = QString::fromStdString(utils::adjust_precision(success_answer.base_coin_fee.amount));
                    fees["base_transaction_fees_ticker"] = QString::fromStdString(success_answer.base_coin_fee.coin);

                    fees["rel_transaction_fees"]        = QString::fromStdString(success_answer.rel_coin_fee.amount);
                    fees["rel_transaction_fees_ticker"] = QString::fromStdString(success_answer.rel_coin_fee.coin);

                    //! We are always in buy or sell mode, in this case show the fees
                    fees["fee_to_send_taker_fee"]        = QString::fromStdString(utils::adjust_precision(success_answer.fee_to_send_taker_fee.value().amount));
                    fees["fee_to_send_taker_fee_ticker"] = QString::fromStdString(success_answer.fee_to_send_taker_fee.value().coin);


                    for (auto&& cur: success_answer.total_fees)
                    {
                        if (!mm2.do_i_have_enough_funds(cur.at("coin").get<std::string>(), safe_float(cur.at("required_balance").get<std::string>())))
                        {
                            fees["error_fees"] = atomic_dex::nlohmann_json_object_to_qt_json_object(cur);
                            break;
                        }
                    }
                    fees["total_fees"] = atomic_dex::nlohmann_json_array_to_qt_json_array(success_answer.total_fees);

                    this->set_fees(fees);
                }
            }
            this->set_preimage_busy(false);
        };
        mm2.get_mm2_client().async_rpc_batch_standalone(batch).then(answer_functor).then(&handle_exception_pplx_task);
    }

    void
    trading_page::determine_error_cases()
    {
        TradingError current_trading_error = TradingError::None;

        //! Check minimal trading amount
        const std::string base                     = this->get_market_pairs_mdl()->get_base_selected_coin().toStdString();
        t_float_50        max_balance_without_dust = this->get_max_balance_without_dust();
        const auto&       rel_min_taker_vol        = get_orderbook_wrapper()->get_rel_min_taker_vol().toStdString();
        // const auto&       base_min_taker_vol        = get_orderbook_wrapper()->get_base_min_taker_vol().toStdString();
        const auto& cur_min_taker_vol = m_market_mode == MarketMode::Sell ? get_min_trade_vol().toStdString() : rel_min_taker_vol;

        if (max_balance_without_dust < safe_float(cur_min_taker_vol)) //<! Checking balance < minimal_trading_amount
        {
            current_trading_error = TradingError::BalanceIsLessThanTheMinimalTradingAmount;
        }
        else if (m_volume.isEmpty()) ///< Volume is not set correctly
        {
            current_trading_error = TradingError::VolumeFieldNotFilled;
        }
        else if (m_price.isEmpty() || m_price == "0") ///< Price is not set correctly
        {
            current_trading_error = TradingError::PriceFieldNotFilled; ///< need to have for multi ticker check
        }
        else if (safe_float(get_base_amount().toStdString()) < safe_float(cur_min_taker_vol))
        {
            // SPDLOG_INFO("base_amount: {}, cur_min_taker_vol: {}, price: {}", get_base_amount().toStdString(), cur_min_taker_vol, get_price().toStdString());
            current_trading_error = TradingError::VolumeIsLowerThanTheMinimum;
        }
        /*else if (safe_float(get_rel_amount().toStdString()) < safe_float(m_market_mode == Sell ? rel_min_taker_vol : base_min_taker_vol))
        {
            SPDLOG_INFO("rel_amount: {}, rel_min_taker_vol: {}, price: {}", get_rel_amount().toStdString(), rel_min_taker_vol, get_price().toStdString());
            current_trading_error = TradingError::ReceiveVolumeIsLowerThanTheMinimum; ///< need to have for multi ticker check
        }*/
        else
        {
            if (!get_fees().empty())
            {
                current_trading_error = generate_fees_error(get_fees());
            }
        }

        //! Check for base coin
        this->set_trading_error(current_trading_error);
    }

    void
    trading_page::determine_cex_rates()
    {
        const auto& price_service   = m_system_manager.get_system<global_price_service>();
        const auto* market_selector = get_market_pairs_mdl();
        const auto& base            = market_selector->get_left_selected_coin();
        const auto& rel             = market_selector->get_right_selected_coin();
        const auto  cex_price       = QString::fromStdString(price_service.get_cex_rates(base.toStdString(), rel.toStdString()));
        if (cex_price != m_cex_price)
        {
            m_cex_price = std::move(cex_price);
            emit cexPriceChanged();
            emit invalidCexPriceChanged();
            emit cexPriceReversedChanged();
        }
        emit cexPriceDiffChanged();
    }

    QString
    trading_page::get_cex_price() const
    {
        return m_cex_price;
    }

    bool
    trading_page::get_invalid_cex_price() const
    {
        return m_cex_price == "0" || m_cex_price == "0.00" || m_cex_price.isEmpty();
    }

    QString
    trading_page::get_price_reversed() const
    {
        if (not m_price.isEmpty() && safe_float(m_price.toStdString()) > 0)
        {
            t_float_50 reversed_price = t_float_50(1) / safe_float(m_price.toStdString());
            return QString::fromStdString(utils::format_float(reversed_price));
        }

        return "0";
    }

    QString
    trading_page::get_cex_price_reversed() const
    {
        if (not get_invalid_cex_price())
        {
            t_float_50 reversed_cex_price = t_float_50(1) / safe_float(m_cex_price.toStdString());
            return QString::fromStdString(utils::format_float(reversed_cex_price));
        }
        return "0";
    }

    QString
    trading_page::get_cex_price_diff() const
    {
        bool is_invalid = get_invalid_cex_price();
        if (is_invalid || safe_float(m_price.toStdString()) <= 0)
        {
            return "0";
        }
        const bool is_buy     = m_market_mode == MarketMode::Buy;
        t_float_50 price      = safe_float(m_price.toStdString());
        t_float_50 cex_price  = safe_float(m_cex_price.toStdString());
        t_float_50 price_diff = t_float_50(100) * (t_float_50(1) - price / cex_price) * (!is_buy ? t_float_50(1) : t_float_50(-1));
        return QString::fromStdString(utils::format_float(price_diff));
    }

    t_float_50
    trading_page::get_max_balance_without_dust(std::optional<QString> trade_with) const
    {
        if (!trade_with.has_value())
        {
            const std::string max_dust_str =
                ((m_market_mode == MarketMode::Sell) ? get_orderbook_wrapper()->get_base_max_taker_vol() : get_orderbook_wrapper()->get_rel_max_taker_vol())
                    .toJsonObject()["decimal"]
                    .toString()
                    .toStdString();
            assert(not max_dust_str.empty());
            t_float_50 max_balance_without_dust = safe_float(max_dust_str);
            return max_balance_without_dust;
        }

        return t_float_50(0);
    }

    TradingError
    trading_page::generate_fees_error(QVariantMap fees) const
    {
        TradingError last_trading_error = TradingError::None;
        const auto&  mm2                = m_system_manager.get_system<mm2_service>();

        if (fees.contains("error_fees"))
        {
            auto&& cur_obj = fees.value("error_fees").toJsonObject();
            if (!mm2.do_i_have_enough_funds(cur_obj["coin"].toString().toStdString(), safe_float(cur_obj["required_balance"].toString().toStdString())))
            {
                last_trading_error = TradingError::TotalFeesNotEnoughFunds;
            }
        }
        return last_trading_error;
    }

    bool
    trading_page::get_skip_taker() const
    {
        return m_skip_taker;
    }

    void
    trading_page::set_skip_taker(bool skip_taker)
    {
        if (m_skip_taker != skip_taker)
        {
            m_skip_taker = skip_taker;
            emit skipTakerChanged();
        }
    }

    QString
    trading_page::get_min_trade_vol() const
    {
        return m_minimal_trading_amount;
    }

    void
    trading_page::set_min_trade_vol(QString min_trade_vol)
    {
        //! KMD<->DOGE Buy -> base_min_vol, sell base_min_vol ->
        //! base_min_vol -> 0.0001 KMD
        //! rel_min_vol -> 10 DOGE
        const auto& min_taker_vol = get_orderbook_wrapper()->get_base_min_taker_vol().toStdString();
        t_float_50  min_vol_f     = safe_float(min_taker_vol);
        // const bool  is_valid      = safe_float(min_trade_vol.toStdString()) <= safe_float(get_volume().toStdString());

        if (safe_float(min_trade_vol.toStdString()) <= min_vol_f)
        {
            min_trade_vol = QString::fromStdString(min_taker_vol);
        }

        if (min_trade_vol != m_minimal_trading_amount)
        {
            SPDLOG_INFO("min_trade_vol: [{}]", min_trade_vol.toStdString());
            m_minimal_trading_amount = std::move(min_trade_vol);
            emit minTradeVolChanged();
            this->determine_error_cases();
        }
    }

    void
    trading_page::reset_order()
    {
        this->clear_forms();
    }

    bool
    trading_page::is_preimage_busy() const
    {
        return m_rpc_preimage_busy.load();
    }

    void
    trading_page::set_preimage_busy(bool status)
    {
        if (status != m_rpc_preimage_busy)
        {
            m_rpc_preimage_busy = status;
            emit preImageRpcStatusChanged();
        }
    }
    void
    trading_page::reset_fees()
    {
        this->set_fees(QVariantMap());
        this->determine_error_cases();
    }
} // namespace atomic_dex

namespace atomic_dex
{
    QString
    trading_page::calculate_total_amount(QString price, QString volume) const
    {
        t_float_50 price_f(safe_float(price.toStdString()));
        t_float_50 volume_f(safe_float(volume.toStdString()));
        t_float_50 total_amount_f = volume_f * price_f;
        return QString::fromStdString(atomic_dex::utils::format_float(total_amount_f));
    }

    void
    trading_page::set_preffered_settings()
    {
        QSettings&    settings            = entity_registry_.ctx<QSettings>();
        auto*         market_selector_mdl = get_market_pairs_mdl();
        const auto    left                = market_selector_mdl->get_left_selected_coin();
        const auto    right               = market_selector_mdl->get_right_selected_coin();
        const auto    category_settings   = left + "_" + right;
        const QString target_settings     = "Disabled";
        settings.beginGroup(category_settings);
        const bool is_disabled = settings.value(target_settings, true).toBool();
        t_float_50 spread      = settings.value("Spread", 1.0).toDouble();
        // const bool max                = settings.value("Max", false).toBool();
        t_float_50 min_volume_percent = settings.value("MinVolume", 10.0).toDouble() / 100; ///< min volume is always 10% of the order or more
        settings.endGroup();
        if (!is_disabled)
        {
            SPDLOG_WARN("{}/{} have trading settings - using them", left.toStdString(), right.toStdString());
            const auto& price_service = m_system_manager.get_system<global_price_service>();
            t_float_50  cex_price     = safe_float(price_service.get_cex_rates(left.toStdString(), right.toStdString()));
            t_float_50  percent       = spread / 100;
            t_float_50  target_price =
                (m_market_mode == MarketMode::Sell) ? t_float_50(cex_price + (cex_price * percent)) : t_float_50(cex_price - (cex_price * percent));

            this->set_price(QString::fromStdString(utils::format_float(target_price)));
            this->determine_max_volume();
            this->set_volume(get_max_volume());
            t_float_50 volume     = safe_float(get_volume().toStdString());
            t_float_50 min_volume = volume * min_volume_percent;
            this->set_min_trade_vol(QString::fromStdString(utils::format_float(min_volume)));
        }
        else
        {
            SPDLOG_WARN("{}/{} doesn't have any trading settings - skipping", left.toStdString(), right.toStdString());
        }
    }

    std::optional<nlohmann::json>
    trading_page::get_raw_preffered_order() const
    {
        return m_preffered_order;
    }
} // namespace atomic_dex
