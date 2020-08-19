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

//! QT
#include <QDebug>
#include <QLocale>

//! Project Headers
#include "atomic.dex.events.hpp"
#include "atomic.dex.qt.settings.page.hpp"

//! Constructo destructor
namespace atomic_dex
{
    settings_page::settings_page(entt::registry& registry, std::shared_ptr<QApplication> app, QObject* parent) noexcept :
        QObject(parent), system(registry), m_app(app)
    {
    }
} // namespace atomic_dex

//! Override
namespace atomic_dex
{
    void
    settings_page::update() noexcept
    {
    }
} // namespace atomic_dex

//! Properties
namespace atomic_dex
{
    QString
    settings_page::get_empty_string() const noexcept
    {
        return m_empty_string;
    }

    QString
    settings_page::get_current_lang() const noexcept
    {
        return QString::fromStdString(m_config.current_lang);
    }

    void
    atomic_dex::settings_page::set_current_lang(QString new_lang) noexcept
    {
        const std::string new_lang_std = new_lang.toStdString();
        change_lang(m_config, new_lang_std);

        auto get_locale = [](const std::string& current_lang) {
            if (current_lang == "tr")
            {
                return QLocale::Language::Turkish;
            }
            if (current_lang == "en")
            {
                return QLocale::Language::English;
            }
            if (current_lang == "fr")
            {
                return QLocale::Language::French;
            }
            return QLocale::Language::AnyLanguage;
        };

        qDebug() << "locale before: " << QLocale().name();
        QLocale::setDefault(get_locale(m_config.current_lang));
        qDebug() << "locale after: " << QLocale().name();
        [[maybe_unused]] auto res = this->m_translator.load("atomicDeFi_" + new_lang, QLatin1String(":/atomic_qt_design/assets/languages"));
        assert(res);
        this->m_app->installTranslator(&m_translator);
        emit onLangChanged();
        emit langChanged();
    }

    bool
    atomic_dex::settings_page::is_notification_enabled() const noexcept
    {
        return m_config.notification_enabled;
    }

    void
    settings_page::set_notification_enabled(bool is_enabled) noexcept
    {
        if (m_config.notification_enabled != is_enabled)
        {
            change_notification_status(m_config, is_enabled);
            emit onNotificationEnabledChanged();
        }
    }

    QString
    settings_page::get_current_currency_sign() const noexcept
    {
        return QString::fromStdString(this->m_config.current_currency_sign);
    }

    QString
    settings_page::get_current_fiat_sign() const noexcept
    {
        return QString::fromStdString(this->m_config.current_fiat_sign);
    }

    QString
    settings_page::get_current_currency() const noexcept
    {
        return QString::fromStdString(this->m_config.current_currency);
    }

    void
    settings_page::set_current_currency(const QString& current_currency) noexcept
    {
        if (current_currency.toStdString() != m_config.current_currency)
        {
            spdlog::info("change currency {} to {}", m_config.current_currency, current_currency.toStdString());
            atomic_dex::change_currency(m_config, current_currency.toStdString());
            this->dispatcher_.trigger<update_portfolio_values>();
            emit onCurrencyChanged();
            emit onCurrencySignChanged();
            emit onFiatSignChanged();
        }
    }

    QString
    settings_page::get_current_fiat() const noexcept
    {
        return QString::fromStdString(this->m_config.current_fiat);
    }

    void
    settings_page::set_current_fiat(const QString& current_fiat) noexcept
    {
        if (current_fiat.toStdString() != m_config.current_fiat)
        {
            spdlog::info("change fiat {} to {}", m_config.current_fiat, current_fiat.toStdString());
            atomic_dex::change_fiat(m_config, current_fiat.toStdString());
            emit onFiatChanged();
        }
    }
} // namespace atomic_dex

//! Public API
namespace atomic_dex
{
    atomic_dex::cfg&
    settings_page::get_cfg() noexcept
    {
        return m_config;
    }

    const atomic_dex::cfg&
    settings_page::get_cfg() const noexcept
    {
        return m_config;
    }

    void
    settings_page::init_lang() noexcept
    {
        set_current_lang(QString::fromStdString(m_config.current_lang));
    }
} // namespace atomic_dex

//! QML API
namespace atomic_dex
{
    QStringList
    settings_page::get_available_langs() const
    {
        QStringList out;
        out.reserve(m_config.available_lang.size());
        for (auto&& cur_lang: m_config.available_lang) { out.push_back(QString::fromStdString(cur_lang)); }
        return out;
    }

    QStringList
    settings_page::get_available_fiats() const
    {
        QStringList out;
        out.reserve(m_config.available_fiat.size());
        for (auto&& cur_fiat: m_config.available_fiat) { out.push_back(QString::fromStdString(cur_fiat)); }
        return out;
    }

    QStringList
    settings_page::get_available_currencies() const
    {
        QStringList out;
        out.reserve(m_config.possible_currencies.size());
        for (auto&& cur_currency: m_config.possible_currencies) { out.push_back(QString::fromStdString(cur_currency)); }
        return out;
    }
} // namespace atomic_dex