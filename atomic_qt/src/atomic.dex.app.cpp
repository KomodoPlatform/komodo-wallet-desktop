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

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>

#if defined(_WIN32) || defined(WIN32)
#    define WIN32_LEAN_AND_MEAN
#    define NOMINMAX
#    include <windows.h>

#    include <wincrypt.h>
#endif

#ifdef __APPLE__
#    include "atomic.dex.osx.manager.hpp"
#    include <QGuiApplication>
#    include <QJsonArray>
#    include <QWindow>
#    include <QWindowList>
#endif

//! Project Headers
#include "atomic.dex.app.hpp"
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"
#include "atomic.dex.qt.bindings.hpp"
#include "atomic.dex.security.hpp"
#include "atomic.threadpool.hpp"

namespace
{
#if defined(_WIN32) || defined(WIN32)
    bool
    acquire_context(HCRYPTPROV* ctx)
    {
        if (!CryptAcquireContext(ctx, nullptr, nullptr, PROV_RSA_FULL, 0))
        {
            return CryptAcquireContext(ctx, nullptr, nullptr, PROV_RSA_FULL, CRYPT_NEWKEYSET);
        }
        return true;
    }


    size_t
    sysrandom(void* dst, size_t dstlen)
    {
        HCRYPTPROV ctx;
        if (!acquire_context(&ctx))
        {
            throw std::runtime_error("Unable to initialize Win32 crypt library.");
        }

        BYTE* buffer = reinterpret_cast<BYTE*>(dst);
        if (!CryptGenRandom(ctx, dstlen, buffer))
        {
            throw std::runtime_error("Unable to generate random bytes.");
        }

        if (!CryptReleaseContext(ctx, 0))
        {
            throw std::runtime_error("Unable to release Win32 crypt library.");
        }

        return dstlen;
    }
#endif
} // namespace

namespace atomic_dex
{
    void
    atomic_dex::application::change_state(int visibility)
    {
#ifdef __APPLE__
        qDebug() << visibility;
        {
            QWindowList windows = QGuiApplication::allWindows();
            QWindow*    win     = windows.first();
            atomic_dex::mac_window_setup(win->winId(), visibility == QWindow::FullScreen);
        }
#endif
    }

    QObjectList
    atomic_dex::application::get_enabled_coins() const noexcept
    {
        return m_enabled_coins;
    }

    QObjectList
    atomic_dex::application::get_enableable_coins() const noexcept
    {
        return m_enableable_coins;
    }

    bool
    atomic_dex::application::enable_coins(const QStringList& coins)
    {
        std::vector<std::string> coins_std;
        coins_std.reserve(coins.size());
        for (auto&& coin: coins) { coins_std.push_back(coin.toStdString()); }
        atomic_dex::mm2& mm2 = get_mm2();
        mm2.enable_multiple_coins(coins_std);
        return true;
    }

    bool
    application::disable_coins(const QStringList& coins)
    {
        std::vector<std::string> coins_std;
        coins_std.reserve(coins.size());
        for (auto&& coin: coins) { coins_std.push_back(coin.toStdString()); }
        get_mm2().disable_multiple_coins(coins_std);
        m_coin_info->set_ticker("");
        return false;
    }

    bool
    atomic_dex::application::create(const QString& password, const QString& seed, const QString& wallet_name)
    {
        std::error_code ec;
        auto            key = atomic_dex::derive_password(password.toStdString(), ec);
        if (ec)
        {
            DLOG_F(WARNING, "{}", ec.message());
            if (ec == dextop_error::derive_password_failed)
            {
                return false;
            }
        }
        else
        {
            using namespace std::string_literals;
            const std::filesystem::path seed_path = ag::core::assets_real_path() / ("config/"s + wallet_name.toStdString() + ".seed"s);
            // Encrypt seed
            atomic_dex::encrypt(seed_path, seed.toStdString().data(), key.data());
            // sodium_memzero(&seed, seed.size());
            sodium_memzero(key.data(), key.size());

            std::ofstream ofs((ag::core::assets_real_path() / "config/default.wallet"s).string());
            ofs << wallet_name.toStdString();
            set_wallet_default_name(wallet_name);

            return true;
        }
        return false;
    }

    bool
    atomic_dex::application::login(const QString& password, const QString& wallet_name)
    {
        std::error_code ec;
        auto            key = atomic_dex::derive_password(password.toStdString(), ec);
        if (ec)
        {
            DLOG_F(WARNING, "{}", ec.message());
            if (ec == dextop_error::derive_password_failed)
            {
                return false;
            }
        }
        else
        {
            using namespace std::string_literals;
            const std::filesystem::path seed_path = ag::core::assets_real_path() / ("config/"s + wallet_name.toStdString() + ".seed"s);
            auto                        seed      = atomic_dex::decrypt(seed_path, key.data(), ec);
            if (ec == dextop_error::corrupted_file_or_wrong_password)
            {
                LOG_F(WARNING, "{}", ec.message());
                return false;
            }
            else
            {
                this->set_status("initializing_mm2");
                get_mm2().spawn_mm2_instance(seed);
                return true;
            }
        }
        return false;
    }

    bool
    atomic_dex::application::first_run()
    {
        return get_wallets().empty();
    }

    void
    application::launch()
    {
        this->system_manager_.start();
        auto timer = new QTimer(this);
        connect(timer, &QTimer::timeout, this, &application::tick);
        timer->start(8);
    }

    QString
    atomic_dex::application::get_mnemonic()
    {
#ifdef __APPLE__
        bc::data_chunk my_entropy_256(32); // 32 bytes = 256 bits

        bc::pseudo_random_fill(my_entropy_256);

        // Instantiate mnemonic word_list
        bc::wallet::word_list words = bc::wallet::create_mnemonic(my_entropy_256);
        return QString::fromStdString(bc::join(words));
#elif defined(_WIN32) || defined(WIN32)
        std::array<unsigned char, WALLY_SECP_RANDOMIZE_LEN> data;
        sysrandom(data.data(), data.size());
        char*  output;
        words* output_words;
        assert(WALLY_OK == bip39_get_wordlist(NULL, &output_words));
        assert(WALLY_OK == bip39_mnemonic_from_bytes(output_words, data.data(), data.size(), &output));
        assert(WALLY_OK == bip39_mnemonic_validate(output_words, output));
        return output;
#else
        return QString("FAKE LINUX WINDOWS SEED");
#endif
    }

    void
    application::tick()
    {
        this->process_one_frame();
        if (this->m_need_a_full_refresh_of_mm2)
        {
            auto& mm2_s = system_manager_.create_system<mm2>();
            system_manager_.create_system<coinpaprika_provider>(mm2_s);

            connect_signals();
            this->m_need_a_full_refresh_of_mm2 = false;
        }
        auto& mm2     = get_mm2();
        auto& paprika = get_paprika();
        if (mm2.is_mm2_running())
        {
            if (m_coin_info->get_ticker().isEmpty() && not m_enabled_coins.empty())
            {
                auto coin = mm2.get_enabled_coins().front();
                m_coin_info->set_ticker(QString::fromStdString(coin.ticker));
                emit coinInfoChanged();
            }

            if (m_refresh_enabled_coin_event)
            {
                auto refresh_coin = [this](auto&& coins_container, auto&& coins_list) {
                    coins_list.clear();
                    coins_list = to_qt_binding(std::move(coins_container), this);
                };

                {
                    auto coins = mm2.get_enabled_coins();
                    refresh_coin(coins, m_enabled_coins);
                    emit enabledCoinsChanged();
                }
                {
                    auto coins = mm2.get_enableable_coins();
                    refresh_coin(coins, m_enableable_coins);
                    emit enableableCoinsChanged();
                }
                {
                    if (not m_coin_info->get_ticker().isEmpty())
                    {
                        refresh_transactions(mm2);
                    }
                }
                m_refresh_enabled_coin_event = false;
            }

            if (m_refresh_current_ticker_infos)
            {
                refresh_transactions(mm2);
                refresh_fiat_balance(mm2, paprika);
                refresh_address(mm2);
                const auto& info = get_mm2().get_coin_info(m_coin_info->get_ticker().toStdString());
                m_coin_info->set_claimable(info.is_claimable);
                m_coin_info->set_minimal_balance_for_asking_rewards(QString::fromStdString(info.minimal_claim_amount));
                m_coin_info->set_explorer_url(QString::fromStdString(info.explorer_url[0]));
                m_refresh_current_ticker_infos = false;
            }

            if (m_refresh_orders_needed)
            {
                emit myOrdersUpdated();
                m_refresh_orders_needed = false;
            }

            if (m_refresh_transaction_only)
            {
                DLOG_F(INFO, "{}", "refreshing transactions");
                refresh_transactions(mm2);
                m_refresh_transaction_only = false;
            }

            std::error_code ec;
            auto            fiat_balance_std = paprika.get_price_in_fiat_all(m_current_fiat.toStdString(), ec);
            if (!ec)
            {
                this->set_current_balance_fiat_all(QString::fromStdString(fiat_balance_std));
            }

            if (not m_coin_info->get_ticker().isEmpty() && not m_enabled_coins.empty())
            {
                refresh_fiat_balance(mm2, paprika);
                refresh_address(mm2);
            }
        }
    }

    void
    application::refresh_fiat_balance(const mm2& mm2, const coinpaprika_provider& paprika)
    {
        std::error_code ec;
        QString         target_balance = QString::fromStdString(mm2.my_balance(m_coin_info->get_ticker().toStdString(), ec));
        m_coin_info->set_balance(target_balance);

        if (m_current_fiat == "USD" || m_current_fiat == "EUR")
        {
            ec          = std::error_code();
            auto amount = QString::fromStdString(paprika.get_price_in_fiat(m_current_fiat.toStdString(), m_coin_info->get_ticker().toStdString(), ec));
            if (!ec)
            {
                m_coin_info->set_fiat_amount(amount);
            }
        }
    }

    void
    application::refresh_transactions(const mm2& mm2)
    {
        LOG_SCOPE_FUNCTION(INFO);
        std::error_code ec;
        auto            txs = mm2.get_tx_history(m_coin_info->get_ticker().toStdString(), ec);
        if (!ec)
        {
            m_coin_info->set_transactions(to_qt_binding(std::move(txs), this, get_paprika(), m_current_fiat, m_coin_info->get_ticker().toStdString()));
        }
        auto tx_state = mm2.get_tx_state(m_coin_info->get_ticker().toStdString(), ec);

        if (!ec)
        {
            m_coin_info->set_tx_state(QString::fromStdString(tx_state.state));
            m_coin_info->set_tx_current_block(tx_state.current_block);
        }
    }

    mm2&
    application::get_mm2() noexcept
    {
        return this->system_manager_.get_system<mm2>();
    }

    coinpaprika_provider&
    application::get_paprika() noexcept
    {
        return this->system_manager_.get_system<coinpaprika_provider>();
    }

    entt::dispatcher&
    application::get_dispatcher() noexcept
    {
        return this->dispatcher_;
    }

    QObject*
    atomic_dex::application::get_current_coin_info() const noexcept
    {
        return m_coin_info;
    }

    QString
    atomic_dex::application::get_balance_fiat_all() const noexcept
    {
        return m_current_balance_all;
    }

    void
    atomic_dex::application::set_current_balance_fiat_all(QString current_fiat_all_balance) noexcept
    {
        this->m_current_balance_all = std::move(current_fiat_all_balance);
        emit on_fiat_balance_all_changed();
    }

    application::application(QObject* pParent) noexcept : QObject(pParent), m_coin_info(new current_coin_info(dispatcher_, this))
    {
        //! MM2 system need to be created before the GUI and give the instance to the gui
        auto& mm2_system = system_manager_.create_system<mm2>();
        system_manager_.create_system<coinpaprika_provider>(mm2_system);

        connect_signals();
        if (is_there_a_default_wallet())
        {
            set_wallet_default_name(get_default_wallet_name());
        }
    }

    void
    atomic_dex::application::cancel_order(const QString& order_id)
    {
        auto& mm2 = get_mm2();
        atomic_dex::spawn([&mm2, order_id, this]() {
            ::mm2::api::rpc_cancel_order({order_id.toStdString()});
            mm2.fetch_infos_thread();
            this->get_dispatcher().trigger<refresh_order_needed>();
        });
    }

    void
    atomic_dex::application::cancel_all_orders()
    {
        auto& mm2 = get_mm2();
        atomic_dex::spawn([&mm2, this]() {
            ::mm2::api::cancel_all_orders_request req;
            ::mm2::api::rpc_cancel_all_orders(std::move(req));
            mm2.process_orders();
            this->get_dispatcher().trigger<refresh_order_needed>();
        });
    }

    void
    application::cancel_all_orders_by_ticker(const QString& ticker)
    {
        auto& mm2 = get_mm2();
        atomic_dex::spawn([&mm2, &ticker, this]() {
            ::mm2::api::cancel_data cd;
            cd.ticker = ticker.toStdString();
            ::mm2::api::cancel_all_orders_request req{{"Coin", cd}};
            ::mm2::api::rpc_cancel_all_orders(std::move(req));
            mm2.process_orders();
            this->get_dispatcher().trigger<refresh_order_needed>();
        });
    }

    void
    atomic_dex::application::on_enabled_coins_event(const enabled_coins_event&) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        m_refresh_enabled_coin_event = true;
    }

    QString
    application::get_current_fiat() const noexcept
    {
        return this->m_current_fiat;
    }

    void
    application::set_current_fiat(QString current_fiat) noexcept
    {
        this->m_current_fiat = std::move(current_fiat);
        emit on_fiat_changed();
    }

    void
    application::on_change_ticker_event(const change_ticker_event&) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        m_refresh_current_ticker_infos = true;
    }

    void
    application::refresh_address(mm2& mm2)
    {
        std::error_code ec;
        auto            address = QString::fromStdString(mm2.address(m_coin_info->get_ticker().toStdString(), ec));
        this->m_coin_info->set_address(address);
    }

    QObject*
    application::prepare_send(const QString& address, const QString& amount, bool max)
    {
        atomic_dex::t_withdraw_request req{
            .to = address.toStdString(), .coin = m_coin_info->get_ticker().toStdString(), .max = max, .amount = amount.toStdString()};
        std::error_code ec;
        auto            answer = mm2::withdraw(std::move(req), ec);
        auto            coin   = get_mm2().get_coin_info(m_coin_info->get_ticker().toStdString());
        return to_qt_binding(std::move(answer), this, QString::fromStdString(coin.explorer_url[0]));
    }

    bool
    atomic_dex::application::is_claiming_ready(const QString& ticker)
    {
        return get_mm2().is_claiming_ready(ticker.toStdString());
    }

    QObject*
    atomic_dex::application::claim_rewards(const QString& ticker)
    {
        std::error_code ec;
        auto            answer = get_mm2().claim_rewards(ticker.toStdString(), ec);
        if (not answer.error.has_value())
        {
            if (ec)
            {
                answer.error = ec.message();
            }
        }
        auto coin = get_mm2().get_coin_info(m_coin_info->get_ticker().toStdString());
        auto obj  = to_qt_binding(std::move(answer), this, QString::fromStdString(coin.explorer_url[0]));
        return obj;
    }

    QString
    application::send(const QString& tx_hex)
    {
        atomic_dex::t_broadcast_request req{.tx_hex = tx_hex.toStdString(), .coin = m_coin_info->get_ticker().toStdString()};
        std::error_code                 ec;
        auto                            answer = mm2::broadcast(std::move(req), ec);
        m_refresh_current_ticker_infos         = true;
        refresh_infos();
        return QString::fromStdString(answer.tx_hash);
    }

    QString
    application::send_rewards(const QString& tx_hex)
    {
        atomic_dex::t_broadcast_request req{.tx_hex = tx_hex.toStdString(), .coin = m_coin_info->get_ticker().toStdString()};
        std::error_code                 ec;
        auto                            answer = get_mm2().send_rewards(std::move(req), ec);
        m_refresh_current_ticker_infos         = true;
        refresh_infos();
        return QString::fromStdString(answer.tx_hash);
    }

    void
    application::on_tx_fetch_finished_event(const tx_fetch_finished&) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        m_refresh_transaction_only = true;
    }

    bool
    application::place_buy_order(const QString& base, const QString& rel, const QString& price, const QString& volume)
    {
        t_float_50 price_f;
        t_float_50 amount_f;
        t_float_50 total_amount;

        price_f.assign(price.toStdString());
        amount_f.assign(volume.toStdString());
        total_amount = price_f * amount_f;

        t_buy_request   req{.base = base.toStdString(), .rel = rel.toStdString(), .price = price.toStdString(), .volume = volume.toStdString()};
        std::error_code ec;
        auto            answer = get_mm2().place_buy_order(std::move(req), total_amount, ec);

        return !answer.error.has_value();
    }

    bool
    application::place_sell_order(const QString& base, const QString& rel, const QString& price, const QString& volume)
    {
        t_float_50 amount_f;
        amount_f.assign(volume.toStdString());

        t_sell_request  req{.base = base.toStdString(), .rel = rel.toStdString(), .price = price.toStdString(), .volume = volume.toStdString()};
        std::error_code ec;
        auto            answer = get_mm2().place_sell_order(std::move(req), amount_f, ec);

        return !answer.error.has_value();
    }

    bool
    application::do_i_have_enough_funds(const QString& ticker, const QString& amount) const
    {
        t_float_50 amount_f(amount.toStdString());
        return get_mm2().do_i_have_enough_funds(ticker.toStdString(), amount_f);
    }

    const mm2&
    application::get_mm2() const noexcept
    {
        return this->system_manager_.get_system<mm2>();
    }

    void
    application::on_coin_disabled_event(const coin_disabled&) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        m_refresh_enabled_coin_event = true;
    }

    QString
    application::get_balance(const QString& coin)
    {
        std::error_code ec;
        auto            res = get_mm2().my_balance(coin.toStdString(), ec);
        return QString::fromStdString(res);
    }

    void
    application::on_gui_enter_dex()
    {
        this->dispatcher_.trigger<gui_enter_trading>();
    }

    void
    application::on_gui_leave_dex()
    {
        this->dispatcher_.trigger<gui_leave_trading>();
    }

    QString
    application::get_status() const noexcept
    {
        return m_current_status;
    }

    void
    application::set_status(QString status) noexcept
    {
        this->m_current_status = std::move(status);
        emit on_status_changed();
    }

    void
    application::on_mm2_initialized_event(const mm2_initialized&) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        this->set_status("enabling_coins");
    }

    void
    application::on_mm2_started_event(const mm2_started&) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        this->set_status("complete");
    }

    void
    application::set_current_orderbook(const QString& base)
    {
        this->dispatcher_.trigger<orderbook_refresh>(base.toStdString());
    }

    QVariantMap
    application::get_orderbook(const QString& ticker)
    {
        QVariantMap     out;
        std::error_code ec;
        auto            answer = get_mm2().get_orderbook(ticker.toStdString(), ec);
        if (ec == dextop_error::orderbook_ticker_not_found)
        {
            LOG_F(WARNING, "{}", ec.message());
            return out;
        }
        for (auto&& current_orderbook: answer)
        {
            nlohmann::json j_out = nlohmann::json::array();
            for (auto&& current_bid: current_orderbook.bids)
            {
                nlohmann::json current_j_bid = {{"volume", current_bid.maxvolume}, {"price", current_bid.price}};
                j_out.push_back(current_j_bid);
            }
            auto out_orderbook = QJsonDocument::fromJson(QString::fromStdString(j_out.dump()).toUtf8());
            out.insert(QString::fromStdString(current_orderbook.rel), out_orderbook.toVariant());
        }
        return out;
    }

    QVariantMap
    application::get_my_orders()
    {
        auto&       mm2 = get_mm2();
        QVariantMap output;
        auto        coins = mm2.get_enabled_coins();
        for (auto&& coin: coins)
        {
            std::error_code ec;
            output.insert(QString::fromStdString(coin.ticker), QVariant::fromValue(to_qt_binding(mm2.get_orders(coin.ticker, ec), this)));
        }
        return output;
    }

    void
    application::on_refresh_order_event(const refresh_order_needed&) noexcept
    {
        LOG_SCOPE_FUNCTION(INFO);
        this->m_refresh_orders_needed = true;
    }

    QVariantMap
    application::get_recent_swaps()
    {
        QVariantMap out;
        auto        swaps = get_mm2().get_swaps();

        for (auto& swap: swaps.swaps)
        {
            nlohmann::json j2 = {{"maker_coin", swap.maker_coin},
                                 {"taker_coin", swap.taker_coin},
                                 {"is_recoverable", swap.funds_recoverable},
                                 {"maker_amount", swap.maker_amount},
                                 {"taker_amount", swap.taker_amount},
                                 {"error_events", swap.error_events},
                                 {"success_events", swap.success_events},
                                 {"type", swap.type},
                                 {"events", swap.events},
                                 {"my_info", swap.my_info}};

            auto out_swap = QJsonDocument::fromJson(QString::fromStdString(j2.dump()).toUtf8());
            out.insert(QString::fromStdString(swap.uuid), out_swap.toVariant());
        }
        return out;
    }

    void
    application::refresh_infos()
    {
        auto& mm2 = get_mm2();
        spawn([&mm2, &dispatcher = dispatcher_]() {
            mm2.fetch_infos_thread();
            dispatcher.trigger<refresh_order_needed>();
        });
    }

    void
    application::refresh_orders_and_swaps()
    {
        auto& mm2 = get_mm2();
        spawn([&mm2, &dispatcher = dispatcher_]() {
            mm2.process_swaps();
            mm2.process_orders();
            dispatcher.trigger<refresh_order_needed>();
        });
    }

    QObject*
    application::get_coin_info(const QString& ticker)
    {
        return to_qt_binding(get_mm2().get_coin_info(ticker.toStdString()), this);
    }

    QStringList
    application::get_wallets() const
    {
        QStringList out;
        for (auto&& p: std::filesystem::directory_iterator(ag::core::assets_real_path() / "config"))
        {
            if (p.path().extension().string() == ".seed")
            {
                out.push_back(QString::fromStdString(p.path().stem().string()));
            }
        }
        return out;
    }

    bool
    application::is_there_a_default_wallet() const
    {
        return fs::exists(ag::core::assets_real_path() / "config/default.wallet");
    }

    QString
    application::get_default_wallet_name() const
    {
        if (is_there_a_default_wallet())
        {
            std::ifstream ifs(ag::core::assets_real_path() / "config/default.wallet");
            assert(ifs);
            std::string str((std::istreambuf_iterator<char>(ifs)), std::istreambuf_iterator<char>());
            return QString::fromStdString(str);
        }
        return "nonexistent";
    }

    bool
    application::disconnect()
    {
        system_manager_.mark_system<mm2>();
        system_manager_.mark_system<coinpaprika_provider>();
        get_dispatcher().sink<change_ticker_event>().disconnect<&application::on_change_ticker_event>(*this);
        get_dispatcher().sink<enabled_coins_event>().disconnect<&application::on_enabled_coins_event>(*this);
        get_dispatcher().sink<tx_fetch_finished>().disconnect<&application::on_tx_fetch_finished_event>(*this);
        get_dispatcher().sink<coin_disabled>().disconnect<&application::on_coin_disabled_event>(*this);
        get_dispatcher().sink<mm2_initialized>().disconnect<&application::on_mm2_initialized_event>(*this);
        get_dispatcher().sink<mm2_started>().disconnect<&application::on_mm2_started_event>(*this);
        get_dispatcher().sink<refresh_order_needed>().disconnect<&application::on_refresh_order_event>(*this);

        this->m_need_a_full_refresh_of_mm2 = true;

        return fs::remove(ag::core::assets_real_path() / "config/default.wallet");
    }

    bool
    application::delete_wallet(const QString& wallet_name) const
    {
        using namespace std::string_literals;
        return fs::remove(ag::core::assets_real_path() / ("config/"s + wallet_name.toStdString() + ".seed"s));
    }

    void
    application::connect_signals()
    {
        LOG_SCOPE_FUNCTION(INFO);
        get_dispatcher().sink<change_ticker_event>().connect<&application::on_change_ticker_event>(*this);
        get_dispatcher().sink<enabled_coins_event>().connect<&application::on_enabled_coins_event>(*this);
        get_dispatcher().sink<tx_fetch_finished>().connect<&application::on_tx_fetch_finished_event>(*this);
        get_dispatcher().sink<coin_disabled>().connect<&application::on_coin_disabled_event>(*this);
        get_dispatcher().sink<mm2_initialized>().connect<&application::on_mm2_initialized_event>(*this);
        get_dispatcher().sink<mm2_started>().connect<&application::on_mm2_started_event>(*this);
        get_dispatcher().sink<refresh_order_needed>().connect<&application::on_refresh_order_event>(*this);
    }

    QString
    application::get_wallet_default_name() const noexcept
    {
        return m_current_default_wallet;
    }

    void
    application::set_wallet_default_name(QString wallet_name) noexcept
    {
        using namespace std::string_literals;
        if (wallet_name == "")
        {
            fs::remove(ag::core::assets_real_path() / "config/default.wallet");
            return;
        }
        if (not fs::exists(ag::core::assets_real_path() / "config/default.wallet"s))
        {
            std::ofstream ofs((ag::core::assets_real_path() / "config/default.wallet"s).string());
            ofs << wallet_name.toStdString();
        }
        else
        {
            std::ofstream ofs((ag::core::assets_real_path() / "config/default.wallet"s).string(), std::ios_base::out | std::ios_base::trunc);
            ofs << wallet_name.toStdString();
        }

        this->m_current_default_wallet = std::move(wallet_name);
        emit on_wallet_default_name_changed();
    }

    QString
    atomic_dex::application::get_regex_password_policy() const noexcept
    {
        return QString(::atomic_dex::get_regex_password_policy());
    }

    QVariantMap
    application::get_trade_infos(const QString& ticker, const QString& receive_ticker, const QString& amount)
    {
        QVariantMap out;
        auto        trade_fee_f = get_mm2().get_trade_fee(ticker.toStdString(), amount.toStdString(), false);
        auto        answer      = get_mm2().get_trade_fixed_fee(ticker.toStdString());
        t_float_50  tx_fee_f    = t_float_50(answer.amount) * 2;
        if (receive_ticker != "")
        {
            get_mm2().apply_erc_fees(receive_ticker.toStdString(), tx_fee_f);
        }
        auto tx_fee_value     = QString::fromStdString(get_formated_float(tx_fee_f));
        auto final_balance    = get_formated_float(t_float_50(amount.toStdString()) - (trade_fee_f + tx_fee_f));
        auto final_balance_qt = QString::fromStdString(final_balance);

        out.insert("trade_fee", QString::fromStdString(get_mm2().get_trade_fee_str(ticker.toStdString(), amount.toStdString(), false)));
        out.insert("tx_fee", tx_fee_value);
        out.insert("is_ticker_of_fees_eth", get_mm2().get_coin_info(ticker.toStdString()).is_erc_20);
        out.insert("input_final_value", final_balance_qt);
        return out;
    }
} // namespace atomic_dex
