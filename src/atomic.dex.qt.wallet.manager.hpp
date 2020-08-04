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
#include <QVariantMap>
#include <QVector>

//! Project Headers
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.qt.addressbook.contact.contents.hpp"
#include "atomic.dex.security.hpp"
#include "atomic.dex.version.hpp"
#include "atomic.dex.wallet.config.hpp"

namespace atomic_dex
{
    class qt_wallet_manager
    {
      public:
        QString get_wallet_default_name() const noexcept;
        void just_set_wallet_name(QString wallet_name);

        void set_wallet_default_name(QString wallet_name) noexcept;

        template <typename Functor>
        bool login(const QString& password, const QString& wallet_name, mm2& mm2_system, Functor&& login_if_success_functor);

        bool create(const QString& password, const QString& seed, const QString& wallet_name);

        bool load_wallet_cfg(const std::string& wallet_name);

        static QStringList get_wallets() noexcept;

        static bool is_there_a_default_wallet() noexcept;

        static QString get_default_wallet_name() noexcept;

        static bool delete_wallet(const QString& wallet_name) noexcept;

        static bool confirm_password(const QString& wallet_name, const QString& password);

        bool update_wallet_cfg() noexcept;

        void update_contact_ticker(const QString& contact_name, const QString& old_ticker, const QString& new_ticker);
        void update_contact_address(const QString& contact_name, const QString& ticker, const QString& address);
        void update_or_insert_contact_name(const QString& old_contact_name, const QString& contact_name);
        void remove_address_entry(const QString& contact_name, const QString& ticker);
        void delete_contact(const QString& contact_name);
        const wallet_cfg& get_wallet_cfg() const noexcept;
        const wallet_cfg& get_wallet_cfg() noexcept;
      private:
        wallet_cfg m_wallet_cfg;
        QString    m_current_default_wallet{""};
    };

    template <typename Functor>
    bool
    qt_wallet_manager::login(const QString& password, const QString& wallet_name, mm2& mm2_system, Functor&& login_if_success_functor)
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
            load_wallet_cfg(get_default_wallet_name().toStdString());
            mm2_system.spawn_mm2_instance(get_default_wallet_name().toStdString(), seed);
            return true;
        }
        return false;
    }
} // namespace atomic_dex
