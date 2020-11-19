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

#include <QJsonDocument>

//! PCH
#include "src/atomicdex/pch.hpp"

//! Project Headers
#include "atomicdex/services/mm2/mm2.service.hpp"
#include "atomicdex/services/ohlc/ohlc.provider.hpp"
#include "qt.trading.page.hpp"
#include "src/atomicdex/utilities/qt.utilities.hpp"

//! Consttructor / Destructor
namespace atomic_dex
{
    trading_page::trading_page(
        entt::registry& registry, ag::ecs::system_manager& system_manager, std::atomic_bool& exit_status, portfolio_model* portfolio, QObject* parent) :
        QObject(parent),
        system(registry), m_system_manager(system_manager),
        m_about_to_exit_the_app(exit_status), m_models{{new qt_orderbook_wrapper(m_system_manager, this), new market_pairs(portfolio, this)}}
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
        spdlog::debug("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
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
    trading_page::get_raw_mm2_coin_cfg(const QString& ticker) const noexcept
    {
        QVariant       out;
        nlohmann::json j = m_system_manager.get_system<mm2_service>().get_raw_mm2_ticker_cfg(ticker.toStdString());
        out              = nlohmann_json_object_to_qt_json_object(j);
        return out;
    }

    void
    trading_page::set_current_orderbook(const QString& base, const QString& rel)
    {
        auto* market_selector_mdl = get_market_pairs_mdl();

        if (base != market_selector_mdl->get_left_selected_coin() || rel != market_selector_mdl->get_right_selected_coin())
        {
            this->clear_forms();
        }
        market_selector_mdl->set_left_selected_coin(base);
        market_selector_mdl->set_right_selected_coin(rel);

        market_selector_mdl->set_base_selected_coin(m_market_mode == MarketMode::Sell ? base : rel);
        market_selector_mdl->set_rel_selected_coin(m_market_mode == MarketMode::Sell ? rel : base);
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
        dispatcher_.trigger<gui_enter_trading>();
    }

    void
    trading_page::on_gui_leave_dex()
    {
        dispatcher_.trigger<gui_leave_trading>();
    }

    void
    trading_page::cancel_order(const QStringList& orders_id)
    {
        nlohmann::json batch = nlohmann::json::array();
        for (auto&& order_id: orders_id)
        {
            ::mm2::api::cancel_all_orders_request req;
            nlohmann::json                        cancel_request = ::mm2::api::template_request("cancel_order");
            ::mm2::api::cancel_order_request      cancel_req{order_id.toStdString()};
            to_json(cancel_request, cancel_req);
            batch.push_back(cancel_request);
        }
        nlohmann::json my_orders_request = ::mm2::api::template_request("my_orders");
        batch.push_back(my_orders_request);
        auto& mm2_system = m_system_manager.get_system<mm2_service>();
        ::mm2::api::async_rpc_batch_standalone(batch, mm2_system.get_mm2_client(), pplx::cancellation_token::none())
            .then([this](web::http::http_response resp) {
                auto& mm2_system       = m_system_manager.get_system<mm2_service>();
                auto  answers          = ::mm2::api::basic_batch_answer(resp);
                auto  my_orders_answer = ::mm2::api::rpc_process_answer_batch<t_my_orders_answer>(answers[answers.size() - 1], "my_orders");
                mm2_system.add_orders_answer(my_orders_answer);
                // spdlog::trace("refreshing orderbook after cancelling order: {}", answers.dump(4));
                mm2_system.process_orderbook(false);
            })
            .then(&handle_exception_pplx_task);
    }

    void
    trading_page::common_cancel_all_orders(bool by_coin, const QString& ticker)
    {
        nlohmann::json batch          = nlohmann::json::array();
        nlohmann::json cancel_request = ::mm2::api::template_request("cancel_all_orders");
        if (by_coin && not ticker.isEmpty())
        {
            ::mm2::api::cancel_data cd;
            cd.ticker = ticker.toStdString();
            ::mm2::api::cancel_all_orders_request req{{"Coin", cd}};
            ::mm2::api::to_json(cancel_request, req);
        }
        else
        {
            ::mm2::api::cancel_data cd;
            cd.ticker = ticker.toStdString();
            ::mm2::api::cancel_all_orders_request req_all;
            ::mm2::api::to_json(cancel_request, req_all);
        }

        batch.push_back(cancel_request);
        nlohmann::json my_orders_request = ::mm2::api::template_request("my_orders");
        batch.push_back(my_orders_request);
        auto& mm2_system = m_system_manager.get_system<mm2_service>();
        ::mm2::api::async_rpc_batch_standalone(batch, mm2_system.get_mm2_client(), pplx::cancellation_token::none())
            .then([this](web::http::http_response resp) {
                auto& mm2_system       = m_system_manager.get_system<mm2_service>();
                auto  answers          = ::mm2::api::basic_batch_answer(resp);
                auto  my_orders_answer = ::mm2::api::rpc_process_answer_batch<t_my_orders_answer>(answers[1], "my_orders");
                mm2_system.add_orders_answer(my_orders_answer);
            })
            .then(&handle_exception_pplx_task);
    }

    void
    trading_page::cancel_all_orders()
    {
        common_cancel_all_orders();
    }

    void
    trading_page::cancel_all_orders_by_ticker(const QString& ticker)
    {
        common_cancel_all_orders(true, ticker);
    }

    void
    trading_page::fetch_additional_fees(const QString& ticker) noexcept
    {
        //! Async start
        this->set_fetching_multi_ticker_fees_busy(true);

        //! Batch preparation
        nlohmann::json          batch = nlohmann::json::array();
        t_get_trade_fee_request req_base{.coin = ticker.toStdString()};
        nlohmann::json          current_request = ::mm2::api::template_request("get_trade_fee");
        ::mm2::api::to_json(current_request, req_base);
        batch.push_back(current_request);

        //! System
        auto& mm2_system = m_system_manager.get_system<mm2_service>();

        auto answer_functor = [this, ticker_std = ticker.toStdString()](web::http::http_response resp) {
            std::string body = TO_STD_STR(resp.extract_string(true).get());
            if (resp.status_code() == 200)
            {
                auto           answers               = nlohmann::json::parse(body);
                nlohmann::json answer                = answers[0];
                auto&          mm2_system            = this->m_system_manager.get_system<mm2_service>();
                auto           trade_fee_base_answer = ::mm2::api::rpc_process_answer_batch<t_get_trade_fee_answer>(answer, "get_trade_fee");
                mm2_system.add_get_trade_fee_answer(ticker_std, trade_fee_base_answer);
            }
            this->set_fetching_multi_ticker_fees_busy(false);
        };

        ::mm2::api::async_rpc_batch_standalone(batch, mm2_system.get_mm2_client(), mm2_system.get_cancellation_token())
            .then(answer_functor)
            .then(&handle_exception_pplx_task);
    }

    void
    trading_page::place_buy_order(
        const QString& base, const QString& rel, const QString& price, const QString& volume, bool is_created_order, const QString& price_denom,
        const QString& price_numer, const QString& base_nota, const QString& base_confs)
    {
        this->set_buy_sell_rpc_busy(true);
        this->set_buy_sell_last_rpc_data(QJsonObject{{}});
        t_float_50 price_f;
        t_float_50 amount_f;
        t_float_50 total_amount;

        price_f.assign(price.toStdString());
        amount_f.assign(volume.toStdString());
        total_amount = price_f * amount_f;

        t_buy_request req{
            .base             = base.toStdString(),
            .rel              = rel.toStdString(),
            .price            = price.toStdString(),
            .volume           = volume.toStdString(),
            .is_created_order = is_created_order,
            .price_denom      = price_denom.toStdString(),
            .price_numer      = price_numer.toStdString(),
            .base_nota        = base_nota.isEmpty() ? std::optional<bool>{std::nullopt} : boost::lexical_cast<bool>(base_nota.toStdString()),
            .base_confs       = base_confs.isEmpty() ? std::optional<std::size_t>{std::nullopt} : base_confs.toUInt()};
        nlohmann::json batch;
        nlohmann::json buy_request = ::mm2::api::template_request("buy");
        ::mm2::api::to_json(buy_request, req);
        batch.push_back(buy_request);
        auto& mm2_system = m_system_manager.get_system<mm2_service>();

        //! Answer
        auto answer_functor = [this](web::http::http_response resp) {
            std::string body = TO_STD_STR(resp.extract_string(true).get());
            if (resp.status_code() == 200)
            {
                if (body.find("error") == std::string::npos)
                {
                    auto           answers = nlohmann::json::parse(body);
                    nlohmann::json answer  = answers[0];
                    this->set_buy_sell_last_rpc_data(nlohmann_json_object_to_qt_json_object(answer));
                    auto& mm2_system = m_system_manager.get_system<mm2_service>();
                    spdlog::trace("order successfully placed, refreshing orders and swap");
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
            this->set_buy_sell_rpc_busy(false);
        };

        //! Async call
        ::mm2::api::async_rpc_batch_standalone(batch, mm2_system.get_mm2_client(), mm2_system.get_cancellation_token())
            .then(answer_functor)
            .then(&handle_exception_pplx_task);
    }

    void
    trading_page::place_sell_order(
        const QString& base, const QString& rel, const QString& price, const QString& volume, bool is_created_order, const QString& price_denom,
        const QString& price_numer, const QString& rel_nota, const QString& rel_confs)
    {
        auto max_taker_vol = this->get_orderbook_wrapper()->get_base_max_taker_vol().toJsonObject();
        // qDebug() << "max_taker_vol: " << max_taker_vol;
        spdlog::info(
            "place_sell_order with: base({}), rel ({}), price ({}), volume ({}), is_created_order ({}), price_denom ({}), price_numer ({}), max_taker_vol ({})",
            base.toStdString(), rel.toStdString(), price.toStdString(), volume.toStdString(), is_created_order, price_numer.toStdString(),
            price_denom.toStdString(), max_taker_vol.value("decimal").toString().toStdString());
        this->set_buy_sell_rpc_busy(true);
        this->set_buy_sell_last_rpc_data(QJsonObject{{}});
        t_float_50 amount_f;
        amount_f.assign(volume.toStdString());

        t_sell_request req{
            .base             = base.toStdString(),
            .rel              = rel.toStdString(),
            .price            = price.toStdString(),
            .volume           = volume.toStdString(),
            .is_created_order = is_created_order,
            .price_denom      = price_denom.toStdString(),
            .price_numer      = price_numer.toStdString(),
            .rel_nota         = rel_nota.isEmpty() ? std::optional<bool>{std::nullopt} : boost::lexical_cast<bool>(rel_nota.toStdString()),
            .rel_confs        = rel_confs.isEmpty() ? std::optional<std::size_t>{std::nullopt} : rel_confs.toUInt()};
        nlohmann::json batch;
        nlohmann::json sell_request = ::mm2::api::template_request("sell");
        ::mm2::api::to_json(sell_request, req);
        batch.push_back(sell_request);
        auto& mm2_system = m_system_manager.get_system<mm2_service>();

        //! Answer
        auto answer_functor = [this](web::http::http_response resp) {
            std::string body = TO_STD_STR(resp.extract_string(true).get());
            if (resp.status_code() == 200)
            {
                if (body.find("error") == std::string::npos)
                {
                    auto           answers = nlohmann::json::parse(body);
                    nlohmann::json answer  = answers[0];
                    this->set_buy_sell_last_rpc_data(nlohmann_json_object_to_qt_json_object(answer));
                    auto& mm2_system = m_system_manager.get_system<mm2_service>();
                    spdlog::trace("order successfully placed, refreshing orders and swap");
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
            this->set_buy_sell_rpc_busy(false);
        };

        //! Async call
        ::mm2::api::async_rpc_batch_standalone(batch, mm2_system.get_mm2_client(), mm2_system.get_cancellation_token())
            .then(answer_functor)
            .then(&handle_exception_pplx_task);
    }
} // namespace atomic_dex

//! Public API
namespace atomic_dex
{
    void
    trading_page::disable_coins(const QStringList& coins) noexcept
    {
        for (auto&& coin: coins)
        {
            auto* market_selector_mdl = get_market_pairs_mdl();
            if (market_selector_mdl->get_left_selected_coin() == coin)
            {
                market_selector_mdl->set_left_selected_coin("BTC");
                market_selector_mdl->set_right_selected_coin("KMD");
            }
            else if (market_selector_mdl->get_right_selected_coin() == coin)
            {
                market_selector_mdl->set_left_selected_coin("BTC");
                market_selector_mdl->set_right_selected_coin("KMD");
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
    trading_page::update() noexcept
    {
    }

    void
    trading_page::connect_signals()
    {
        dispatcher_.sink<process_orderbook_finished>().connect<&trading_page::on_process_orderbook_finished_event>(*this);
        dispatcher_.sink<multi_ticker_enabled>().connect<&trading_page::on_multi_ticker_enabled>(*this);
    }

    void
    atomic_dex::trading_page::disconnect_signals()
    {
        dispatcher_.sink<process_orderbook_finished>().disconnect<&trading_page::on_process_orderbook_finished_event>(*this);
        dispatcher_.sink<multi_ticker_enabled>().disconnect<&trading_page::on_multi_ticker_enabled>(*this);
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

    market_pairs*
    trading_page::get_market_pairs_mdl() const noexcept
    {
        return qobject_cast<market_pairs*>(m_models[models::market_selector]);
    }

    bool
    trading_page::is_buy_sell_rpc_busy() const noexcept
    {
        return m_rpc_buy_sell_busy.load();
    }

    void
    trading_page::set_buy_sell_rpc_busy(bool status) noexcept
    {
        if (m_rpc_buy_sell_busy != status)
        {
            m_rpc_buy_sell_busy = status;
            emit buySellRpcStatusChanged();
        }
    }

    QVariant
    trading_page::get_buy_sell_last_rpc_data() const noexcept
    {
        return m_rpc_buy_sell_result.get();
    }

    void
    trading_page::set_buy_sell_last_rpc_data(QVariant rpc_data) noexcept
    {
        m_rpc_buy_sell_result = rpc_data.toJsonObject();
        emit buySellLastRpcDataChanged();
    }

    bool
    trading_page::is_fetching_multi_ticker_fees_busy() const noexcept
    {
        return m_fetching_multi_ticker_fees_busy.load();
    }

    void
    trading_page::set_fetching_multi_ticker_fees_busy(bool status) noexcept
    {
        if (m_fetching_multi_ticker_fees_busy != status)
        {
            m_fetching_multi_ticker_fees_busy = status;
            emit multiTickerFeesStatusChanged();
        }
    }

    void
    trading_page::on_multi_ticker_enabled(const multi_ticker_enabled& evt) noexcept
    {
        this->fetch_additional_fees(evt.ticker);
    }

    void
    trading_page::place_multiple_sell_order() noexcept
    {
        nlohmann::json         batch    = nlohmann::json::array();
        portfolio_proxy_model* model    = this->get_market_pairs_mdl()->get_multiple_selection_box();
        int                    nb_items = model->rowCount();
        for (int cur_idx = 0; cur_idx < nb_items; ++cur_idx)
        {
            QModelIndex idx                  = model->index(cur_idx, 0);
            bool        multi_ticker_enabled = model->data(idx, portfolio_model::PortfolioRoles::IsMultiTickerCurrentlyEnabled).toBool();
            std::string ticker               = model->data(idx, portfolio_model::PortfolioRoles::TickerRole).toString().toStdString();
            if (multi_ticker_enabled)
            {
                QJsonObject obj = model->data(idx, portfolio_model::PortfolioRoles::MultiTickerData).toJsonObject();
                if (not obj.isEmpty())
                {
                    nlohmann::json json = nlohmann::json::parse(QJsonDocument(obj).toJson(QJsonDocument::Compact).toStdString());
                    t_sell_request req{
                        .base             = json.at("base").get<std::string>(),
                        .rel              = json.at("rel").get<std::string>(),
                        .price            = json.at("price").get<std::string>(),
                        .volume           = json.at("volume").get<std::string>(),
                        .is_created_order = json.at("is_created_order").get<bool>(),
                        .price_denom      = "",
                        .price_numer      = "",
                        .rel_nota         = "",
                        .rel_confs        = 0};
                    nlohmann::json sell_request = ::mm2::api::template_request("sell");
                    ::mm2::api::to_json(sell_request, req);
                    batch.push_back(sell_request);
                }
                else
                {
                    spdlog::error("empty json send from the front end for ticker: {} - ignoring", ticker);
                }
            }
        }

        auto& mm2_system     = m_system_manager.get_system<mm2_service>();
        auto  answer_functor = [](web::http::http_response resp) {
            std::string body = TO_STD_STR(resp.extract_string(true).get());
            if (resp.status_code() == 200)
            {
                auto answers = nlohmann::json::parse(body);
            }
            else
            {
                auto error_json = QJsonObject({{"error_code", resp.status_code()}, {"error_message", QString::fromStdString(body)}});
            }
        };

        ::mm2::api::async_rpc_batch_standalone(batch, mm2_system.get_mm2_client(), mm2_system.get_cancellation_token())
            .then(answer_functor)
            .then(&handle_exception_pplx_task);
    }

} // namespace atomic_dex

//! Properties related to trading
namespace atomic_dex
{
    MarketMode
    trading_page::get_market_mode() const noexcept
    {
        return m_market_mode;
    }

    void
    trading_page::set_market_mode(MarketMode market_mode) noexcept
    {
        if (this->m_market_mode != market_mode)
        {
            this->m_market_mode = market_mode;
            spdlog::info("switching market_mode, new mode: {}", m_market_mode == MarketMode::Buy ? "buy" : "sell");
            this->clear_forms();
            auto* market_selector_mdl = get_market_pairs_mdl();
            set_current_orderbook(market_selector_mdl->get_left_selected_coin(), market_selector_mdl->get_right_selected_coin());
            emit marketModeChanged();
        }
    }

    QString
    trading_page::get_price() const noexcept
    {
        return m_price;
    }
    void
    trading_page::set_price(QString price) noexcept
    {
        if (m_price != price)
        {
            m_price = std::move(price);
            spdlog::trace("price is [{}]", m_price.toStdString());
            //! When price change in MarketMode::Buy you want to redetermine max_volume
            if (m_market_mode == MarketMode::Buy)
            {
                this->determine_max_volume();
            }
            this->determine_total_amount();
            emit priceChanged();
        }
    }

    void
    trading_page::clear_forms() noexcept
    {
        spdlog::info("clearing forms");
        this->set_price("");
        this->set_volume("");
        this->set_max_volume("0");
        this->set_total_amount("0");
        this->m_preffered_order = std::nullopt;
        this->m_fees            = QVariantMap();
        emit feesChanged();
        emit prefferedOrderChanged();
    }

    QString
    trading_page::get_volume() const noexcept
    {
        return m_volume;
    }
    void
    trading_page::set_volume(QString volume) noexcept
    {
        if (m_volume != volume)
        {
            m_volume = std::move(volume);
            spdlog::trace("volume is [{}]", m_volume.toStdString());
            this->determine_total_amount();
            emit volumeChanged();
            this->cap_volume();
        }
    }

    QString
    trading_page::get_max_volume() const noexcept
    {
        return m_max_volume;
    }

    void
    trading_page::set_max_volume(QString max_volume) noexcept
    {
        if (m_max_volume != max_volume)
        {
            m_max_volume = std::move(max_volume);
            spdlog::trace("max_volume is [{}]", m_max_volume.toStdString());
            emit maxVolumeChanged();
        }
    }

    void
    trading_page::determine_max_volume() noexcept
    {
        if (this->m_market_mode == MarketMode::Sell)
        {
            //! In MarketMode::Sell mode max volume is just the base_max_taker_vol
            const auto max_taker_vol = get_orderbook_wrapper()->get_base_max_taker_vol().toJsonObject()["decimal"].toString().toStdString();
            if (not max_taker_vol.empty())
            {
                spdlog::info("max_taker_vol is valid, processing...");
                const auto max_vol_str = utils::format_float(t_float_50(max_taker_vol));

                //! max_volume is max_taker_vol
                this->set_max_volume(QString::fromStdString(max_vol_str));

                //! Capping it
                this->cap_volume();
            }
            else
            {
                spdlog::warn("max_taker_vol cannot be empty, is it called before being determinated ?");
            }
        }
        else
        {
            //! In MarketMode::Buy mode the max volume is base_max_taker_vol / price
            if (not m_price.isEmpty())
            {
                t_float_50 max_vol(get_orderbook_wrapper()->get_rel_max_taker_vol().toJsonObject()["decimal"].toString().toStdString());
                max_vol = std::max(t_float_50(0), max_vol);
                t_float_50 price_f(m_price.toStdString());
                t_float_50 res = price_f > t_float_50(0) ? max_vol / price_f : t_float_50(0);
                this->set_max_volume(QString::fromStdString(utils::format_float(res)));
                this->cap_volume();
            }
        }
    }

    void
    trading_page::cap_volume() noexcept
    {
        /*
         * cap_volume is called only in MarketMode::Buy, and in Sell mode if prefered order
         * if the current volume text field is > the new max_volume then set volume to max_volume
         */
        if (auto std_volume = this->get_volume().toStdString(); not std_volume.empty())
        {
            if (t_float_50(std_volume) > t_float_50(this->get_max_volume().toStdString()))
            {
                this->set_volume(this->get_max_volume());
            }
        }
    }

    TradingError
    trading_page::get_trading_error() const noexcept
    {
        return m_last_trading_error;
    }

    void
    trading_page::set_trading_error(TradingError trading_error) noexcept
    {
        if (m_last_trading_error != trading_error)
        {
            m_last_trading_error = trading_error;
            switch (m_last_trading_error)
            {
            case TradingErrorGadget::None:
                spdlog::info("last_trading_error is None");
                break;
            case TradingErrorGadget::BaseNotEnoughFunds:
                spdlog::warn("last_trading_error is BaseNotEnoughFunds");
                break;
            case TradingErrorGadget::RelTransactionFeesNotEnough:
                spdlog::warn("last_trading_error is RelTransactionFeesNotEnough");
                break;
            case TradingErrorGadget::BalanceIsLessThanTheMinimalTradingAmount:
                spdlog::warn("last_trading_error is BalanceIsLessThanTheMinimalTradingAmount");
                break;
            case TradingErrorGadget::TradingFeesNotEnoughFunds:
                spdlog::warn("last_trading_error is TradingFeesNotEnoughFunds");
                break;
            case TradingErrorGadget::BaseTransactionFeesNotEnough:
                spdlog::warn("last_trading_error is BaseTransactionFeesNotEnough");
                break;
            case TradingErrorGadget::PriceFieldNotFilled:
                spdlog::warn("last_trading_error is PriceFieldNotFilled");
                break;
            case TradingErrorGadget::VolumeFieldNotFilled:
                spdlog::warn("last_trading_error is VolumeFieldNotFilled");
                break;
            case TradingErrorGadget::VolumeIsLowerThanTheMinimum:
                spdlog::warn("last_trading_error is VolumeIsLowerThanTheMinimum");
                break;
            case TradingErrorGadget::ReceiveVolumeIsLowerThanTheMinimum:
                spdlog::warn("last_trading_error is ReceiveVolumeIsLowerThanTheMinimum");
                break;
            }
            emit tradingErrorChanged();
        }
    }

    bool
    trading_page::set_pair(bool is_left_side, QString changed_ticker) noexcept
    {
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
            set_current_orderbook(base, rel);
        }
        return true;
    }

    QVariantMap
    trading_page::get_preffered_order() noexcept
    {
        if (m_preffered_order.has_value())
        {
            return nlohmann_json_object_to_qt_json_object(m_preffered_order.value()).toVariantMap();
        }

        return QVariantMap();
    }

    void
    trading_page::set_preffered_order(QVariantMap price_object) noexcept
    {
        if (auto preffered_order = nlohmann::json::parse(QString(QJsonDocument(QJsonObject::fromVariantMap(price_object)).toJson()).toStdString());
            preffered_order != m_preffered_order)
        {
            m_preffered_order = std::move(preffered_order);
            emit prefferedOrderChanged();
            if (not m_preffered_order->empty() && m_preffered_order->contains("price"))
            {
                this->set_price(QString::fromStdString(utils::format_float(t_float_50(m_preffered_order->at("price").get<std::string>()))));
                this->set_volume(QString::fromStdString(utils::format_float(t_float_50(m_preffered_order->at("quantity").get<std::string>()))));
                this->determine_max_volume();
            }
        }
    }

    QString
    trading_page::get_total_amount() const noexcept
    {
        return m_total_amount;
    }

    void
    trading_page::set_total_amount(QString total_amount) noexcept
    {
        if (m_total_amount != total_amount)
        {
            m_total_amount = std::move(total_amount);
            spdlog::trace("total_amount is [{}]", m_total_amount.toStdString());
            emit totalAmountChanged();
            emit baseAmountChanged();
            emit relAmountChanged();
        }
    }

    void
    trading_page::determine_total_amount() noexcept
    {
        if (not m_price.isEmpty() && not m_volume.isEmpty())
        {
            t_float_50 price(m_price.toStdString());
            t_float_50 volume(m_volume.toStdString());
            t_float_50 total_amount_f = volume * price;
            this->set_total_amount(QString::fromStdString(utils::format_float(total_amount_f)));
            this->determine_fees();
            this->determine_error_cases();
        }
    }

    QString
    trading_page::get_base_amount() const noexcept
    {
        return m_market_mode == MarketMode::Sell ? m_volume : m_total_amount;
    }

    QString
    trading_page::get_rel_amount() const noexcept
    {
        return m_market_mode == MarketMode::Sell ? m_total_amount : m_volume;
    }

    QVariantMap
    trading_page::get_fees() const noexcept
    {
        return m_fees;
    }

    void
    trading_page::set_fees(QVariantMap fees) noexcept
    {
        if (fees != m_fees)
        {
            m_fees = std::move(fees);
            qDebug() << "fees are: [" << m_fees << "]";
            emit feesChanged();
        }
    }

    void
    trading_page::determine_fees() noexcept
    {
        const auto* market_pair = get_market_pairs_mdl();
        const auto& mm2         = this->m_system_manager.get_system<mm2_service>();

        //! Send
        const auto base = market_pair->get_base_selected_coin();

        //! Receive
        const auto rel = market_pair->get_rel_selected_coin();

        //! (send) BCH <-> ETH (receive)
        bool is_max = false;

        //! If We are in sell mode check if it's max
        if (m_market_mode == MarketMode::Sell)
        {
            if (m_volume == m_max_volume) //! It's capped, means max_trade_vol means all the fees are included
            {
                is_max = true;
            }
        }

        //! Trading fees

        //! 1 / 777 * total_amount (if max is true, total_amount will be the balance);
        const t_float_50 trade_fee_f = mm2.get_trading_fees(base.toStdString(), m_total_amount.toStdString(), is_max);

        //! Transaction Fees
        const auto answer   = mm2.get_transaction_fees(base.toStdString());
        t_float_50 tx_fee_f = 0;

        //! If answer is valid
        if (!answer.amount.empty())
        {
            tx_fee_f = t_float_50(answer.amount) * 2;
        }

        t_float_50        specific_fees(0);
        const std::string extra_fees_ticker = mm2.apply_specific_fees(rel.toStdString(), specific_fees);

        //! Write output
        QVariantMap fees;

        fees["trading_fee"] = QString::fromStdString(utils::format_float(trade_fee_f));

        //! for BCH <-> ETH, trading_fee_ticker will be BCH
        fees["trading_fee_ticker"] = base;

        //! Base transaction fees
        fees["base_transaction_fees"]        = QString::fromStdString(utils::format_float(tx_fee_f));
        fees["base_transaction_fees_ticker"] = QString::fromStdString(answer.coin);

        if (not extra_fees_ticker.empty())
        {
            fees["rel_transaction_fees"]        = QString::fromStdString(utils::format_float(specific_fees));
            fees["rel_transaction_fees_ticker"] = QString::fromStdString(extra_fees_ticker);
        }

        if (base.toStdString() == answer.coin)
        {
            //! It's the same coin for trading_fees and transaction fees let's add a total
            t_float_50 total_base_fees_f = trade_fee_f + tx_fee_f;
            fees["total_base_fees"]      = QString::fromStdString(utils::format_float(total_base_fees_f));
            fees["total_base_fees_fp"]   = QString::fromStdString(total_base_fees_f.str(50, std::ios_base::fixed));
        }

        this->set_fees(fees);
    }

    void
    trading_page::determine_error_cases() noexcept
    {
        TradingError current_trading_error = TradingError::None;

        //! Check minimal trading amount
        const std::string base = this->get_market_pairs_mdl()->get_base_selected_coin().toStdString();
        const auto&       mm2  = this->m_system_manager.get_system<mm2_service>();
        t_float_50        max_balance_without_dust(
            (m_market_mode == MarketMode::Sell ? get_orderbook_wrapper()->get_base_max_taker_vol() : get_orderbook_wrapper()->get_rel_max_taker_vol())
                .toJsonObject()["decimal"]
                .toString()
                .toStdString());

        if (max_balance_without_dust < utils::minimal_trade_amount()) //<! Checking balance < minimal_trading_amount
        {
            current_trading_error = TradingError::BalanceIsLessThanTheMinimalTradingAmount;
        }
        else if (m_volume.isEmpty() || m_volume == "0") ///< Volume is not set correctly
        {
            current_trading_error = TradingError::VolumeFieldNotFilled;
        }
        else if (m_price.isEmpty() || m_price == "0") ///< Price is not set correctly
        {
            current_trading_error = TradingError::PriceFieldNotFilled;
        }
        else if (t_float_50(get_base_amount().toStdString()) < utils::minimal_trade_amount())
        {
            current_trading_error = TradingError::VolumeIsLowerThanTheMinimum;
        }
        else if (t_float_50(get_rel_amount().toStdString()) < utils::minimal_trade_amount())
        {
            current_trading_error = TradingError::ReceiveVolumeIsLowerThanTheMinimum;
        }
        else if (const auto trading_fee_ticker = m_fees["trading_fee_ticker"].toString();
                 m_fees["trading_fee_ticker"] != m_fees["base_transaction_fees_ticker"] &&
                 not mm2.do_i_have_enough_funds(trading_fee_ticker.toStdString(), t_float_50(m_fees["trading_fee"].toString().toStdString())))
        {
            current_trading_error = TradingError::TradingFeesNotEnoughFunds;
        }
        else if (m_fees.contains("total_base_fees") && t_float_50(m_fees["total_base_fees_fp"].toString().toStdString()) > max_balance_without_dust)
        {
            current_trading_error = TradingError::BaseNotEnoughFunds;
        }
        else if (m_fees.contains("rel_transaction_fees_ticker")) //! Checking rel coin if specific fees aka: ETH, QTUM, QRC-20, ERC-20 ?
        {
            const auto rel_ticker = m_fees["rel_transaction_fees_ticker"].toString().toStdString();
            t_float_50 rel_amount(m_fees["rel_transaction_fees"].toString().toStdString());
            if (not mm2.do_i_have_enough_funds(rel_ticker, rel_amount))
            {
                current_trading_error = TradingError::RelTransactionFeesNotEnough;
            }
        }

        //! Check for base coin
        this->set_trading_error(current_trading_error);
    }
} // namespace atomic_dex
