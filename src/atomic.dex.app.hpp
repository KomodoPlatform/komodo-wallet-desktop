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

//! QT Headers
#include <QAbstractListModel>
#include <QApplication>
#include <QImage>
#include <QObject>
#include <QSize>
#include <QStringList>
#include <QTranslator>
#include <QVariantMap>

//! PCH Headers
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.cfg.hpp"
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"
#include "atomic.dex.qt.addressbook.model.hpp"
#include "atomic.dex.qt.bindings.hpp"
#include "atomic.dex.qt.candlestick.charts.model.hpp"
#include "atomic.dex.qt.current.coin.infos.hpp"
#include "atomic.dex.qt.internet.checker.service.hpp"
#include "atomic.dex.qt.orderbook.hpp"
#include "atomic.dex.qt.orders.model.hpp"
#include "atomic.dex.qt.portfolio.model.hpp"
#include "atomic.dex.qt.wallet.manager.hpp"

namespace ag = antara::gaming;

inline constexpr std::size_t g_max_actions_size{128};

namespace atomic_dex
{
    struct application : public QObject, public ag::world::app
    {
        Q_OBJECT

        //! Properties
        Q_PROPERTY(QString empty_string READ get_empty_string NOTIFY langChanged)
        Q_PROPERTY(QList<QVariant> enabled_coins READ get_enabled_coins NOTIFY enabledCoinsChanged)
        Q_PROPERTY(QList<QVariant> enableable_coins READ get_enableable_coins NOTIFY enableableCoinsChanged)
        Q_PROPERTY(QObject* current_coin_info READ get_current_coin_info NOTIFY coinInfoChanged)
        Q_PROPERTY(addressbook_model* addressbook_mdl READ get_addressbook NOTIFY addressbookChanged)
        Q_PROPERTY(orders_model* orders_mdl READ get_orders NOTIFY ordersChanged)
        Q_PROPERTY(qt_orderbook_wrapper* orderbook READ get_orderbook_wrapper NOTIFY orderbookChanged)
        Q_PROPERTY(candlestick_charts_model* candlestick_charts_mdl READ get_candlestick_charts NOTIFY candlestickChartsChanged)
        Q_PROPERTY(QVariant update_status READ get_update_status NOTIFY updateStatusChanged)
        Q_PROPERTY(portfolio_model* portfolio_mdl READ get_portfolio NOTIFY portfolioChanged)
        Q_PROPERTY(internet_service_checker* internet_checker READ get_internet_checker NOTIFY internetCheckerChanged)
        Q_PROPERTY(QString current_currency READ get_current_currency WRITE set_current_currency NOTIFY onCurrencyChanged)
        Q_PROPERTY(QString current_currency_sign READ get_current_currency_sign NOTIFY onCurrencySignChanged)
        Q_PROPERTY(QString current_fiat_sign READ get_current_fiat_sign NOTIFY onFiatSignChanged)
        Q_PROPERTY(QString current_fiat READ get_current_fiat WRITE set_current_fiat NOTIFY onFiatChanged)
        Q_PROPERTY(QString lang READ get_current_lang WRITE set_current_lang NOTIFY onLangChanged)
        Q_PROPERTY(QString wallet_default_name READ get_wallet_default_name WRITE set_wallet_default_name NOTIFY onWalletDefaultNameChanged)
        Q_PROPERTY(QString balance_fiat_all READ get_balance_fiat_all WRITE set_current_balance_fiat_all NOTIFY onFiatBalanceAllChanged)
        Q_PROPERTY(QString initial_loading_status READ get_status WRITE set_status NOTIFY onStatusChanged)

        //! Private function
        void refresh_transactions(const atomic_dex::mm2& mm2_system);
        void refresh_fiat_balance(const atomic_dex::mm2& mm2_system, const coinpaprika_provider& coinpaprika_system);
        void refresh_address(atomic_dex::mm2& mm2_system);
        void connect_signals();
        void tick();
        void process_refresh_enabled_coin_action();
        void process_refresh_current_ticker_infos();

        //! Private enums
        enum class action
        {
            refresh_enabled_coin             = 0,
            refresh_current_ticker           = 1,
            refresh_ohlc                     = 2,
            refresh_transactions             = 3,
            refresh_portfolio_ticker_balance = 4,
            refresh_update_status            = 5,
            post_process_orders_finished     = 6,
            post_process_swaps_finished      = 7,
            post_process_orderbook_finished  = 8
        };

        //! Private typedefs
        using t_actions_queue          = boost::lockfree::queue<action>;
        using t_synchronized_string    = boost::synchronized_value<std::string>;
        using t_manager_model_registry = std::unordered_map<std::string, QObject*>;

        //! Private members fields
        atomic_dex::cfg               m_config{load_cfg()};
        std::shared_ptr<QApplication> m_app;
        atomic_dex::qt_wallet_manager m_wallet_manager;
        t_actions_queue               m_actions_queue{g_max_actions_size};
        t_synchronized_string         m_ticker_balance_to_refresh;
        bool                          m_need_a_full_refresh_of_mm2{false};
        QVariantList                  m_enabled_coins;
        QVariantList                  m_enableable_coins;
        QVariant                      m_update_status;
        QTranslator                   m_translator;
        QString                       m_current_lang{QString::fromStdString(m_config.current_lang)};
        QString                       m_current_status{"None"};
        QString                       m_current_balance_all{"0.00"};
        current_coin_info*            m_coin_info;
        t_manager_model_registry      m_manager_models;
        candlestick_charts_model*     m_candlestick_chart_ohlc;
        std::atomic_bool              m_candlestick_need_a_reset{false};
        qt_orderbook_wrapper*         m_orderbook;
        std::atomic_bool              m_orderbook_need_a_reset{false};
        internet_service_checker*     m_internet_service_checker;
        std::atomic_bool              m_about_to_exit_app{false};

      public:
        //! Constructor
        explicit application(QObject* pParent = nullptr) noexcept;
        ~application() noexcept;

        //! entt::dispatcher events
        void on_ticker_balance_updated_event(const ticker_balance_updated&) noexcept;
        void on_enabled_coins_event(const enabled_coins_event&) noexcept;
        void on_enabled_default_coins_event(const enabled_default_coins_event&) noexcept;
        void on_coin_fully_initialized_event(const coin_fully_initialized&) noexcept;
        void on_change_ticker_event(const change_ticker_event&) noexcept;
        void on_tx_fetch_finished_event(const tx_fetch_finished&) noexcept;
        void on_coin_disabled_event(const coin_disabled&) noexcept;
        void on_mm2_initialized_event(const mm2_initialized&) noexcept;
        void on_mm2_started_event(const mm2_started&) noexcept;
        void on_refresh_ohlc_event(const refresh_ohlc_needed&) noexcept;
        void on_refresh_update_status_event(const refresh_update_status&) noexcept;
        void on_process_orders_finished_event(const process_orders_finished&) noexcept;
        void on_process_swaps_finished_event(const process_swaps_finished&) noexcept;
        void on_process_orderbook_finished_event(const process_orderbook_finished&) noexcept;
        void on_start_fetching_new_ohlc_data_event(const start_fetching_new_ohlc_data&);

        //! Properties Getter
        static const QString&      get_empty_string();
        mm2&                       get_mm2() noexcept;
        const mm2&                 get_mm2() const noexcept;
        coinpaprika_provider&      get_paprika() noexcept;
        entt::dispatcher&          get_dispatcher() noexcept;
        QObject*                   get_current_coin_info() const noexcept;
        addressbook_model*         get_addressbook() const noexcept;
        portfolio_model*           get_portfolio() const noexcept;
        orders_model*              get_orders() const noexcept;
        candlestick_charts_model*  get_candlestick_charts() const noexcept;
        internet_service_checker*  get_internet_checker() const noexcept;
        qt_orderbook_wrapper*      get_orderbook_wrapper() const noexcept;
        QVariantList               get_enabled_coins() const noexcept;
        QVariantList               get_enableable_coins() const noexcept;
        QString                    get_current_currency() const noexcept;
        QString                    get_current_currency_sign() const noexcept;
        QString                    get_current_fiat_sign() const noexcept;
        QString                    get_current_fiat() const noexcept;
        QString                    get_current_lang() const noexcept;
        QString                    get_balance_fiat_all() const noexcept;
        QString                    get_wallet_default_name() const noexcept;
        QString                    get_status() const noexcept;
        QVariant                   get_update_status() const noexcept;
        Q_INVOKABLE static QString get_version() noexcept;

        //! Properties Setter
        void set_current_currency(const QString& current_currency) noexcept;
        void set_current_fiat(const QString& current_fiat) noexcept;
        void set_current_lang(const QString& current_lang) noexcept;
        void set_wallet_default_name(QString wallet_default_name) noexcept;
        void set_current_balance_fiat_all(QString current_fiat_all_balance) noexcept;
        void set_status(QString status) noexcept;
        void set_qt_app(std::shared_ptr<QApplication> app) noexcept;

        //! Launch the internal loop for the SDK.
        void launch();

        //! Bind to the QML Worlds

        //! Wallet Manager QML API Bindings, this internally call the `atomic_dex::qt_wallet_manager`
        Q_INVOKABLE bool               login(const QString& password, const QString& wallet_name);
        Q_INVOKABLE bool               create(const QString& password, const QString& seed, const QString& wallet_name);
        Q_INVOKABLE static QStringList get_wallets();
        Q_INVOKABLE static bool        is_there_a_default_wallet();
        Q_INVOKABLE static QString     get_default_wallet_name();
        Q_INVOKABLE static bool        delete_wallet(const QString& wallet_name);
        Q_INVOKABLE static bool        confirm_password(const QString& wallet_name, const QString& password);

        //! Miscs
        Q_INVOKABLE QString        get_paprika_id_from_ticker(const QString& ticker) const;
        Q_INVOKABLE static QString to_eth_checksum_qt(const QString& eth_lowercase_address);
        Q_INVOKABLE static QString get_mm2_version();
        Q_INVOKABLE static QString get_log_folder();
        Q_INVOKABLE static QString get_export_folder();
        Q_INVOKABLE QStringList    get_available_langs() const;
        Q_INVOKABLE QStringList    get_available_fiats() const;
        Q_INVOKABLE QStringList    get_available_currencies() const;
        Q_INVOKABLE static void    change_state(int visibility);

        //! Portfolio QML API Bindings
        Q_INVOKABLE static QString recover_fund(const QString& uuid);
        Q_INVOKABLE QObject* prepare_send(const QString& address, const QString& amount, bool max = false);
        Q_INVOKABLE QObject* prepare_send_fees(
            const QString& address, const QString& amount, bool is_erc_20, const QString& fees_amount, const QString& gas_price, const QString& gas,
            bool max = false);
        Q_INVOKABLE QString send(const QString& tx_hex);
        Q_INVOKABLE QString send_rewards(const QString& tx_hex);

        //! Trading QML API Bindings
        Q_INVOKABLE void on_gui_enter_dex();
        Q_INVOKABLE void on_gui_leave_dex();
        Q_INVOKABLE void cancel_order(const QString& order_id);
        Q_INVOKABLE void cancel_all_orders();
        Q_INVOKABLE void cancel_all_orders_by_ticker(const QString& ticker);

        //! Others
        Q_INVOKABLE static bool    mnemonic_validate(const QString& entropy);
        Q_INVOKABLE static QString retrieve_seed(const QString& wallet_name, const QString& password);
        Q_INVOKABLE void           refresh_infos();
        Q_INVOKABLE void           refresh_orders_and_swaps();
        Q_INVOKABLE static QString get_mnemonic();
        Q_INVOKABLE static bool    first_run();
        Q_INVOKABLE bool           disconnect();
        Q_INVOKABLE bool           enable_coins(const QStringList& coins);
        Q_INVOKABLE QString        get_balance(const QString& coin);
        Q_INVOKABLE static QString get_price_amount(const QString& base_amount, const QString& rel_amount);
        Q_INVOKABLE QString        place_buy_order(
                   const QString& base, const QString& rel, const QString& price, const QString& volume, bool is_created_order, const QString& price_denom,
                   const QString& price_numer, const QString& base_nota = "", const QString& base_confs = "");
        Q_INVOKABLE QString place_sell_order(
            const QString& base, const QString& rel, const QString& price, const QString& volume, bool is_created_order, const QString& price_denom,
            const QString& price_numer, const QString& rel_nota = "", const QString& rel_confs = "");
        Q_INVOKABLE void set_current_orderbook(const QString& base, const QString& rel);
        Q_INVOKABLE bool do_i_have_enough_funds(const QString& ticker, const QString& amount) const;
        Q_INVOKABLE bool disable_coins(const QStringList& coins);
        Q_INVOKABLE bool is_claiming_ready(const QString& ticker);
        Q_INVOKABLE QObject* claim_rewards(const QString& ticker);


        Q_INVOKABLE QString        get_cex_rates(const QString& base, const QString& rel);
        Q_INVOKABLE QString        get_fiat_from_amount(const QString& ticker, const QString& amount);
        Q_INVOKABLE QVariantMap    find_closest_ohlc_data(int range, int timestamp);
        Q_INVOKABLE QVariant       get_coin_info(const QString& ticker);
        Q_INVOKABLE bool           export_swaps(const QString& csv_filename) noexcept;
        Q_INVOKABLE bool           export_swaps_json() noexcept;
        Q_INVOKABLE static QString get_regex_password_policy() noexcept;
        Q_INVOKABLE QVariantMap    get_trade_infos(const QString& ticker, const QString& receive_ticker, const QString& amount);
        Q_INVOKABLE QVariantList   get_all_coins() const noexcept;

      signals:
        //! Signals to the QML Worlds
        void enabledCoinsChanged();
        void enableableCoinsChanged();
        void coinInfoChanged();
        void onCurrencyChanged();
        void onCurrencySignChanged();
        void onFiatSignChanged();
        void onFiatChanged();
        void onLangChanged();
        void langChanged();
        void onFiatBalanceAllChanged();
        void onSecondFiatBalanceAllChanged();
        void onStatusChanged();
        void onWalletDefaultNameChanged();
        void myOrdersUpdated();
        void addressbookChanged();
        void OHLCDataUpdated();
        void portfolioChanged();
        void updateStatusChanged();
        void ordersChanged();
        void candlestickChartsChanged();
        void orderbookChanged();
        void internetCheckerChanged();
      public slots:
        void exit_handler();
    };
} // namespace atomic_dex
