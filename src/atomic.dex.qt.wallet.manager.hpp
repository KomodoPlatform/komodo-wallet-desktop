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
#include <QString>
#include <QStringList>

//! Project Headers
#include "atomic.dex.security.hpp"
#include "atomic.dex.version.hpp"

namespace atomic_dex
{
    class qt_wallet_manager
    {
      public:
        template <typename Functor>
        bool inline login(
            const QString& password, const QString& wallet_name, mm2& mm2_system, const QString& default_wallet_name, Functor&& login_if_success_functor);

        static inline QStringList get_wallets() noexcept;

        static inline bool is_there_a_default_wallet() noexcept;

        static inline QString get_default_wallet_name() noexcept;

        static inline bool delete_wallet(const QString& wallet_name) noexcept;

        static inline bool confirm_password(const QString& wallet_name, const QString& password);
    };

    template <typename Functor>
    bool
    qt_wallet_manager::login(
        const QString& password, const QString& wallet_name, mm2& mm2_system, const QString& default_wallet, Functor&& login_if_success_functor)
    {
        std::error_code ec;
        auto            key = atomic_dex::derive_password(password.toStdString(), ec);
        if (ec)
        {
            spdlog::warn("{}", ec.message());
            if (ec == dextop_error::derive_password_failed)
            {
                return false;
            }
        }
        else
        {
            using namespace std::string_literals;

            const std::string wallet_cfg_file = std::string(atomic_dex::get_raw_version()) + "-coins"s + "."s + wallet_name.toStdString() + ".json"s;
            const fs::path    wallet_cfg_path = get_atomic_dex_config_folder() / wallet_cfg_file;


            if (not fs::exists(wallet_cfg_path))
            {
                const auto  cfg_path = ag::core::assets_real_path() / "config";
                std::string filename = std::string(atomic_dex::get_raw_version()) + "-coins.json";
                fs::copy(cfg_path / filename, wallet_cfg_path);
            }

            const fs::path seed_path = get_atomic_dex_config_folder() / (wallet_name.toStdString() + ".seed"s);
            auto           seed      = atomic_dex::decrypt(seed_path, key.data(), ec);
            if (ec == dextop_error::corrupted_file_or_wrong_password)
            {
                spdlog::warn("{}", ec.message());
                return false;
            }

            login_if_success_functor();
            mm2_system.spawn_mm2_instance(default_wallet.toStdString(), seed);
            return true;
        }
        return false;
    }

    QStringList
    qt_wallet_manager::get_wallets() noexcept
    {
        QStringList out;

        for (auto&& p: fs::directory_iterator((get_atomic_dex_config_folder())))
        {
            if (p.path().extension().string() == ".seed")
            {
                out.push_back(QString::fromStdString(p.path().stem().string()));
            }
        }

        return out;
    }

    bool
    qt_wallet_manager::is_there_a_default_wallet() noexcept
    {
        return fs::exists(get_atomic_dex_config_folder() / "default.wallet");
    }

    QString
    qt_wallet_manager::get_default_wallet_name() noexcept
    {
        if (is_there_a_default_wallet())
        {
            std::ifstream ifs((get_atomic_dex_config_folder() / "default.wallet").c_str());
            assert(ifs);
            std::string str((std::istreambuf_iterator<char>(ifs)), std::istreambuf_iterator<char>());
            return QString::fromStdString(str);
        }
        return "nonexistent";
    }

    bool
    qt_wallet_manager::delete_wallet(const QString& wallet_name) noexcept
    {
        using namespace std::string_literals;
        return fs::remove(get_atomic_dex_config_folder() / (wallet_name.toStdString() + ".seed"s));
    }

    bool
    qt_wallet_manager::confirm_password(const QString& wallet_name, const QString& password)
    {
        std::error_code ec;
        auto            key = atomic_dex::derive_password(password.toStdString(), ec);
        if (ec)
        {
            spdlog::debug("{}", ec.message());
            if (ec == dextop_error::derive_password_failed)
            {
                return false;
            }
        }
        using namespace std::string_literals;
        const fs::path seed_path = get_atomic_dex_config_folder() / (wallet_name.toStdString() + ".seed"s);
        auto           seed      = atomic_dex::decrypt(seed_path, key.data(), ec);
        if (ec == dextop_error::corrupted_file_or_wrong_password)
        {
            spdlog::warn("{}", ec.message());
            return false;
        }
        return true;
    }
} // namespace atomic_dex
