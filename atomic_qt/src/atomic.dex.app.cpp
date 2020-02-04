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
#    include <QWindow>
#    include <QWindowList>
#endif

//! Project Headers
#include "atomic.dex.app.hpp"
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"
#include "atomic.dex.qt.bindings.hpp"
#include "atomic.dex.security.hpp"

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

    QString
    atomic_dex::current_coin_info::get_balance() const noexcept
    {
        return selected_coin_balance;
    }

    void
    atomic_dex::current_coin_info::set_balance(QString balance) noexcept
    {
        this->selected_coin_balance = std::move(balance);
        emit balance_changed();
    }

    QString
    atomic_dex::current_coin_info::get_ticker() const noexcept
    {
        return selected_coin_name;
    }

    void
    atomic_dex::current_coin_info::set_ticker(QString ticker) noexcept
    {
        selected_coin_name = std::move(ticker);
        this->m_dispatcher.trigger<change_ticker_event>();
        emit ticker_changed();
    }

    QString
    atomic_dex::current_coin_info::get_explorer_url() const noexcept
    {
        return selected_coin_url;
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
    atomic_dex::application::create(const QString& password, const QString& seed)
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
            const std::filesystem::path seed_path = ag::core::assets_real_path() / "config/encrypted.seed";
            // Encrypt seed
            atomic_dex::encrypt(seed_path, seed.toStdString().data(), key.data());
            // sodium_memzero(&seed, seed.size());
            sodium_memzero(key.data(), key.size());

            return true;
        }
        return false;
    }

    bool
    atomic_dex::application::login(const QString& password)
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
            const std::filesystem::path seed_path = ag::core::assets_real_path() / "config/encrypted.seed";
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
        return not fs::exists(ag::core::assets_real_path() / "config/encrypted.seed");
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
                m_coin_info->set_explorer_url(QString::fromStdString(get_mm2().get_coin_info(m_coin_info->get_ticker().toStdString()).explorer_url[0]));
                m_refresh_current_ticker_infos = false;
            }

            if (m_refresh_transaction_only)
            {
                DLOG_F(INFO, "{}", "refreshing transactions");
                refresh_transactions(mm2);
                m_refresh_transaction_only = false;
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
        std::error_code ec;
        auto            txs = mm2.get_tx_history(m_coin_info->get_ticker().toStdString(), ec);
        if (!ec)
        {
            m_coin_info->set_transactions(to_qt_binding(std::move(txs), this, get_paprika(), m_current_fiat, m_coin_info->get_ticker().toStdString()));
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

    atomic_dex::current_coin_info::current_coin_info(entt::dispatcher& dispatcher, QObject* pParent) noexcept : QObject(pParent), m_dispatcher(dispatcher) {}

    QString
    current_coin_info::get_fiat_amount() const noexcept
    {
        return this->selected_coin_fiat_amount;
    }

    void
    current_coin_info::set_fiat_amount(QString fiat_amount) noexcept
    {
        this->selected_coin_fiat_amount = std::move(fiat_amount);
        emit fiat_amount_changed();
    }
    QObjectList
    current_coin_info::get_transactions() const noexcept
    {
        return this->selected_coin_transactions;
    }

    void
    current_coin_info::set_transactions(QObjectList transactions) noexcept
    {
        this->selected_coin_transactions.clear();
        this->selected_coin_transactions = std::move(transactions);
        emit transactionsChanged();
    }
    QString
    current_coin_info::get_address() const noexcept
    {
        return selected_coin_address;
    }

    void
    current_coin_info::set_address(QString address) noexcept
    {
        this->selected_coin_address = std::move(address);
        emit address_changed();
    }

    void
    current_coin_info::set_explorer_url(QString url) noexcept
    {
        this->selected_coin_url = std::move(url);
        emit explorer_url_changed();
    }

    application::application(QObject* pParent) noexcept : QObject(pParent), m_coin_info(new current_coin_info(dispatcher_, this))
    {
        //! MM2 system need to be created before the GUI and give the instance to the gui
        auto& mm2_system = system_manager_.create_system<mm2>();
        system_manager_.create_system<coinpaprika_provider>(mm2_system);

        get_dispatcher().sink<change_ticker_event>().connect<&application::on_change_ticker_event>(*this);
        get_dispatcher().sink<enabled_coins_event>().connect<&application::on_enabled_coins_event>(*this);
        get_dispatcher().sink<tx_fetch_finished>().connect<&application::on_tx_fetch_finished_event>(*this);
        get_dispatcher().sink<coin_disabled>().connect<&application::on_coin_disabled_event>(*this);
        get_dispatcher().sink<mm2_initialized>().connect<&application::on_mm2_initialized_event>(*this);
        get_dispatcher().sink<mm2_started>().connect<&application::on_mm2_started_event>(*this);
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

    QString
    application::send(const QString& tx_hex)
    {
        atomic_dex::t_broadcast_request req{.tx_hex = tx_hex.toStdString(), .coin = m_coin_info->get_ticker().toStdString()};
        std::error_code                 ec;
        auto                            answer = mm2::broadcast(std::move(req), ec);
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
    application::set_current_orderbook(const QString& base, const QString& rel)
    {
        this->dispatcher_.trigger<orderbook_refresh>(base.toStdString(), rel.toStdString());
    }

    QObject*
    application::get_orderbook()
    {
        std::error_code ec;
        auto            answer = get_mm2().get_current_orderbook(ec);
        return to_qt_binding(std::move(answer), this);
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
} // namespace atomic_dex
