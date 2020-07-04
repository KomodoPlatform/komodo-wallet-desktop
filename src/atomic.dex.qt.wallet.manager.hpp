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

//! Project Headers
#include "atomic.dex.security.hpp"
#include "atomic.dex.version.hpp"
#include "atomic.dex.wallet.config.hpp"

namespace atomic_dex
{
    class qt_wallet_manager
    {
      public:
        template <typename Functor>
        bool inline login(
            const QString& password, const QString& wallet_name, mm2& mm2_system, const QString& default_wallet_name, Functor&& login_if_success_functor);

        inline bool load_wallet_cfg(const std::string& wallet_name);

        inline QStringList get_categories_list() const noexcept;

        inline QVariantMap get_address_from(const std::string& contact_name) const noexcept;

        inline bool add_category(const std::string& category_name, bool with_update_file) noexcept;

        static inline QStringList get_wallets() noexcept;

        static inline bool is_there_a_default_wallet() noexcept;

        static inline QString get_default_wallet_name() noexcept;

        static inline bool delete_wallet(const QString& wallet_name) noexcept;

        static inline bool confirm_password(const QString& wallet_name, const QString& password);

      private:
        inline bool update_wallet_cfg() noexcept;
        wallet_cfg  m_wallet_cfg;
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
            load_wallet_cfg(default_wallet.toStdString());
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

    bool
    qt_wallet_manager::load_wallet_cfg(const std::string& wallet_name)
    {
        using namespace std::string_literals;
        const fs::path wallet_object_path = get_atomic_dex_export_folder() / (wallet_name + ".wallet.json"s);
        std::ifstream  ifs(wallet_object_path.string());

        if (not ifs.is_open())
        {
            return false;
        }
        nlohmann::json j;
        ifs >> j;
        m_wallet_cfg = j;
        return true;
    }

    QStringList
    qt_wallet_manager::get_categories_list() const noexcept
    {
        QStringList out;

        out.reserve(m_wallet_cfg.categories_addressbook_registry.size());
        for (const auto& [key, _]: m_wallet_cfg.categories_addressbook_registry)
        {
            (void)_;
            out.push_back(QString::fromStdString(key));
        }
        return out;
    }

    QVariantMap
    qt_wallet_manager::get_address_from(const std::string& contact_name) const noexcept
    {
        QVariantMap out;

        if (m_wallet_cfg.addressbook_registry.find(contact_name) != m_wallet_cfg.addressbook_registry.cend())
        {
            for (auto&& [key, value]: m_wallet_cfg.addressbook_registry.at(contact_name))
            { out.insert(QString::fromStdString(key), QVariant(QString::fromStdString(value))); }
        }
        return out;
    }

    bool
    qt_wallet_manager::update_wallet_cfg() noexcept
    {
        using namespace std::string_literals;
        const fs::path wallet_object_path = get_atomic_dex_export_folder() / (m_wallet_cfg.name + ".wallet.json"s);
        std::ofstream  ofs(wallet_object_path.string(), std::ios::trunc);
        if (not ofs.is_open())
        {
            return false;
        }

        nlohmann::json j;
        atomic_dex::to_json(j, m_wallet_cfg);
        ofs << j.dump(4);
        return true;
    }

    bool
    qt_wallet_manager::add_category(const std::string& category_name, bool with_update_file) noexcept
    {
        if (m_wallet_cfg.categories_addressbook_registry.find(category_name) == m_wallet_cfg.categories_addressbook_registry.cend())
        {
            m_wallet_cfg.categories_addressbook_registry[category_name] = {};
            return with_update_file ? update_wallet_cfg() : true;
        }
        return false;
    }
} // namespace atomic_dex
