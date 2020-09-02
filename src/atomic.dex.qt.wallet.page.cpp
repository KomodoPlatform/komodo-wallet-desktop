#include <QJsonArray>
#include <QJsonObject>

//! PCH
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.global.price.service.hpp"
#include "atomic.dex.mm2.hpp"
#include "atomic.dex.provider.coinpaprika.hpp"
#include "atomic.dex.qt.settings.page.hpp"
#include "atomic.dex.qt.utilities.hpp"
#include "atomic.dex.qt.wallet.page.hpp"

namespace atomic_dex
{
    wallet_page::wallet_page(entt::registry& registry, ag::ecs::system_manager& system_manager, QObject* parent) :
        QObject(parent), system(registry), m_system_manager(system_manager)
    {
    }

    void
    wallet_page::update() noexcept
    {
    }
} // namespace atomic_dex

//! Properties
namespace atomic_dex
{
    QString
    wallet_page::get_current_ticker() const noexcept
    {
        const auto& mm2_system = m_system_manager.get_system<mm2>();
        return QString::fromStdString(mm2_system.get_current_ticker());
    }

    void
    wallet_page::set_current_ticker(const QString& ticker) noexcept
    {
        auto& mm2_system = m_system_manager.get_system<mm2>();
        if (mm2_system.set_current_ticker(ticker.toStdString()))
        {
            emit currentTickerChanged();
            refresh_ticker_infos();
        }
    }
} // namespace atomic_dex

//! Public api
namespace atomic_dex
{
    void
    wallet_page::refresh_ticker_infos() noexcept
    {
        emit tickerInfosChanged();
    }

    QVariant
    wallet_page::get_ticker_infos() const noexcept
    {
        spdlog::trace("get_ticker_infos");
        QJsonObject     obj{{"balance", "0"},        {"name", "Komodo"},
                        {"type", "SmartChain"},  {"is_claimable", true},
                        {"address", "foo"},      {"minimal_balance_asking_rewards", "10.00"},
                        {"explorer_url", "foo"}, {"current_currency_ticker_price", "0.00"},
                        {"change_24h", "0"},     {"tx_state", "InProgress"},
                        {"fiat_amount", "0.00"}, {"trend_7d", QJsonArray()}};
        std::error_code ec;
        auto&           mm2_system = m_system_manager.get_system<mm2>();
        if (mm2_system.is_mm2_running())
        {
            auto&       price_service                 = m_system_manager.get_system<global_price_service>();
            const auto& settings_system               = m_system_manager.get_system<settings_page>();
            const auto& paprika                       = m_system_manager.get_system<coinpaprika_provider>();
            const auto& ticker                        = mm2_system.get_current_ticker();
            const auto& coin_info                     = mm2_system.get_coin_info(ticker);
            const auto& config                        = settings_system.get_cfg();
            obj["balance"]                            = QString::fromStdString(mm2_system.my_balance(ticker, ec));
            obj["name"]                               = QString::fromStdString(coin_info.name);
            obj["type"]                               = QString::fromStdString(coin_info.type);
            obj["is_claimable"]                       = coin_info.is_claimable;
            obj["address"]                            = QString::fromStdString(mm2_system.address(ticker, ec));
            obj["minimal_balance_for_asking_rewards"] = QString::fromStdString(coin_info.minimal_claim_amount);
            obj["explorer_url"]                       = QString::fromStdString(coin_info.explorer_url[0]);
            obj["current_currency_ticker_price"]      = QString::fromStdString(price_service.get_rate_conversion(config.current_currency, ticker, ec, true));
            obj["change_24h"]                         = retrieve_change_24h(paprika, coin_info, config);
            obj["tx_state"]                           = QString::fromStdString(mm2_system.get_tx_state(ec).state);
            obj["fiat_amount"]                        = QString::fromStdString(price_service.get_price_in_fiat(config.current_currency, ticker, ec));
            obj["trend_7d"]                           = nlohmann_json_array_to_qt_json_array(paprika.get_ticker_historical(ticker).answer);
        }
        return obj;
    }
} // namespace atomic_dex