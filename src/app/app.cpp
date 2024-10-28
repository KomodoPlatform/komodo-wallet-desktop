/******************************************************************************
 * Copyright © 2013-2024 The Komodo Platform Developers.                      *
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

//! Deps
#include <boost/random/random_device.hpp>
#include <wally_bip39.h>
#include <range/v3/algorithm/any_of.hpp>

//! QT
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QProcess>
#include <QSettings>
#include <QTimer>
#include <QSettings>

#ifdef __APPLE__

#    include <QGuiApplication>
#    include <QWindow>
#    include <QWindowList>

#    include "atomicdex/platform/osx/manager.hpp"
#endif

//! Project Headers
#include "app.hpp"
#include "atomicdex/services/exporter/exporter.service.hpp"
#include "atomicdex/services/kdf/auto.update.maker.order.service.hpp"
#include "atomicdex/services/price/komodo_prices/komodo.prices.provider.hpp"
#include "atomicdex/services/price/coingecko/coingecko.wallet.charts.hpp"
#include "atomicdex/services/price/orderbook.scanner.service.hpp"
#include "atomicdex/services/sync/timesync.checker.service.hpp"

namespace
{
    constexpr std::size_t g_timeout_q_timer_ms = 16;
}

namespace atomic_dex
{
    void atomic_dex::application::change_state([[maybe_unused]] int visibility)
    {
/*#ifdef __APPLE__
        {
            QWindowList windows = QGuiApplication::allWindows();
            auto        win     = windows.first();
            atomic_dex::mac_window_setup(win->winId(), visibility == QWindow::FullScreen);
        }
#endif*/
    }

    bool atomic_dex::application::enable_coins(const QStringList& coins)
    {
        auto enableable_coins_count = entity_registry_.template ctx<QSettings>().value("MaximumNbCoinsEnabled").toULongLong();
        if (enableable_coins_count < coins.size() + get_portfolio_page()->get_global_cfg()->get_enabled_coins().size())
        {
            return false;
        }
        
        std::vector<std::string> coins_std{};
        coins_std.reserve(coins.size());
        atomic_dex::kdf_service& kdf = get_kdf();
        std::unordered_set<std::string> extra_coins;
        for (auto&& coin : coins)
        {
            auto coin_info = kdf.get_coin_info(coin.toStdString());
            
            if (coin_info.has_parent_fees_ticker &&
                coin_info.ticker != coin_info.fees_ticker &&
                !coins.contains(QString::fromStdString(coin_info.fees_ticker)))
            {
                auto coin_parent_info = kdf.get_coin_info(coin_info.fees_ticker);
                // todo: why can it be empty when it has been found ?
                //       refactor coins enabling logic!!!
                if (coin_parent_info.ticker != "")
                {
                    if (!coin_parent_info.currently_enabled && !coin_parent_info.active && extra_coins.insert(coin_parent_info.ticker).second)
                    {
                        SPDLOG_INFO("Adding extra coin: {} to enable", coin_parent_info.ticker);
                    }
                }
            }
            coins_std.push_back(coin.toStdString());
        }
        for (auto&& extra_coin : extra_coins)
        {
            coins_std.push_back(extra_coin);
        }
        kdf.enable_coins(coins_std);
        return true;
    }

    bool atomic_dex::application::enable_coin(const QString& coin)
    {
        return enable_coins(QStringList{coin});
    }

    bool application::disable_coins(const QStringList& coins)
    {
        QString     primary_coin   = QString::fromStdString(g_primary_dex_coin);
        QString     secondary_coin = QString::fromStdString(g_second_primary_dex_coin);
        QStringList coins_copy;
        const auto& kdf = system_manager_.get_system<kdf_service>();
        for (auto&& coin : coins)
        {
            const auto coin_info       = kdf.get_coin_info(coin.toStdString());
            bool       has_parent_fees = coin_info.has_parent_fees_ticker;
            if (not get_orders()->swap_is_in_progress(coin) && coin != primary_coin && coin != secondary_coin)
            {
                if (!get_kdf().is_zhtlc_coin_ready(coin.toStdString()))
                {
                    this->dispatcher_.trigger<disabling_coin_failed>(coin.toStdString(), "Can't disable until fully activated.");
                }
                else
                {
                    if (has_parent_fees)
                    {
                        coins_copy.push_front(coin);
                    }
                    else
                    {
                        coins_copy.push_back(coin);
                    }
                }
            }
        }

        if (not coins_copy.empty())
        {
            std::vector<std::string> coins_std{};
            system_manager_.get_system<portfolio_page>().disable_coins(coins_copy);
            system_manager_.get_system<trading_page>().disable_coins(coins_copy);
            coins_std.reserve(coins_copy.size());
            for (auto&& coin : coins_copy)
            {
                if (QString::fromStdString(get_kdf().get_current_ticker()) == coin && m_primary_coin_fully_enabled)
                {
                    system_manager_.get_system<wallet_page>().set_current_ticker(primary_coin);
                }
                coins_std.push_back(coin.toStdString());
            }
            get_kdf().disable_multiple_coins(coins_std);
            this->dispatcher_.trigger<update_portfolio_values>(false);
        }

        return true;
    }

    bool application::disable_no_balance_coins()
    {
        auto* portfolio_page = get_portfolio_page();
        auto* portfolio_mdl = portfolio_page->get_portfolio();
        auto portfolio_data = portfolio_mdl->get_underlying_data();
        QStringList coins_to_disable{};
        
        for (auto& coin : portfolio_data)
        {
            if (coin.balance.toFloat() == 0)
            {
                coins_to_disable.push_back(coin.ticker);
            }
        }
        return disable_coins(coins_to_disable);
    }

    bool application::has_coins_with_balance()
    {
        // TODO: Does this ignore test coins?
        // Simple view on fresh wallet with only test coins from faucet returns `no tradable assets`
        auto* portfolio_page = get_portfolio_page();
        auto* portfolio_mdl = portfolio_page->get_portfolio();
        auto portfolio_data = portfolio_mdl->get_underlying_data();

        auto functor = [](const auto& coin) { return coin.balance.toFloat() > 0; }; 
        return ranges::any_of(portfolio_data, functor);
    }

    bool atomic_dex::application::first_run()
    {
        return qt_wallet_manager::get_wallets().empty();
    }

    void atomic_dex::application::reset_coin_cfg()
    {
        using namespace std::string_literals;
        const std::string wallet_name                = qt_wallet_manager::get_default_wallet_name().toStdString();
        const std::string wallet_cfg_file            = std::string(atomic_dex::get_raw_version()) + "-coins"s + "."s + wallet_name + ".json"s;
        std::string       wallet_custom_cfg_filename = "custom-tokens."s + wallet_name + ".json"s;
        const fs::path    wallet_custom_cfg_path{utils::get_atomic_dex_config_folder() / wallet_custom_cfg_filename};
        const fs::path    wallet_cfg_path{utils::get_atomic_dex_config_folder() / wallet_cfg_file};
        const fs::path    kdf_coins_file_path{atomic_dex::utils::get_current_configs_path() / "coins.json"};
        const fs::path    ini_file_path      = atomic_dex::utils::get_current_configs_path() / "cfg.ini";
        const fs::path    cfg_json_file_path = atomic_dex::utils::get_current_configs_path() / "cfg.json";
        const fs::path    logo_path          = atomic_dex::utils::get_logo_path();
        const fs::path    theme_path         = atomic_dex::utils::get_themes_path();

        const auto functor_remove = [](auto&& path_to_remove)
        {
            if (fs::exists(path_to_remove))
            {
                std::error_code ec;
                if (fs::is_directory(path_to_remove))
                {
                    fs::remove_all(path_to_remove, ec);
                }
                else
                {
                    fs::remove(path_to_remove, ec);
                }
                if (ec)
                {
                    LOG_PATH("error when removing {}", path_to_remove);
                    SPDLOG_ERROR("error: {}", ec.message());
                }
                else
                {
                    LOG_PATH("Successfully removed {}", path_to_remove);
                }
            }
        };

        if (fs::exists(wallet_cfg_path))
        {
            nlohmann::json coin_config_json_data;
            std::unordered_set<std::string> active_coins_registry;
            QFile          coins_file;
            coins_file.setFileName(std_path_to_qstring(wallet_cfg_path));
            coins_file.open(QIODevice::ReadOnly | QIODevice::Text);

            //! Read Contents
            coin_config_json_data = nlohmann::json::parse(QString(coins_file.readAll()).toStdString());
            coins_file.close();

            //! Get the active coins
            for (auto&& [key, value]: coin_config_json_data.items())
            {
                if (value["active"]) { active_coins_registry.insert(key); }
            }

            // remove old coins file
            functor_remove(std::move(wallet_cfg_path));

            //! Copy default coins file
            const auto  cfg_path = ag::core::assets_real_path() / "config";
            std::string filename = std::string(atomic_dex::get_raw_version()) + "-coins.json";
            fs::copy(cfg_path / filename, wallet_cfg_path);
            QFile          default_coins_file;

            //! Open coins file
            default_coins_file.setFileName(std_path_to_qstring(wallet_cfg_path));
            default_coins_file.open(QIODevice::ReadOnly | QIODevice::Text);

            //! Read default coins contents
            nlohmann::json default_coin_config_json_data;
            default_coin_config_json_data = nlohmann::json::parse(QString(default_coins_file.readAll()).toStdString());
            default_coins_file.close();

            //! set active coins again
            for (auto&& key: active_coins_registry)
            {
                try
                {
                    if (default_coin_config_json_data.contains(key))
                    {
                        default_coin_config_json_data[key]["active"] = true;
                    }
                }
                catch (const std::exception& error)
                {
                    SPDLOG_ERROR("Exception caught: {}", error.what());
                }
            }

            //! Write
            QFile          output_coins_file;
            //SPDLOG_DEBUG("Data written: ", default_coin_config_json_data.dump(4));
            output_coins_file.setFileName(std_path_to_qstring(wallet_cfg_path));
            output_coins_file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate);
            output_coins_file.write(QString::fromStdString(default_coin_config_json_data.dump(4)).toUtf8());
            output_coins_file.close();
        }

        if (fs::exists(wallet_custom_cfg_path))
        {
            nlohmann::json custom_config_json_data = utils::read_json_file(wallet_custom_cfg_path);

            //! Modify
            for (auto&& [key, value]: custom_config_json_data.items()) { value["active"] = false; }

            //! Write
            QFile      file;
            file.setFileName(std_path_to_qstring(wallet_custom_cfg_path));
            file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate);
            file.write(QString::fromStdString(custom_config_json_data.dump()).toUtf8());
            file.close();
        }
        functor_remove(std::move(kdf_coins_file_path));
        functor_remove(std::move(cfg_json_file_path));
        functor_remove(std::move(logo_path));
        functor_remove(std::move(theme_path));
        // Uncomment if you want to reset fiat/language/theme
        // functor_remove(std::move(ini_file_path));
        atomic_dex::application::restart();
    }

    void application::launch()
    {
        SPDLOG_INFO("Launch the application");
        this->system_manager_.start();
        auto* timer = new QTimer(this);
        connect(timer, &QTimer::timeout, this, &application::tick);
        timer->start(g_timeout_q_timer_ms);
    }

    QString atomic_dex::application::get_mnemonic()
    {
        std::array<unsigned char, WALLY_SECP_RANDOMIZE_LEN> data{};
        boost::random_device                                device;
        device.generate(data.begin(), data.end());
        char*  output       = nullptr;
        words* output_words = nullptr;
        bip39_get_wordlist(nullptr, &output_words);
        bip39_mnemonic_from_bytes(output_words, data.data(), data.size(), &output);
        bip39_mnemonic_validate(output_words, output);
        return output;
    }

    void application::tick()
    {
        this->process_one_frame();
        if (m_event_actions[events_action::need_a_full_refresh_of_kdf])
        {
            system_manager_.create_system<kdf_service>(system_manager_);
            connect_signals();
            m_event_actions[events_action::need_a_full_refresh_of_kdf] = false;
        }
        auto& kdf = get_kdf();
        if (kdf.is_kdf_running())
        {
            std::vector<std::string> to_init;
            while (not m_portfolio_queue.empty())
            {
                const char* ticker_cstr = nullptr;
                bool add_to_init(true);
                m_portfolio_queue.pop(ticker_cstr);
                std::string ticker(ticker_cstr);
                if (ticker == g_primary_dex_coin)
                {
                    this->m_primary_coin_fully_enabled = true;
                }
                if (ticker == g_second_primary_dex_coin)
                {
                    this->m_secondary_coin_fully_enabled = true;
                }
                //! TODO: figure out why sometimes ZHTLC coins end up in here twice. When they do, without this check it crashes.
                if (std::find(to_init.begin(), to_init.end(), ticker) != to_init.end()) {
                    // SPDLOG_DEBUG("Ticker {} is already in vector", ticker);
                    add_to_init = false;
                }
                if (add_to_init) {
                    to_init.push_back(ticker);
                }
                std::free((void*)ticker_cstr);
            }

            if (not to_init.empty())
            {
                system_manager_.get_system<portfolio_page>().initialize_portfolio(to_init);
                if (m_primary_coin_fully_enabled && m_secondary_coin_fully_enabled)
                {
                    if (std::find(to_init.begin(), to_init.end(), g_primary_dex_coin) != to_init.end())
                    {
                        get_wallet_page()->get_transactions_mdl()->reset();
                        this->dispatcher_.trigger<tx_fetch_finished>();
                    }
                    get_wallet_page()->refresh_ticker_infos();
                    system_manager_.get_system<qt_wallet_manager>().set_status("complete");
                }
                this->dispatcher_.trigger<update_portfolio_values>();
                if (system_manager_.has_system<coingecko_wallet_charts_service>())
                {
                    system_manager_.get_system<coingecko_wallet_charts_service>().manual_refresh("tick");
                }
            }
        }

        system_manager_.get_system<trading_page>().process_action();
        while (not this->m_actions_queue.empty())
        {
            if (m_event_actions[events_action::about_to_exit_app])
            {
                break;
            }
            action last_action;
            this->m_actions_queue.pop(last_action);
            switch (last_action)
            {
            case action::post_process_orders_and_swaps_finished:
                if (kdf.is_kdf_running())
                {
                    qobject_cast<orders_model*>(m_manager_models.at("orders"))->refresh_or_insert();
                }
                break;
            case action::post_process_orders_and_swaps_finished_reset:
                if (kdf.is_kdf_running())
                {
                    qobject_cast<orders_model*>(m_manager_models.at("orders"))->refresh_or_insert(true);
                }
                break;
            }
        }
    }

    kdf_service& application::get_kdf()
    {
        return this->system_manager_.get_system<kdf_service>();
    }

    entt::dispatcher& application::get_dispatcher()
    {
        return this->dispatcher_;
    }

    const entt::registry& application::get_registry() const
    {
        return this->entity_registry_;
    }

    entt::registry& application::get_registry()
    {
        return this->entity_registry_;
    }

    void application::post_handle_settings()
    {
        QSettings& settings = get_registry().ctx<QSettings>();
        if (settings.value("AutomaticUpdateOrderBot", false).toBool())
        {
            SPDLOG_INFO("AutomaticUpdateOrderBot is true, activating the service");
            system_manager_.create_system<auto_update_maker_order_service>(system_manager_);
        }
        else
        {
            SPDLOG_WARN("AutomaticUpdateOrderBot is false, ignoring the service");
        }
        auto category_chart = static_cast<WalletChartsCategories>(settings.value("WalletChartsCategory", 2).toInt());
        system_manager_.get_system<portfolio_page>().set_chart_category(category_chart);
    }

    application::application(QObject* pParent) : QObject(pParent)
    {
        std::filesystem::path settings_path = (atomic_dex::utils::get_current_configs_path() / "cfg.ini");
        #if defined(_WIN32) || defined(WIN32)
            this->entity_registry_.set<QSettings>(QString::fromStdWString(settings_path.wstring()), QSettings::IniFormat);
        #else
            this->entity_registry_.set<QSettings>(QString::fromStdString(settings_path.string()), QSettings::IniFormat);
        #endif

        //! Creates managers
        {
            system_manager_.create_system<qt_wallet_manager>(system_manager_);
            system_manager_.create_system<addressbook_page>(system_manager_);
        }

        //! Creates models
        {
            // m_manager_models.emplace("addressbook", new addressbook_model(system_manager_, this));
            m_manager_models.emplace("orders", new orders_model(system_manager_, this->dispatcher_, this));
            m_manager_models.emplace(
                "internet_service", std::addressof(system_manager_.create_system<internet_service_checker>(system_manager_, this->dispatcher_, this)));
            m_manager_models.emplace("notifications", new notification_manager(dispatcher_, this));
        }

        // get_dispatcher().sink<refresh_update_status>().connect<&application::on_refresh_update_status_event>(*this);
        //! KDF system need to be created before the GUI and give the instance to the gui
        system_manager_.create_system<kdf_service>(system_manager_);
        auto& settings_page_system = system_manager_.create_system<settings_page>(system_manager_, m_app, this);
        auto& portfolio_system     = system_manager_.create_system<portfolio_page>(system_manager_, this);
        portfolio_system.get_portfolio()->set_cfg(settings_page_system.get_cfg());

        system_manager_.create_system<wallet_page>(system_manager_, this);
        system_manager_.create_system<global_price_service>(system_manager_, settings_page_system.get_cfg());
        system_manager_.create_system<global_defi_stats_service>(system_manager_);
        system_manager_.create_system<orderbook_scanner_service>(system_manager_);
        system_manager_.create_system<komodo_prices_provider>();
        system_manager_.create_system<update_checker_service>();
        system_manager_.create_system<timesync_checker_service>();
        system_manager_.create_system<coingecko_wallet_charts_service>(system_manager_);
        system_manager_.create_system<exporter_service>(system_manager_);
        system_manager_.create_system<trading_page>(
            system_manager_, m_event_actions.at(events_action::about_to_exit_app), portfolio_system.get_portfolio(), this);


        system_manager_.create_system<zcash_params_service>(system_manager_, this->dispatcher_, this);

        connect_signals();
        if (qt_wallet_manager::is_there_a_default_wallet())
        {
            auto* wallet_mgr = get_wallet_mgr();
            wallet_mgr->set_wallet_default_name(wallet_mgr->get_default_wallet_name());
            // set_wallet_default_name(get_default_wallet_name());
        }
        SPDLOG_INFO("application created");
    }

    void
    application::on_coin_fully_initialized_event(const coin_fully_initialized& evt)
    {
        //! This event is called when a call is enabled and cex provider finished fetch data
        if (not m_event_actions[events_action::about_to_exit_app])
        {
            SPDLOG_DEBUG("on_coin_fully_initialized_event");
#if !defined(_WIN32)
            for (auto&& ticker: evt.tickers) {
                SPDLOG_DEBUG("Adding {} to m_portfolio_queue", ticker);
                m_portfolio_queue.push(strdup(ticker.c_str()));
            }
#else
            for (auto&& ticker: evt.tickers) {
                SPDLOG_DEBUG("Adding {} to m_portfolio_queue", ticker);
                m_portfolio_queue.push(_strdup(ticker.c_str()));
            }
#endif
        }
    }

    bool application::do_i_have_enough_funds(const QString& ticker, const QString& amount) const
    {
        t_float_50 amount_f = safe_float(amount.toStdString());
        return get_kdf().do_i_have_enough_funds(ticker.toStdString(), amount_f);
    }

    const kdf_service& application::get_kdf() const
    {
        return this->system_manager_.get_system<kdf_service>();
    }

    QJsonObject application::get_zhtlc_status(const QString& coin)
    {
        QJsonObject  res = nlohmann_json_object_to_qt_json_object(get_kdf().get_zhtlc_status(coin.toStdString()));
        return res;
    }

    QString application::get_balance_info_qstr(const QString& coin)
    {
        std::error_code ec;
        SPDLOG_DEBUG("{} l{}", __FUNCTION__, __LINE__);
        auto            res = get_kdf().get_balance_info(coin.toStdString(), ec);
        return QString::fromStdString(res);
    }

    void application::on_kdf_initialized_event([[maybe_unused]] const kdf_initialized& evt)
    {
        SPDLOG_DEBUG("{} l{}", __FUNCTION__, __LINE__);
        system_manager_.get_system<qt_wallet_manager>().set_status("enabling_coins");
    }

    // Function appears to be unused.
    void application::refresh_orders_and_swaps()
    {
        auto& kdf = get_kdf();
        if (kdf.is_kdf_running())
        {
            kdf.batch_fetch_orders_and_swap();
        }
    }

    bool application::disconnect()
    {
        //! Clears pending events
        while (not this->m_actions_queue.empty())
        {
            [[maybe_unused]] action act;
            this->m_actions_queue.pop(act);
        }

        while (not this->m_portfolio_queue.empty())
        {
            const char* ticker = nullptr;
            m_portfolio_queue.pop(ticker);
            free((void*)ticker);
        }

        auto* addressbook_pg = get_addressbook_page();
        addressbook_pg->clear();

        orders_model* orders = qobject_cast<orders_model*>(m_manager_models.at("orders"));
        if (auto count = orders->rowCount(QModelIndex()); count > 0)
        {
            orders->removeRows(0, count, QModelIndex());
        }
        orders->reset();

        system_manager_.get_system<portfolio_page>().get_portfolio()->reset();
        system_manager_.get_system<portfolio_page>().set_current_balance_fiat_all("0");
        system_manager_.get_system<trading_page>().clear_models();
        get_wallet_page()->get_transactions_mdl()->reset();


        //! Mark systems
        system_manager_.mark_system<kdf_service>();
        //system_manager_.mark_system<coingecko_provider>();

        //! Disconnect signals
        get_trading_page()->disconnect_signals();
        addressbook_pg->disconnect_signals();
        qobject_cast<notification_manager*>(m_manager_models.at("notifications"))->disconnect_signals();
        dispatcher_.sink<ticker_balance_updated>().disconnect<&application::on_ticker_balance_updated_event>(*this);
        dispatcher_.sink<fiat_rate_updated>().disconnect<&application::on_fiat_rate_updated>(*this);
        dispatcher_.sink<coin_fully_initialized>().disconnect<&application::on_coin_fully_initialized_event>(*this);
        dispatcher_.sink<kdf_initialized>().disconnect<&application::on_kdf_initialized_event>(*this);
        dispatcher_.sink<process_swaps_and_orders_finished>().disconnect<&application::on_process_orders_and_swaps_finished_event>(*this);

        m_event_actions[events_action::need_a_full_refresh_of_kdf] = true;

        //! Resets wallet name.
        auto& wallet_manager = this->system_manager_.get_system<qt_wallet_manager>();
        wallet_manager.just_set_wallet_name("");

        this->m_primary_coin_fully_enabled   = false;
        this->m_secondary_coin_fully_enabled = false;
        system_manager_.get_system<qt_wallet_manager>().set_status("None");
        return std::filesystem::remove(utils::get_atomic_dex_config_folder() / "default.wallet");
    }

    void application::connect_signals()
    {
        SPDLOG_INFO("connecting signals");
        qobject_cast<notification_manager*>(m_manager_models.at("notifications"))->connect_signals();
        system_manager_.get_system<trading_page>().connect_signals();
        system_manager_.get_system<addressbook_page>().connect_signals();
        get_dispatcher().sink<ticker_balance_updated>().connect<&application::on_ticker_balance_updated_event>(*this);
        get_dispatcher().sink<fiat_rate_updated>().connect<&application::on_fiat_rate_updated>(*this);
        get_dispatcher().sink<coin_fully_initialized>().connect<&application::on_coin_fully_initialized_event>(*this);
        get_dispatcher().sink<kdf_initialized>().connect<&application::on_kdf_initialized_event>(*this);
        get_dispatcher().sink<process_swaps_and_orders_finished>().connect<&application::on_process_orders_and_swaps_finished_event>(*this);
        // get_dispatcher().sink<process_swaps_finished>().connect<&application::on_process_swaps_finished_event>(*this);
    }

    void application::set_qt_app(std::shared_ptr<QApplication> app, QQmlApplicationEngine* engine)
    {
        this->m_app = app;
        connect(m_app.get(), SIGNAL(aboutToQuit()), this, SLOT(exit_handler()));
        connect(qGuiApp, &QGuiApplication::applicationStateChanged, this, &application::app_state_changed);
        auto& settings_system = system_manager_.get_system<settings_page>();
        settings_system.set_qml_engine(engine);
        settings_system.init_lang();
    }

    QString application::recover_fund(const QString& uuid)
    {
        QString result;

        kdf::recover_funds_of_swap_request request{.swap_uuid = uuid.toStdString()};
        auto                                      res = get_kdf().get_kdf_client().rpc_recover_funds(std::move(request));
        result                                        = QString::fromStdString(res.raw_result);

        return result;
    }
} // namespace atomic_dex

//! Misc QML Utilities
namespace atomic_dex
{
    QString
    application::to_eth_checksum_qt(const QString& eth_lowercase_address)
    {
        auto str = eth_lowercase_address.toStdString();
        utils::to_eth_checksum(str);
        return QString::fromStdString(str);
    }
} // namespace atomic_dex

//! Trading functions
namespace atomic_dex
{
    QString
    application::get_rate_conversion(const QString& fiat, const QString& ticker, bool adjusted)
    {
        const auto&     price_service = system_manager_.get_system<global_price_service>();
        return QString::fromStdString(price_service.get_rate_conversion(fiat.toStdString(), ticker.toStdString(), adjusted));
    }

    QString
    application::get_fiat_rate(const QString& fiat)
    {
        const auto&     price_service = system_manager_.get_system<global_price_service>();
        return QString::fromStdString(price_service.get_fiat_rates(fiat.toStdString()));
    }

    QString
    application::get_fiat_from_amount(const QString& ticker, const QString& amount)
    {
        std::error_code ec;
        const auto&     config        = system_manager_.get_system<settings_page>().get_cfg();
        const auto&     price_service = system_manager_.get_system<global_price_service>();
        return QString::fromStdString(price_service.get_price_as_currency_from_amount(config.current_fiat, ticker.toStdString(), amount.toStdString()));
    }
} // namespace atomic_dex

//! Ticker balance change
namespace atomic_dex
{
    void
    application::on_fiat_rate_updated(const fiat_rate_updated&)
    {
        SPDLOG_DEBUG("on_fiat_rate_updated");
        this->dispatcher_.trigger<update_portfolio_values>();
        this->dispatcher_.trigger<current_currency_changed>();
    }

    void
    application::on_ticker_balance_updated_event(const ticker_balance_updated& evt)
    {
        SPDLOG_DEBUG("Ticker balance is about to be updated.");
        if (m_event_actions[events_action::about_to_exit_app])
        {
            SPDLOG_DEBUG("Ticker balance not updated because app is exiting.");
        }
        else if (evt.tickers.empty())
        {
            SPDLOG_DEBUG("Ticker balance not updated because there are not tickers to update");
        }
        else if (get_portfolio_page()->get_portfolio()->update_balance_values(evt.tickers))
        {
            this->dispatcher_.trigger<update_portfolio_values>(false);
            SPDLOG_DEBUG("Ticker balance updated.");
        }
        else
        {
            SPDLOG_ERROR("Ticker balance not updated, tickers not found in the registry: {}", fmt::join(evt.tickers, ", "));
        }
    }
} // namespace atomic_dex

//! Orders
namespace atomic_dex
{
    /*void
    application::on_process_swaps_finished_event([[maybe_unused]] const process_swaps_finished& evt)
    {
        if (not m_event_actions[events_action::about_to_exit_app])
        {
            this->m_actions_queue.push(action::post_process_swaps_finished);
        }
    }*/

    void
    application::on_process_orders_and_swaps_finished_event([[maybe_unused]] const process_swaps_and_orders_finished& evt)
    {
        if (not m_event_actions[events_action::about_to_exit_app])
        {
            this->m_actions_queue.push(
                evt.after_manual_reset ? action::post_process_orders_and_swaps_finished_reset : action::post_process_orders_and_swaps_finished);
        }
    }

    orders_model*
    application::get_orders() const
    {
        return qobject_cast<orders_model*>(m_manager_models.at("orders"));
    }
} // namespace atomic_dex

//! Portfolio
namespace atomic_dex
{
    portfolio_page*
    application::get_portfolio_page() const
    {
        portfolio_page* ptr = const_cast<portfolio_page*>(std::addressof(system_manager_.get_system<portfolio_page>()));
        assert(ptr != nullptr);
        return ptr;
    }
} // namespace atomic_dex

//! Wallet manager QML API
namespace atomic_dex
{
    bool
    application::is_pin_cfg_enabled() const
    {
        return get_kdf().is_pin_cfg_enabled();
    }
} // namespace atomic_dex

//! Actions implementation
namespace atomic_dex
{
    void
    application::exit_handler()
    {
        SPDLOG_DEBUG("will quit app, prevent all threading event");
        this->system_manager_.mark_system<kdf_service>();
        this->process_one_frame();
        m_event_actions[events_action::about_to_exit_app] = true;
    }

    void
    application::app_state_changed()
    {
        switch (m_app->applicationState())
        {
        case Qt::ApplicationSuspended:
            SPDLOG_INFO("Application suspended");
            break;
        case Qt::ApplicationHidden:
            SPDLOG_INFO("Application hidden");
            break;
        case Qt::ApplicationInactive:
            SPDLOG_INFO("Application inactive");
            break;
        case Qt::ApplicationActive:
            SPDLOG_INFO("Application active");
            break;
        }
    }

} // namespace atomic_dex

//! trading
namespace atomic_dex
{
    trading_page*
    application::get_trading_page() const
    {
        auto ptr = const_cast<trading_page*>(std::addressof(system_manager_.get_system<trading_page>()));
        assert(ptr != nullptr);
        return ptr;
    }
} // namespace atomic_dex

//! wallet
namespace atomic_dex
{
    wallet_page*
    application::get_wallet_page() const
    {
        auto ptr = const_cast<wallet_page*>(std::addressof(system_manager_.get_system<wallet_page>()));
        assert(ptr != nullptr);
        return ptr;
    }
} // namespace atomic_dex

//! Settings
namespace atomic_dex
{
    settings_page*
    application::get_settings_page() const
    {
        auto ptr = const_cast<settings_page*>(std::addressof(system_manager_.get_system<settings_page>()));
        assert(ptr != nullptr);
        return ptr;
    }
} // namespace atomic_dex

//! Addressbook
namespace atomic_dex
{
    addressbook_page*
    application::get_addressbook_page() const
    {
        auto ptr = const_cast<addressbook_page*>(std::addressof(system_manager_.get_system<addressbook_page>()));
        assert(ptr != nullptr);
        return ptr;
    }
} // namespace atomic_dex

//! Notification
namespace atomic_dex
{
    notification_manager*
    application::get_notification_manager() const
    {
        return qobject_cast<notification_manager*>(m_manager_models.at("notifications"));
    }
} // namespace atomic_dex

//! Internet checker
namespace atomic_dex
{
    internet_service_checker*
    application::get_internet_checker() const
    {
        return qobject_cast<internet_service_checker*>(m_manager_models.at("internet_service"));
    }
} // namespace atomic_dex

//! update checker
namespace atomic_dex
{
    update_checker_service* application::get_update_checker_service() const
    {
        auto ptr = const_cast<update_checker_service*>(std::addressof(system_manager_.get_system<update_checker_service>()));
        assert(ptr != nullptr);
        return ptr;
    }
} // namespace atomic_dex

//! time sync checker
namespace atomic_dex
{
    timesync_checker_service* application::get_timesync_checker_service() const
    {
        auto ptr = const_cast<timesync_checker_service*>(std::addressof(system_manager_.get_system<timesync_checker_service>()));
        assert(ptr != nullptr);
        return ptr;
    }
} // namespace atomic_dex

//! zcash_params checker
namespace atomic_dex
{
    zcash_params_service* application::get_zcash_params_service() const
    {
        auto ptr = const_cast<zcash_params_service*>(std::addressof(system_manager_.get_system<zcash_params_service>()));
        assert(ptr != nullptr);
        return ptr;
    }
} // namespace atomic_dex

//! Exporter service
namespace atomic_dex
{
    exporter_service*
    application::get_exporter_service() const
    {
        auto ptr = const_cast<exporter_service*>(std::addressof(system_manager_.get_system<exporter_service>()));
        assert(ptr != nullptr);
        return ptr;
    }
} // namespace atomic_dex

//! Wallet_mgr
namespace atomic_dex
{
    qt_wallet_manager*
    application::get_wallet_mgr() const
    {
        auto ptr = const_cast<qt_wallet_manager*>(std::addressof(system_manager_.get_system<qt_wallet_manager>()));
        assert(ptr != nullptr);
        return ptr;
    }
} // namespace atomic_dex

//! App restart
namespace atomic_dex
{
    void
    application::restart()
    {
        SPDLOG_INFO("restarting the application");
        const char* appimage{nullptr};
        if (appimage = std::getenv("APPIMAGE"); appimage != nullptr)
        {
            SPDLOG_INFO("APPIMAGE path is {}", appimage);
        }

        qApp->quit();

        if (appimage == nullptr || not QString(appimage).contains(DEX_PROJECT_NAME))
        {
            bool res = QProcess::startDetached(qApp->arguments()[0], qApp->arguments(), qApp->applicationDirPath());
            if (!res)
            {
                SPDLOG_ERROR("Couldn't start a new process");
            }
            else
            {
                SPDLOG_INFO("Successfully restarted the app");
            }
        }
        else
        {
            QString path(appimage);
            QProcess::startDetached(path, qApp->arguments());
        }
    }
} // namespace atomic_dex
