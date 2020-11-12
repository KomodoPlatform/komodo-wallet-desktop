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

#pragma once

//! Deps
#include <boost/lockfree/queue.hpp>

//! QT
#include <QObject>

//! Project Headers
#include "atomicdex/events/events.hpp"
#include "src/atomicdex/constants/qt.actions.hpp"
#include "src/atomicdex/events/qt.events.hpp"
#include "src/atomicdex/models/qt.candlestick.charts.model.hpp"
#include "src/atomicdex/models/qt.portfolio.model.hpp"
#include "src/atomicdex/widgets/dex/qt.market.pairs.hpp"
#include "src/atomicdex/widgets/dex/qt.orderbook.hpp"

namespace atomic_dex
{
    class trading_page final : public QObject, public ag::ecs::pre_update_system<trading_page>
    {
        //! Q_Object definition
        Q_OBJECT

        //! Q Properties definitions
        Q_PROPERTY(qt_orderbook_wrapper* orderbook READ get_orderbook_wrapper NOTIFY orderbookChanged)
        //Q_PROPERTY(candlestick_charts_model* candlestick_charts_mdl READ get_candlestick_charts NOTIFY candlestickChartsChanged)
        Q_PROPERTY(market_pairs* market_pairs_mdl READ get_market_pairs_mdl NOTIFY marketPairsChanged)
        Q_PROPERTY(QVariant buy_sell_last_rpc_data READ get_buy_sell_last_rpc_data WRITE set_buy_sell_last_rpc_data NOTIFY buySellLastRpcDataChanged)
        Q_PROPERTY(bool buy_sell_rpc_busy READ is_buy_sell_rpc_busy WRITE set_buy_sell_rpc_busy NOTIFY buySellRpcStatusChanged)
        Q_PROPERTY(bool fetching_multi_ticker_fees_busy READ is_fetching_multi_ticker_fees_busy WRITE set_fetching_multi_ticker_fees_busy NOTIFY
                       multiTickerFeesStatusChanged)

        //! Private enum
        enum models
        {
            orderbook       = 0,
            market_selector = 1,
            models_size     = 2
        };

        enum models_actions
        {
            orderbook_need_a_reset   = 0,
            models_actions_size      = 1
        };

        enum class trading_actions
        {
            post_process_orderbook_finished = 0,
        };

        enum market_mode
        {
            sell = 0,
            buy  = 1
        };

        //! Private typedefs
        using t_models               = std::array<QObject*, models_size>;
        using t_models_actions       = std::array<std::atomic_bool, models_actions_size>;
        using t_actions_queue        = boost::lockfree::queue<trading_actions>;
        using t_qt_synchronized_json = boost::synchronized_value<QJsonObject>;

        //! Private members fields
        ag::ecs::system_manager& m_system_manager;
        std::atomic_bool&        m_about_to_exit_the_app;
        t_models                 m_models;
        t_models_actions         m_models_actions;
        t_actions_queue          m_actions_queue{g_max_actions_size};
        std::atomic_bool         m_rpc_buy_sell_busy{false};
        std::atomic_bool         m_fetching_multi_ticker_fees_busy{false};
        t_qt_synchronized_json   m_rpc_buy_sell_result;
        market_mode              m_market_mode{sell};

        //! Privae function
        void common_cancel_all_orders(bool by_coin = false, const QString& ticker = "");

      public:
        //! Constructor
        explicit trading_page(
            entt::registry& registry, ag::ecs::system_manager& system_manager, std::atomic_bool& exit_status, portfolio_model* portfolio,
            QObject* parent = nullptr);
        ~trading_page() noexcept final = default;

        //! Public override
        void update() noexcept final;

        //! Public API
        void process_action();
        void connect_signals();
        void disconnect_signals();
        void clear_models();
        void disable_coins(const QStringList& coins) noexcept;

        //! Public QML API
        Q_INVOKABLE void on_gui_enter_dex();
        Q_INVOKABLE void on_gui_leave_dex();
        Q_INVOKABLE void cancel_order(const QStringList& orders_id);
        Q_INVOKABLE void cancel_all_orders();
        Q_INVOKABLE void cancel_all_orders_by_ticker(const QString& ticker);


        Q_INVOKABLE QVariant get_raw_mm2_coin_cfg(const QString& ticker) const noexcept;

        //! Trading business
        Q_INVOKABLE void swap_market_pair();                                             ///< market_selector (button to switch market selector and orderbook)
        Q_INVOKABLE void set_current_orderbook(const QString& base, const QString& rel); ///< market_selector (called and selecting another coin)

        Q_INVOKABLE void switch_market_mode() noexcept; ///< trading_widget (when clicking on buy or sell)
        Q_INVOKABLE void place_buy_order(
            const QString& base,
            const QString& rel,
            const QString& price,
            const QString& volume,
            bool is_created_order,
            const QString& price_denom,
            const QString& price_numer,
            const QString& base_nota = "",
            const QString& base_confs = "");
        Q_INVOKABLE void place_sell_order(
            const QString& base, const QString& rel, const QString& price, const QString& volume, bool is_created_order, const QString& price_denom,
            const QString& price_numer, const QString& rel_nota = "", const QString& rel_confs = "");

        Q_INVOKABLE void fetch_additional_fees(const QString& ticker) noexcept; ///< multi ticker (when enabling a coin of the list)
        Q_INVOKABLE void place_multiple_sell_order() noexcept;                  ///< multi ticker (when confirming a multi order)

        //! Properties
        [[nodiscard]] qt_orderbook_wrapper*     get_orderbook_wrapper() const noexcept;
        //[[nodiscard]] candlestick_charts_model* get_candlestick_charts() const noexcept;
        [[nodiscard]] market_pairs*             get_market_pairs_mdl() const noexcept;
        [[nodiscard]] bool                      is_buy_sell_rpc_busy() const noexcept;
        void                                    set_buy_sell_rpc_busy(bool status) noexcept;

        //! For multi ticker part
        [[nodiscard]] bool is_fetching_multi_ticker_fees_busy() const noexcept;
        void               set_fetching_multi_ticker_fees_busy(bool status) noexcept;

        [[nodiscard]] QVariant get_buy_sell_last_rpc_data() const noexcept;
        void                   set_buy_sell_last_rpc_data(QVariant rpc_data) noexcept;

        //! Events Callbacks
        void on_process_orderbook_finished_event(const process_orderbook_finished& evt) noexcept;
        void on_start_fetching_new_ohlc_data_event(const start_fetching_new_ohlc_data& evt);
        void on_refresh_ohlc_event(const refresh_ohlc_needed& evt) noexcept;
        void on_multi_ticker_enabled(const multi_ticker_enabled& evt) noexcept;

      signals:
        void orderbookChanged();
        void candlestickChartsChanged();
        void marketPairsChanged();
        void buySellLastRpcDataChanged();
        void buySellRpcStatusChanged();
        void multiTickerFeesStatusChanged();
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::trading_page))
