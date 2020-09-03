#include <QJsonArray>
#include <QJsonDocument>
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

    bool
    wallet_page::is_rpc_claiming_busy() const noexcept
    {
        return m_is_claiming_busy.load();
    }

    void
    wallet_page::set_claiming_is_busy(bool status) noexcept
    {
        if (m_is_claiming_busy != status)
        {
            m_is_claiming_busy = status;
            emit rpcClaimingStatusChanged();
        }
    }

    void
    wallet_page::set_send_busy(bool status) noexcept
    {
        if (m_is_send_busy != status)
        {
            m_is_send_busy = status;
            emit sendStatusChanged();
        }
    }

    bool
    wallet_page::is_send_busy() const noexcept
    {
        return m_is_send_busy.load();
    }

    bool
    wallet_page::is_broadcast_busy() const noexcept
    {
        return m_is_broadcast_busy.load();
    }

    void
    wallet_page::set_broadcast_busy(bool status) noexcept
    {
        if (m_is_broadcast_busy != status)
        {
            m_is_broadcast_busy = status;
            emit broadCastStatusChanged();
        }
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

    QVariant
    wallet_page::get_rpc_claiming_data() const noexcept
    {
        return m_claiming_rpc_result.get();
    }

    void
    wallet_page::set_rpc_claiming_data(QVariant rpc_data) noexcept
    {
        m_claiming_rpc_result = rpc_data.toJsonObject();
        emit claimingRpcDataChanged();
    }

    QString
    wallet_page::get_rpc_broadcast_data() const noexcept
    {
        return m_broadcast_rpc_result.get();
    }

    void
    wallet_page::set_rpc_broadcast_data(QString rpc_data) noexcept
    {
        m_broadcast_rpc_result = rpc_data;
        emit broadcastDataChanged();
    }

    QVariant
    wallet_page::get_rpc_send_data() const noexcept
    {
        return m_send_rpc_result.get();
    }

    void
    wallet_page::set_rpc_send_data(QVariant rpc_data) noexcept
    {
        m_send_rpc_result = rpc_data.toJsonObject();
        emit sendDataChanged();
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

    void
    wallet_page::send(const QString& address, const QString& amount, bool max, bool with_fees, QVariant fees_data)
    {
        this->set_send_busy(true);
        nlohmann::json     batch      = nlohmann::json::array();
        auto&              mm2_system = m_system_manager.get_system<mm2>();
        const auto&        ticker     = mm2_system.get_current_ticker();
        t_withdraw_request withdraw_req{.coin = ticker, .to = address.toStdString(), .amount = amount.toStdString(), .max = max};
        if (with_fees)
        {
            auto json_fees    = nlohmann::json::parse(QString(QJsonDocument(fees_data.toJsonObject()).toJson()).toStdString());
            bool is_erc_20    = mm2_system.get_coin_info(ticker).is_erc_20;
            withdraw_req.fees = t_withdraw_fees{
                .type      = is_erc_20 ? "EthGas" : "UtxoFixed",
                .amount    = json_fees.at("fees_amount").get<std::string>(),
                .gas_price = json_fees.at("gas_price").get<std::string>(),
                .gas_limit = json_fees.at("gas_limit").get<int>()};
        }
        nlohmann::json json_data = ::mm2::api::template_request("withdraw");
        ::mm2::api::to_json(json_data, withdraw_req);
        batch.push_back(json_data);
        auto answer_functor = [this](web::http::http_response resp) {
            std::string body = TO_STD_STR(resp.extract_string(true).get());
            if (resp.status_code() == 200)
            {
                auto           answers              = nlohmann::json::parse(body);
                auto           withdraw_answer      = ::mm2::api::rpc_process_answer_batch<t_withdraw_answer>(answers[0], "withdraw");
                nlohmann::json j_out                = nlohmann::json::object();
                j_out["withdraw_answer"]            = answers[0];
                j_out.at("withdraw_answer")["date"] = withdraw_answer.result.value().timestamp_as_date;
                this->set_rpc_send_data(nlohmann_json_object_to_qt_json_object(j_out));
            }
            else
            {
                auto error_json = QJsonObject({{"error_code", resp.status_code()}});
                this->set_rpc_send_data(error_json);
            }
            this->set_send_busy(false);
        };
        ::mm2::api::async_rpc_batch_standalone(batch, mm2_system.get_mm2_client(), mm2_system.get_cancellation_token())
            .then(answer_functor)
            .then(&handle_exception_pplx_task);
    }

    void
    wallet_page::broadcast(const QString& tx_hex) noexcept
    {
        //! Preparation
        this->set_rpc_broadcast_data("");
        this->set_broadcast_busy(true);
        auto&               mm2_system = m_system_manager.get_system<mm2>();
        const auto&         ticker     = mm2_system.get_current_ticker();
        nlohmann::json      batch      = nlohmann::json::array();
        t_broadcast_request broadcast_request{.tx_hex = tx_hex.toStdString(), .coin = ticker};
        nlohmann::json      json_data = ::mm2::api::template_request("send_raw_transaction");
        ::mm2::api::to_json(json_data, broadcast_request);
        batch.push_back(json_data);

        //! Answer
        auto answer_functor = [this](web::http::http_response resp) {
            std::string body = TO_STD_STR(resp.extract_string(true).get());
            if (resp.status_code() == 200)
            {
                auto answers = nlohmann::json::parse(body);
                this->set_rpc_broadcast_data(QString::fromStdString(answers[0].at("tx_hash").get<std::string>()));
            }
            else
            {
                this->set_rpc_broadcast_data(QString::fromStdString(body));
            }
            this->set_broadcast_busy(false);
        };

        ::mm2::api::async_rpc_batch_standalone(batch, mm2_system.get_mm2_client(), mm2_system.get_cancellation_token())
            .then(answer_functor)
            .then(&handle_exception_pplx_task);
    }

    void
    wallet_page::claim_rewards()
    {
        this->set_claiming_is_busy(true);
        nlohmann::json     batch      = nlohmann::json::array();
        auto&              mm2_system = m_system_manager.get_system<mm2>();
        std::error_code    ec;
        t_withdraw_request withdraw_req{.coin = "KMD", .to = mm2_system.address("KMD", ec), .amount = "0", .max = true};
        nlohmann::json     json_data = ::mm2::api::template_request("withdraw");
        ::mm2::api::to_json(json_data, withdraw_req);
        batch.push_back(json_data);
        json_data = ::mm2::api::template_request("kmd_rewards_info");
        batch.push_back(json_data);
        ::mm2::api::async_rpc_batch_standalone(batch, mm2_system.get_mm2_client(), mm2_system.get_cancellation_token())
            .then([this](web::http::http_response resp) {
                std::string body = TO_STD_STR(resp.extract_string(true).get());
                if (resp.status_code() == 200)
                {
                    auto           answers              = nlohmann::json::parse(body);
                    auto           withdraw_answer      = ::mm2::api::rpc_process_answer_batch<t_withdraw_answer>(answers[0], "withdraw");
                    nlohmann::json j_out                = nlohmann::json::object();
                    j_out["withdraw_answer"]            = answers[0];
                    j_out.at("withdraw_answer")["date"] = withdraw_answer.result.value().timestamp_as_date;
                    auto kmd_rewards_answer             = ::mm2::api::process_kmd_rewards_answer(answers[1]);
                    j_out["kmd_rewards_info"]           = kmd_rewards_answer.result;
                    this->set_rpc_claiming_data(nlohmann_json_object_to_qt_json_object(j_out));
                }
                else
                {
                    auto error_json = QJsonObject({{"error_code", resp.status_code()}});
                    this->set_rpc_claiming_data(error_json);
                }
                this->set_claiming_is_busy(false);
            })
            .then(&handle_exception_pplx_task);
    }
} // namespace atomic_dex