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
        emit ticker_changed();
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
        auto timer = new QTimer(this);
        connect(timer, &QTimer::timeout, this, &application::tick);
        timer->start(8);
    }

    QString
    atomic_dex::application::get_mnemonic()
    {
        bc::data_chunk my_entropy_256(32); // 32 bytes = 256 bits

        bc::pseudo_random_fill(my_entropy_256);

        // Instantiate mnemonic word_list
        bc::wallet::word_list words = bc::wallet::create_mnemonic(my_entropy_256);
        return QString::fromStdString(bc::join(words));
    }

    void
    application::tick()
    {
        this->process_one_frame();
        auto& mm2 = get_mm2();
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
                {
                    auto coins = mm2.get_enabled_coins();
                    this->m_enabled_coins.clear();
                    this->m_enabled_coins = to_qt_binding(std::move(coins), this);
                    emit enabledCoinsChanged();
                }
                {
                    auto coins = mm2.get_enableable_coins();
                    this->m_enableable_coins.clear();
                    this->m_enableable_coins = to_qt_binding(std::move(coins), this);
                    emit enableableCoinsChanged();
                }
                m_refresh_enabled_coin_event = false;
            }

            if (not m_coin_info->get_ticker().isEmpty() && not m_enabled_coins.empty())
            {
                std::error_code ec;
                QString target_balance = QString::fromStdString(mm2.my_balance(this->m_coin_info->get_ticker().toStdString(), ec));
                this->m_coin_info->set_balance(target_balance);
            }
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

    atomic_dex::current_coin_info::current_coin_info(QObject* pParent) noexcept : QObject(pParent) {}

    application::application(QObject* pParent) noexcept : QObject(pParent), m_coin_info(new current_coin_info(this))
    {
        //! MM2 system need to be created before the GUI and give the instance to the gui
        auto& mm2_system = system_manager_.create_system<mm2>();
        system_manager_.create_system<coinpaprika_provider>(mm2_system);

        get_dispatcher().sink<enabled_coins_event>().connect<&application::on_enabled_coins_event>(*this);
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
} // namespace atomic_dex
