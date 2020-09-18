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

//! QT
#include <QApplication>
#include <QObject>
#include <QString>
#include <QTranslator>

//! Project headers
#include "atomic.dex.cfg.hpp"

namespace atomic_dex
{
    class settings_page final : public QObject, public ag::ecs::pre_update_system<settings_page>
    {
        //! Q_Object definition
        Q_OBJECT

        //! Properties
        Q_PROPERTY(QString lang READ get_current_lang WRITE set_current_lang NOTIFY onLangChanged)
        Q_PROPERTY(QString empty_string READ get_empty_string NOTIFY langChanged)
        Q_PROPERTY(QString current_currency READ get_current_currency WRITE set_current_currency NOTIFY onCurrencyChanged)
        Q_PROPERTY(QString current_currency_sign READ get_current_currency_sign NOTIFY onCurrencySignChanged)
        Q_PROPERTY(QString current_fiat_sign READ get_current_fiat_sign NOTIFY onFiatSignChanged)
        Q_PROPERTY(QString current_fiat READ get_current_fiat WRITE set_current_fiat NOTIFY onFiatChanged)
        Q_PROPERTY(bool notification_enabled READ is_notification_enabled WRITE set_notification_enabled NOTIFY onNotificationEnabledChanged)
        Q_PROPERTY(QVariant custom_erc_token_data READ get_custom_erc_token_data WRITE set_custom_erc_token_data NOTIFY customErcTokenDataChanged)
        Q_PROPERTY(bool fetching_erc_data_busy READ is_fetching_erc_data_busy WRITE set_fetching_erc_data_busy NOTIFY ercDataStatusChanged)

        using t_synchronized_json = boost::synchronized_value<nlohmann::json>;

        //! Private member fields Fields
        ag::ecs::system_manager&      m_system_manager;
        std::shared_ptr<QApplication> m_app;
        atomic_dex::cfg               m_config{load_cfg()};
        QTranslator                   m_translator;
        QString                       m_empty_string{""};
        std::atomic_bool              m_fetching_erc_data_busy{false};
        t_synchronized_json           m_custom_erc_token_data;

      public:
        explicit settings_page(
            entt::registry& registry, ag::ecs::system_manager& system_manager, std::shared_ptr<QApplication> app, QObject* parent = nullptr) noexcept;
        ~settings_page() noexcept final = default;

        //! Public override
        void update() noexcept final;

        //! Properties
        [[nodiscard]] QString  get_current_lang() const noexcept;
        void                   set_current_lang(QString new_lang) noexcept;
        [[nodiscard]] QString  get_empty_string() const noexcept;
        [[nodiscard]] QString  get_current_currency() const noexcept;
        [[nodiscard]] QString  get_current_currency_sign() const noexcept;
        [[nodiscard]] QString  get_current_fiat_sign() const noexcept;
        [[nodiscard]] QString  get_current_fiat() const noexcept;
        [[nodiscard]] bool     is_notification_enabled() const noexcept;
        void                   set_notification_enabled(bool is_enabled) noexcept;
        void                   set_current_currency(const QString& current_currency) noexcept;
        void                   set_current_fiat(const QString& current_fiat) noexcept;
        [[nodiscard]] bool     is_fetching_erc_data_busy() const noexcept;
        void                   set_fetching_erc_data_busy(bool status) noexcept;
        [[nodiscard]] QVariant get_custom_erc_token_data() const noexcept;
        void                   set_custom_erc_token_data(QVariant rpc_data) noexcept;

        //! Public API
        [[nodiscard]] atomic_dex::cfg&       get_cfg() noexcept;
        [[nodiscard]] const atomic_dex::cfg& get_cfg() const noexcept;
        void                                 init_lang() noexcept;

        //! Public QML API
        Q_INVOKABLE [[nodiscard]] QStringList  get_available_langs() const;
        Q_INVOKABLE [[nodiscard]] QStringList  get_available_fiats() const;
        Q_INVOKABLE [[nodiscard]] QStringList  get_available_currencies() const;
        Q_INVOKABLE [[nodiscard]] bool         is_this_ticker_present_in_raw_cfg(const QString& ticker) const noexcept;
        Q_INVOKABLE [[nodiscard]] bool         is_this_ticker_present_in_normal_cfg(const QString& ticker) const noexcept;
        Q_INVOKABLE [[nodiscard]] QVariantList get_custom_coins() const noexcept;
        Q_INVOKABLE [[nodiscard]] QString      get_custom_coins_icons_path() const noexcept;
        Q_INVOKABLE void process_erc_20_token_add(const QString& contract_address, const QString& coinpaprika_id, const QString& icon_filepath);

      signals:
        void onLangChanged();
        void langChanged();
        void onCurrencyChanged();
        void onCurrencySignChanged();
        void onFiatSignChanged();
        void onFiatChanged();
        void onNotificationEnabledChanged();
        void customErcTokenDataChanged();
        void ercDataStatusChanged();
    };
} // namespace atomic_dex

REFL_AUTO(type(atomic_dex::settings_page))