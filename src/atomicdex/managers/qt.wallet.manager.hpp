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
#include "atomicdex/config/wallet.cfg.hpp"
#include "atomicdex/services/mm2/mm2.service.hpp"
#include "atomicdex/utilities/security.utilities.hpp"
#include "atomicdex/version/version.hpp"

namespace atomic_dex
{
    class qt_wallet_manager final : public QObject, public ag::ecs::pre_update_system<qt_wallet_manager>
    {
        //! Q_OBJECT Declaration
        Q_OBJECT

        //! Properties
        Q_PROPERTY(QString initial_loading_status READ get_status WRITE set_status NOTIFY onStatusChanged)

        //! Private fields
        ag::ecs::system_manager& m_system_manager;
        wallet_cfg               m_wallet_cfg;
        QString                  m_current_default_wallet{""};
        QString                  m_current_status{"None"};

      signals:
        void onStatusChanged();

      public:
        //! Properties
        QString get_status() const noexcept;
        void    set_status(QString status) noexcept;

        //! Q_INVOKABLE (QML API)
        Q_INVOKABLE bool login(const QString& password, const QString& wallet_name);

        qt_wallet_manager(entt::registry& registry, ag::ecs::system_manager& system_manager, QObject* parent = nullptr);
        QString get_wallet_default_name() const noexcept;
        void    just_set_wallet_name(QString wallet_name);

        void set_wallet_default_name(QString wallet_name) noexcept;

        bool create(const QString& password, const QString& seed, const QString& wallet_name);

        bool load_wallet_cfg(const std::string& wallet_name);

        static QStringList get_wallets() noexcept;

        static bool is_there_a_default_wallet() noexcept;

        static QString get_default_wallet_name() noexcept;

        static bool delete_wallet(const QString& wallet_name) noexcept;

        static bool confirm_password(const QString& wallet_name, const QString& password);
        void        update() noexcept override;

        bool update_wallet_cfg() noexcept;

        std::string                     retrieve_transactions_notes(const std::string& tx_hash) const;
        void                            update_transactions_notes(const std::string& tx_hash, const std::string& notes);
        void                            set_emergency_password(const QString& emergency_password);
        [[nodiscard]] const wallet_cfg& get_wallet_cfg() const noexcept;
        const wallet_cfg&               get_wallet_cfg() noexcept;
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::qt_wallet_manager))
