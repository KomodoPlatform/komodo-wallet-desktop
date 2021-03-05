/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
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

//! STD
#include <unordered_set>

//! Project Headers
#include "atomicdex/api/mm2/rpc.electrum.hpp"
#include "atomicdex/api/mm2/rpc.enable.hpp"
#include "atomicdex/config/mm2.cfg.hpp"
#include "atomicdex/constants/mm2.constants.hpp"
#include "atomicdex/managers/qt.wallet.manager.hpp"
#include "atomicdex/services/internet/internet.checker.service.hpp"
#include "atomicdex/services/mm2/mm2.service.hpp"
#include "atomicdex/utilities/kill.hpp" ///< no delete
#include "atomicdex/utilities/stacktrace.prerequisites.hpp"

//! Anonymous functions
namespace
{
    namespace ag = antara::gaming;

    void
    check_for_reconfiguration(const std::string& wallet_name)
    {
        using namespace std::string_literals;
        SPDLOG_DEBUG("checking for reconfiguration");

        fs::path    cfg_path                   = atomic_dex::utils::get_atomic_dex_config_folder();
        std::string filename                   = std::string(atomic_dex::get_precedent_raw_version()) + "-coins." + wallet_name + ".json";
        fs::path    precedent_version_cfg_path = cfg_path / filename;

        if (fs::exists(precedent_version_cfg_path))
        {
            //! There is a precedent configuration file
            SPDLOG_INFO("There is a precedent configuration file, upgrading the new one with precedent settings");

            //! Old cfg to ifs
            std::ifstream ifs(precedent_version_cfg_path.string());
            assert(ifs.is_open());
            nlohmann::json precedent_config_json_data;
            ifs >> precedent_config_json_data;

            //! New cfg to ifs
            fs::path      actual_version_filepath = cfg_path / (std::string(atomic_dex::get_raw_version()) + "-coins."s + wallet_name + ".json"s);
            std::ifstream actual_version_ifs(actual_version_filepath.string());
            assert(actual_version_ifs.is_open());
            nlohmann::json actual_config_data;
            actual_version_ifs >> actual_config_data;

            //! Iterate through new config
            for (auto& [key, value]: actual_config_data.items())
            {
                //! If the coin in new config is present in the old one, copy the contents
                if (precedent_config_json_data.contains(key))
                {
                    actual_config_data.at(key)["active"] = precedent_config_json_data.at(key).at("active").get<bool>();
                }
            }

            for (auto& [key, value]: precedent_config_json_data.items())
            {
                if (value.contains("is_custom_coin") && value.at("is_custom_coin").get<bool>())
                {
                    SPDLOG_INFO("{} is a custom coin, copying to new cfg", key);
                    actual_config_data[key] = value;
                }
            }

            ifs.close();
            actual_version_ifs.close();

            //! Write contents
            std::ofstream ofs(actual_version_filepath.string());
            assert(ofs.is_open());
            ofs << actual_config_data;

            //! Delete old cfg
            fs_error_code ec;
            fs::remove(precedent_version_cfg_path, ec);
            if (ec)
            {
                SPDLOG_ERROR("error: {}", ec.message());
            }
        }
    }

    void
    update_coin_status(const std::string& wallet_name, const std::vector<std::string>& tickers, bool status = true)
    {
        fs::path       cfg_path = atomic_dex::utils::get_atomic_dex_config_folder();
        std::string    filename = std::string(atomic_dex::get_raw_version()) + "-coins." + wallet_name + ".json";
        std::ifstream  ifs((cfg_path / filename).c_str());
        nlohmann::json config_json_data;

        assert(ifs.is_open());
        ifs >> config_json_data;

        for (auto&& ticker: tickers) { config_json_data.at(ticker)["active"] = status; }

        ifs.close();

        //! Write contents
        std::ofstream ofs((cfg_path / filename).c_str(), std::ios::trunc);
        assert(ofs.is_open());
        ofs << config_json_data;
    }
} // namespace

namespace atomic_dex
{
    std::vector<atomic_dex::coin_config>
    mm2_service::retrieve_coins_informations() noexcept
    {
        std::vector<atomic_dex::coin_config> cfg;
        SPDLOG_DEBUG("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

        check_for_reconfiguration(m_current_wallet_name);
        const auto  cfg_path = atomic_dex::utils::get_atomic_dex_config_folder();
        std::string filename = std::string(atomic_dex::get_raw_version()) + "-coins." + m_current_wallet_name + ".json";
        SPDLOG_INFO("Retrieving Wallet information of {}", (cfg_path / filename).string());
        if (exists(cfg_path / filename))
        {
            std::ifstream ifs((cfg_path / filename).c_str());
            assert(ifs.is_open());
            nlohmann::json config_json_data;
            ifs >> config_json_data;
            auto res = config_json_data.get<std::unordered_map<std::string, atomic_dex::coin_config>>();
            cfg.reserve(res.size());
            for (auto&& [key, value]: res) { cfg.emplace_back(value); }
            {
                std::unique_lock lock(m_coin_cfg_mutex);
                m_coins_informations = std::move(res);
            }

            return cfg;
        }
        return cfg;
    }

    mm2_service::mm2_service(entt::registry& registry, ag::ecs::system_manager& system_manager) : system(registry), m_system_manager(system_manager)
    {
        m_orderbook_clock = std::chrono::high_resolution_clock::now();
        m_info_clock      = std::chrono::high_resolution_clock::now();

        dispatcher_.sink<gui_enter_trading>().connect<&mm2_service::on_gui_enter_trading>(*this);
        dispatcher_.sink<gui_leave_trading>().connect<&mm2_service::on_gui_leave_trading>(*this);
        dispatcher_.sink<orderbook_refresh>().connect<&mm2_service::on_refresh_orderbook>(*this);
    }

    void
    mm2_service::update() noexcept
    {
        using namespace std::chrono_literals;

        if (not m_mm2_running)
        {
            return;
        }

        const auto now    = std::chrono::high_resolution_clock::now();
        const auto s      = std::chrono::duration_cast<std::chrono::seconds>(now - m_orderbook_clock);
        const auto s_info = std::chrono::duration_cast<std::chrono::seconds>(now - m_info_clock);

        if (s >= 5s)
        {
            fetch_current_orderbook_thread(false);
            batch_fetch_orders_and_swap();
            m_orderbook_clock = std::chrono::high_resolution_clock::now();
        }

        if (s_info >= 30s)
        {
            fetch_infos_thread();
            m_info_clock = std::chrono::high_resolution_clock::now();
        }
    }

    mm2_service::~mm2_service() noexcept
    {
        SPDLOG_INFO("destroying mm2 service...");
        dispatcher_.sink<gui_enter_trading>().disconnect<&mm2_service::on_gui_enter_trading>(*this);
        dispatcher_.sink<gui_leave_trading>().disconnect<&mm2_service::on_gui_leave_trading>(*this);
        dispatcher_.sink<orderbook_refresh>().disconnect<&mm2_service::on_refresh_orderbook>(*this);
        SPDLOG_INFO("mm2 signals successfully disconnected");
        bool mm2_stopped = false;
        if (m_mm2_running)
        {
            SPDLOG_INFO("preparing mm2 stop batch request");
            nlohmann::json stop_request = ::mm2::api::template_request("stop");
            nlohmann::json batch        = nlohmann::json::array();
            batch.push_back(stop_request);
            SPDLOG_INFO("processing mm2 stop batch request");
            pplx::task<web::http::http_response> resp_task = ::mm2::api::async_rpc_batch_standalone(batch, m_mm2_client, m_token_source.get_token());
            web::http::http_response             resp      = resp_task.get();
            SPDLOG_INFO("mm2 stop batch answer received");
            auto answers = ::mm2::api::basic_batch_answer(resp);
            if (answers[0].contains("result"))
            {
                mm2_stopped = answers[0].at("result").get<std::string>() == "success";
                SPDLOG_INFO("mm2 successfully stopped with rpc stop");
            }
        }
        m_mm2_running = false;
        m_token_source.cancel();

        if (!mm2_stopped)
        {
            SPDLOG_INFO("mm2 didn't stop yet with rpc stop, stopping process manually");
#if defined(_WIN32) || defined(WIN32)
            atomic_dex::kill_executable("mm2");
#else
            const reproc::stop_actions stop_actions = {
                {reproc::stop::terminate, reproc::milliseconds(2000)},
                {reproc::stop::kill, reproc::milliseconds(5000)},
                {reproc::stop::wait, reproc::milliseconds(2000)}};

            const auto ec = m_mm2_instance.stop(stop_actions).second;

            if (ec)
            {
                SPDLOG_ERROR("error when stopping mm2 by process: {}", ec.message());
                // std::cerr << "error: " << ec.message() << std::endl;
            }
#endif
        }

        if (m_mm2_init_thread.joinable())
        {
            m_mm2_init_thread.join();
            SPDLOG_INFO("mm2 init thread destroyed");
        }
        SPDLOG_INFO("mm2 service fully destroyed");
    }

    const std::atomic_bool&
    mm2_service::is_mm2_running() const noexcept
    {
        return m_mm2_running;
    }

    t_coins
    mm2_service::get_enabled_coins() const noexcept
    {
        t_coins destination;

        std::shared_lock lock(m_coin_cfg_mutex);
        for (auto&& [key, value]: m_coins_informations)
        {
            if (value.currently_enabled)
            {
                destination.push_back(value);
            }
        }

        return destination;
    }

    t_coins
    mm2_service::get_active_coins() const noexcept
    {
        t_coins destination;

        std::shared_lock lock(m_coin_cfg_mutex);
        for (auto&& [key, value]: m_coins_informations)
        {
            if (value.active)
            {
                destination.emplace_back(value);
            }
        }

        return destination;
    }

    bool
    mm2_service::disable_coin(const std::string& ticker, std::error_code& ec) noexcept
    {
        coin_config coin_info = get_coin_info(ticker);
        if (not coin_info.currently_enabled)
        {
            return true;
        }

        t_disable_coin_request request{.coin = ticker};
        auto                   answer = rpc_disable_coin(std::move(request), m_mm2_client);

        if (answer.error.has_value())
        {
            std::string error = answer.error.value();
            if (error.find("such coin") != std::string::npos)
            {
                ec = dextop_error::disable_unknown_coin;
                return false;
            }
            if (error.find("active swaps") != std::string::npos)
            {
                ec = dextop_error::active_swap_is_using_the_coin;
                return false;
            }
            if (error.find("matching orders") != std::string::npos)
            {
                ec = dextop_error::order_is_matched_at_the_moment;
                return false;
            }
        }

        coin_info.currently_enabled = false;

        {
            std::unique_lock lock(m_coin_cfg_mutex);
            m_coins_informations[ticker].currently_enabled = false;
        }

        dispatcher_.trigger<coin_disabled>(ticker);
        return true;
    }

    bool
    mm2_service::enable_default_coins() noexcept
    {
        std::atomic<std::size_t> result{1};
        auto                     coins = get_active_coins();

        std::vector<std::string> tickers;
        tickers.reserve(coins.size());
        for (auto&& current_coin: coins) { tickers.push_back(current_coin.ticker); }

        batch_enable_coins(tickers, true);

        batch_fetch_orders_and_swap();

        return result.load() == 1;
    }

    void
    mm2_service::disable_multiple_coins(const std::vector<std::string>& tickers) noexcept
    {
        SPDLOG_DEBUG("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        for (const auto& ticker: tickers)
        {
            std::error_code ec;
            disable_coin(ticker, ec);
            if (ec)
            {
                SPDLOG_WARN("{}", ec.message());
            }
        }

        update_coin_status(this->m_current_wallet_name, tickers, false);
    }

    auto
    mm2_service::batch_balance_and_tx(bool is_a_reset, std::vector<std::string> tickers, bool is_during_enabling, bool only_tx)
    {
        auto&& [batch_array, tickers_idx, erc_to_fetch] = prepare_batch_balance_and_tx(only_tx);
        return ::mm2::api::async_rpc_batch_standalone(batch_array, m_mm2_client, m_token_source.get_token())
            .then([this, tickers_idx = tickers_idx, erc_to_fetch = erc_to_fetch, is_a_reset, tickers, is_during_enabling](web::http::http_response resp) {
                try
                {
                    auto answers = ::mm2::api::basic_batch_answer(resp);
                    if (not answers.contains("error"))
                    {
                        std::size_t idx = 0;
                        for (auto&& answer: answers)
                        {
                            if (answer.contains("balance"))
                            {
                                this->process_balance_answer(answer);
                            }
                            else if (answer.contains("result"))
                            {
                                this->process_tx_answer(answer);
                            }
                            else
                            {
                                const std::string error = answer.dump(4);
                                SPDLOG_ERROR("error answer for tx or my_balance: {}", error);
                                if (error.find("future timed out") != std::string::npos)
                                {
                                    SPDLOG_WARN("Future timed out error detected, probably a connection issue");
                                    //! Emit error for UI Change
                                }
                            }
                            ++idx;
                        }

                        for (auto&& coin: erc_to_fetch) { process_tx_etherscan(coin, is_a_reset); }
                        this->dispatcher_.trigger<ticker_balance_updated>(tickers_idx);
                        if (is_during_enabling)
                        {
                            dispatcher_.trigger<coin_enabled>(tickers);
                        }
                    }
                }
                catch (const std::exception& error)
                {
                    SPDLOG_ERROR("exception in batch_balance_and_tx: {}", error.what());
                }
            })
            .then([this](pplx::task<void> previous_task) { this->handle_exception_pplx_task(previous_task); });
    }

    std::tuple<nlohmann::json, std::vector<std::string>, std::vector<std::string>>
    mm2_service::prepare_batch_balance_and_tx(bool only_tx) const
    {
        const auto&              enabled_coins = get_enabled_coins();
        nlohmann::json           batch_array   = nlohmann::json::array();
        std::vector<std::string> tickers_idx;
        std::vector<std::string> erc_to_fetch;
        const auto&              ticker = get_current_ticker();
        if (!(get_coin_info(ticker).coin_type == CoinType::ERC20))
        {
            t_tx_history_request request{.coin = ticker, .limit = 5000};
            nlohmann::json       j = ::mm2::api::template_request("my_tx_history");
            ::mm2::api::to_json(j, request);
            batch_array.push_back(j);
        }
        else
        {
            erc_to_fetch.push_back(ticker);
        }
        if (not only_tx)
        {
            for (auto&& coin: enabled_coins)
            {
                if (is_pin_cfg_enabled())
                {
                    std::shared_lock lock(m_balance_mutex); ///< shared_lock
                    if (m_balance_informations.find(coin.ticker) != m_balance_informations.cend())
                    {
                        continue;
                    }
                }
                t_balance_request balance_request{.coin = coin.ticker};
                nlohmann::json    j = ::mm2::api::template_request("my_balance");
                ::mm2::api::to_json(j, balance_request);
                batch_array.push_back(j);
                tickers_idx.push_back(coin.ticker);
            }
        }
        return std::make_tuple(batch_array, tickers_idx, erc_to_fetch);
    }

    std::pair<bool, std::string>
    mm2_service::process_batch_enable_answer(const json& answer)
    {
        std::string error = answer.dump(4);

        if (answer.contains("error") || answer.contains("Error") || error.find("error") != std::string::npos || error.find("Error") != std::string::npos)
        {
            SPDLOG_DEBUG("bad answer json for enable/electrum details: {}", error);
            return {false, error};
        }

        if (answer.contains("coin"))
        {
            auto ticker = answer.at("coin").get<std::string>();
            {
                std::unique_lock lock(m_coin_cfg_mutex);
                m_coins_informations[ticker].currently_enabled = true;
            }
            return {true, ""};
        }

        SPDLOG_DEBUG("bad answer json for enable/electrum details: {}", error);
        return {false, error};
    }

    void
    mm2_service::batch_enable_coins(const std::vector<std::string>& tickers, bool first_time) noexcept
    {
        nlohmann::json btc_kmd_batch = nlohmann::json::array();
        if (first_time)
        {
            coin_config        coin_info = get_coin_info("BTC");
            t_electrum_request request{.coin_name = coin_info.ticker, .servers = coin_info.electrum_urls.value(), .with_tx_history = true};
            nlohmann::json     j = ::mm2::api::template_request("electrum");
            ::mm2::api::to_json(j, request);
            btc_kmd_batch.push_back(j);
            coin_info = get_coin_info("KMD");
            t_electrum_request request_kmd{.coin_name = coin_info.ticker, .servers = coin_info.electrum_urls.value(), .with_tx_history = true};
            j = ::mm2::api::template_request("electrum");
            ::mm2::api::to_json(j, request_kmd);
            btc_kmd_batch.push_back(j);
        }

        nlohmann::json batch_array = nlohmann::json::array();

        std::vector<std::string> copy_tickers;

        for (const auto& ticker: tickers)
        {
            if (ticker == "BTC" || ticker == "KMD")
                continue;
            copy_tickers.push_back(ticker);
            coin_config coin_info = get_coin_info(ticker);

            if (coin_info.currently_enabled)
            {
                continue;
            }

            if (!(coin_info.coin_type == CoinType::ERC20))
            {
                t_electrum_request request{
                    .coin_name       = coin_info.ticker,
                    .servers         = coin_info.electrum_urls.value_or(get_electrum_server_from_token(coin_info.ticker)),
                    .coin_type       = coin_info.coin_type,
                    .is_testnet      = coin_info.is_testnet.value_or(false),
                    .with_tx_history = true};
                nlohmann::json j = ::mm2::api::template_request("electrum");
                ::mm2::api::to_json(j, request);
                batch_array.push_back(j);
            }
            else
            {
                t_enable_request request{
                    .coin_name       = coin_info.ticker,
                    .urls            = (coin_info.coin_type == CoinType::ERC20) ? coin_info.eth_urls.value() : std::vector<std::string>(),
                    .coin_type       = coin_info.coin_type,
                    .with_tx_history = false};
                nlohmann::json j = ::mm2::api::template_request("enable");
                ::mm2::api::to_json(j, request);
                batch_array.push_back(j);
            }
            //! If the coin is a custom coin and not present, then we have a config mismatch, we re-add it to the mm2 coins cfg but this need a app restart.
            if (coin_info.is_custom_coin && !this->is_this_ticker_present_in_raw_cfg(coin_info.ticker))
            {
                nlohmann::json empty = "{}"_json;
                if (coin_info.custom_backup.has_value())
                {
                    SPDLOG_WARN("Configuration mismatch between mm2 cfg and coin cfg for ticker {}, readjusting...", coin_info.ticker);
                    this->add_new_coin(empty, coin_info.custom_backup.value());
                    this->dispatcher_.trigger<mismatch_configuration_custom_coin>(coin_info.ticker);
                }
            }
        }

        // SPDLOG_DEBUG("{}", batch_array.dump(4));
        auto functor = [this](nlohmann::json batch_array, std::vector<std::string> tickers) {
            ::mm2::api::async_rpc_batch_standalone(batch_array, this->m_mm2_client, m_token_source.get_token())
                .then([this, tickers](web::http::http_response resp) mutable {
                    try
                    {
                        SPDLOG_DEBUG("Enabling coin finished");
                        auto answers = ::mm2::api::basic_batch_answer(resp);
                        SPDLOG_DEBUG("Enabling coin parsed");

                        if (answers.count("error") == 0)
                        {
                            std::size_t                     idx = 0;
                            std::unordered_set<std::string> to_remove;
                            for (auto&& answer: answers)
                            {
                                auto [res, error] = this->process_batch_enable_answer(answer);
                                if (not res && idx < tickers.size())
                                {
                                    SPDLOG_DEBUG(
                                        "bad answer for: [{}] -> removing it from enabling, idx: {}, tickers size: {}, answers size: {}", tickers[idx], idx,
                                        tickers.size(), answers.size());
                                    this->dispatcher_.trigger<enabling_coin_failed>(tickers[idx], error);
                                    to_remove.emplace(tickers[idx]);
                                }
                                idx += 1;
                            }

                            for (auto&& t: to_remove) { tickers.erase(std::remove(tickers.begin(), tickers.end(), t), tickers.end()); }

                            if (not tickers.empty())
                            {
                                if (tickers == default_coins)
                                {
                                    this->dispatcher_.trigger<default_coins_enabled>();
                                }
                                batch_balance_and_tx(false, tickers, true);
                            }
                        }
                    }
                    catch (const std::exception& error)
                    {
                        SPDLOG_ERROR("exception caught in batch_enable_coins: {}", error.what());
                        //! Emit event here
                    }
                })
                .then([this](pplx::task<void> previous_task) { this->handle_exception_pplx_task(previous_task); });
        };

        SPDLOG_DEBUG("starting async enabling coin");

        if (not btc_kmd_batch.empty() && first_time)
        {
            functor(btc_kmd_batch, default_coins);
        }

        if (not batch_array.empty())
        {
            functor(batch_array, copy_tickers);
        }
    }

    void
    mm2_service::enable_multiple_coins(const std::vector<std::string>& tickers) noexcept
    {
        batch_enable_coins(tickers);
        update_coin_status(this->m_current_wallet_name, tickers, true);
    }

    coin_config
    mm2_service::get_coin_info(const std::string& ticker) const
    {
        std::shared_lock lock(m_coin_cfg_mutex);
        if (m_coins_informations.find(ticker) == m_coins_informations.cend())
        {
            return {};
        }
        return m_coins_informations.at(ticker);
    }

    t_orderbook_answer
    mm2_service::get_orderbook(t_mm2_ec& ec) const noexcept
    {
        auto&& [base, rel]          = this->m_synchronized_ticker_pair.get();
        const std::string pair      = base + "/" + rel;
        auto              orderbook = m_orderbook.get();
        if (orderbook.base.empty() && orderbook.rel.empty())
        {
            ec = dextop_error::orderbook_empty;
            return {};
        }
        if (pair != orderbook.base + "/" + rel)
        {
            ec = dextop_error::orderbook_ticker_not_found;
            return {};
        }
        return orderbook;
    }

    nlohmann::json
    mm2_service::prepare_batch_orderbook()
    {
        auto&& [base, rel] = m_synchronized_ticker_pair.get();
        if (rel.empty())
            return nlohmann::json::array();
        nlohmann::json batch = nlohmann::json::array();

        nlohmann::json      current_request = ::mm2::api::template_request("orderbook");
        t_orderbook_request req_orderbook{.base = base, .rel = rel};
        ::mm2::api::to_json(current_request, req_orderbook);
        batch.push_back(current_request);
        current_request = ::mm2::api::template_request("max_taker_vol");
        ::mm2::api::max_taker_vol_request req_base_max_taker_vol{.coin = base};
        ::mm2::api::to_json(current_request, req_base_max_taker_vol);
        batch.push_back(current_request);
        current_request = ::mm2::api::template_request("max_taker_vol");
        ::mm2::api::max_taker_vol_request req_rel_max_taker_vol{.coin = rel};
        ::mm2::api::to_json(current_request, req_rel_max_taker_vol);
        batch.push_back(current_request);
        return batch;
    }

    void
    mm2_service::batch_process_fees_and_fetch_current_orderbook_thread(bool is_a_reset)
    {
        SPDLOG_INFO("batch orderbook/fees");
        if (not m_orderbook_thread_active)
        {
            SPDLOG_WARN("Nothing to achieve, sleeping");
            return;
        }

        //! Prepare fees
        auto batch = prepare_process_fees_and_current_orderbook();
        // SPDLOG_INFO("Request: {}", batch.dump(4));
        if (batch.empty())
        {
            return;
        }
        auto&& [orderbook_ticker_base, orderbook_ticker_rel] = m_synchronized_ticker_pair.get();

        ::mm2::api::async_rpc_batch_standalone(batch, m_mm2_client, m_token_source.get_token())
            .then(
                [this, orderbook_ticker_base = orderbook_ticker_base, orderbook_ticker_rel = orderbook_ticker_rel, is_a_reset](web::http::http_response resp) {
                    auto answer = ::mm2::api::basic_batch_answer(resp);
                    // SPDLOG_INFO("Debug output: {}", answer.dump(4));
                    if (answer.is_array())
                    {
                        auto trade_fee_base_answer = ::mm2::api::rpc_process_answer_batch<t_get_trade_fee_answer>(answer[0], "get_trade_fee");
                        if (trade_fee_base_answer.rpc_result_code == 200)
                        {
                            this->m_trade_fees_registry->operator[](orderbook_ticker_base) = trade_fee_base_answer;
                        }

                        auto trade_fee_rel_answer = ::mm2::api::rpc_process_answer_batch<t_get_trade_fee_answer>(answer[1], "get_trade_fee");
                        if (trade_fee_rel_answer.rpc_result_code == 200)
                        {
                            this->m_trade_fees_registry->operator[](orderbook_ticker_rel) = trade_fee_rel_answer;
                        }

                        auto orderbook_answer = ::mm2::api::rpc_process_answer_batch<t_orderbook_answer>(answer[2], "orderbook");

                        if (orderbook_answer.rpc_result_code == 200)
                        {
                            m_orderbook = orderbook_answer;
                            this->dispatcher_.trigger<process_orderbook_finished>(is_a_reset);
                        }

                        auto base_max_taker_vol_answer = ::mm2::api::rpc_process_answer_batch<::mm2::api::max_taker_vol_answer>(answer[3], "max_taker_vol");
                        if (base_max_taker_vol_answer.rpc_result_code == 200)
                        {
                            this->m_synchronized_max_taker_vol->first = base_max_taker_vol_answer.result.value();
                            t_float_50 base_res                       = t_float_50(this->m_synchronized_max_taker_vol->first.decimal) * m_balance_factor;
                            this->m_synchronized_max_taker_vol->first.decimal = base_res.str(8);
                        }

                        auto rel_max_taker_vol_answer = ::mm2::api::rpc_process_answer_batch<::mm2::api::max_taker_vol_answer>(answer[4], "max_taker_vol");
                        if (rel_max_taker_vol_answer.rpc_result_code == 200)
                        {
                            this->m_synchronized_max_taker_vol->second = rel_max_taker_vol_answer.result.value();
                            t_float_50 rel_res                         = t_float_50(this->m_synchronized_max_taker_vol->second.decimal) * m_balance_factor;
                            this->m_synchronized_max_taker_vol->second.decimal = rel_res.str(8);
                        }
                    }
                })
            .then([this](pplx::task<void> previous_task) { this->handle_exception_pplx_task(previous_task); });
    }

    void
    mm2_service::process_orderbook(bool is_a_reset)
    {
        auto batch = prepare_batch_orderbook();
        if (batch.empty())
            return;
        auto&& [base, rel] = m_synchronized_ticker_pair.get();

        ::mm2::api::async_rpc_batch_standalone(batch, m_mm2_client, m_token_source.get_token())
            .then([this, is_a_reset, base = base, rel = rel](web::http::http_response resp) {
                auto answer = ::mm2::api::basic_batch_answer(resp);
                if (answer.is_array())
                {
                    auto orderbook_answer = ::mm2::api::rpc_process_answer_batch<t_orderbook_answer>(answer[0], "orderbook");

                    if (orderbook_answer.rpc_result_code == 200)
                    {
                        m_orderbook = orderbook_answer;
                        this->dispatcher_.trigger<process_orderbook_finished>(is_a_reset);
                    }

                    auto base_max_taker_vol_answer = ::mm2::api::rpc_process_answer_batch<::mm2::api::max_taker_vol_answer>(answer[1], "max_taker_vol");
                    if (base_max_taker_vol_answer.rpc_result_code == 200)
                    {
                        this->m_synchronized_max_taker_vol->first         = base_max_taker_vol_answer.result.value();
                        t_float_50 base_res                               = t_float_50(this->m_synchronized_max_taker_vol->first.decimal) * m_balance_factor;
                        this->m_synchronized_max_taker_vol->first.decimal = base_res.str(8);
                    }

                    auto rel_max_taker_vol_answer = ::mm2::api::rpc_process_answer_batch<::mm2::api::max_taker_vol_answer>(answer[2], "max_taker_vol");
                    if (rel_max_taker_vol_answer.rpc_result_code == 200)
                    {
                        this->m_synchronized_max_taker_vol->second         = rel_max_taker_vol_answer.result.value();
                        t_float_50 rel_res                                 = t_float_50(this->m_synchronized_max_taker_vol->second.decimal) * m_balance_factor;
                        this->m_synchronized_max_taker_vol->second.decimal = rel_res.str(8);
                    }
                }
            })
            .then([this](pplx::task<void> previous_task) { this->handle_exception_pplx_task(previous_task); });
    }

    void
    mm2_service::fetch_current_orderbook_thread(bool is_a_reset)
    {
        !m_orderbook_thread_active ? SPDLOG_WARN("Nothing to achieve, sleeping") : SPDLOG_INFO("Fetch current orderbook");

        //! If thread is not active ex: we are not on the trading page anymore, we continue sleeping.
        if (!m_orderbook_thread_active)
        {
            return;
        }

        process_orderbook(is_a_reset);
    }

    void
    mm2_service::fetch_infos_thread(bool is_a_refresh, bool only_tx)
    {
        SPDLOG_INFO("fetch_infos_thread");

        batch_balance_and_tx(is_a_refresh, {}, false, only_tx);
    }

    void
    mm2_service::spawn_mm2_instance(std::string wallet_name, std::string passphrase, bool with_pin_cfg)
    {
        this->m_balance_factor = utils::determine_balance_factor(with_pin_cfg);
        SPDLOG_DEBUG("balance factor is: {}", m_balance_factor);
        SPDLOG_DEBUG("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        this->m_current_wallet_name = std::move(wallet_name);
        this->dispatcher_.trigger<coin_cfg_parsed>(this->retrieve_coins_informations());
        mm2_config cfg{.passphrase = std::move(passphrase), .rpc_password = atomic_dex::gen_random_password()};
        ::mm2::api::set_system_manager(m_system_manager);
        ::mm2::api::set_rpc_password(cfg.rpc_password);
        json       json_cfg;
        const auto tools_path = ag::core::assets_real_path() / "tools/mm2/";

        nlohmann::to_json(json_cfg, cfg);
        fs::path mm2_cfg_path = (fs::temp_directory_path() / "MM2.json");

        std::ofstream ofs(mm2_cfg_path.string());
        ofs << json_cfg.dump();
        // std::cout << json_cfg.dump() << std::endl;
        ofs.close();
        const std::array<std::string, 1> args = {(tools_path / "mm2").string()};
        reproc::options                  options;
        options.redirect.parent = false;

        options.env.behavior = reproc::env::extend;
        options.env.extra    = std::unordered_map<std::string, std::string>{
            {"MM_CONF_PATH", utils::u8string(mm2_cfg_path)},
            {"MM_LOG", utils::u8string(utils::get_mm2_atomic_dex_current_log_file())},
            {"MM_COINS_PATH", utils::u8string((utils::get_current_configs_path() / "coins.json"))}};

        options.working_directory = strdup(tools_path.string().c_str());

        SPDLOG_DEBUG("command line: {}, from directory: {}", args[0], options.working_directory);
        const auto ec = m_mm2_instance.start(args, options);
        std::free((void*)options.working_directory);
        if (ec)
        {
            SPDLOG_ERROR("{}\n", ec.message());
            std::exit(EXIT_FAILURE);
        }

        m_mm2_init_thread = std::thread([this, mm2_cfg_path]() {
            // std::this_thread::
            using namespace std::chrono_literals;
            auto               check_mm2_alive = []() { return ::mm2::api::rpc_version() != "error occured during rpc_version"; };
            static std::size_t nb_try          = 0;

            while (not check_mm2_alive())
            {
                nb_try += 1;
                if (nb_try == 30)
                {
                    SPDLOG_ERROR("MM2 not started correctly");
                    //! TODO: emit mm2_failed_initialization
                    fs::remove(mm2_cfg_path);
                    return;
                }
                std::this_thread::sleep_for(1s);
            }

            web::http::client::http_client_config cfg;
            using namespace std::chrono_literals;
            cfg.set_timeout(30s);
            m_mm2_client = std::make_shared<web::http::client::http_client>(FROM_STD_STR(::mm2::api::g_endpoint), cfg);
            fs::remove(mm2_cfg_path);
            SPDLOG_INFO("mm2 is initialized");
            dispatcher_.trigger<mm2_initialized>();
            enable_default_coins();
            m_mm2_running = true;
            dispatcher_.trigger<mm2_started>();
        });
    }

    t_float_50
    mm2_service::get_balance(const std::string& ticker) const
    {
        std::error_code ec;
        t_float_50      balance(my_balance(ticker, ec));
        return balance;
    }

    std::pair<t_transactions, t_tx_state>
    mm2_service::get_tx(t_mm2_ec& ec) const noexcept
    {
        const auto& ticker = get_current_ticker();
        //SPDLOG_DEBUG("asking history of ticker: {}", ticker);
        const auto underlying_tx_history_map = m_tx_informations.synchronize();
        const auto coin_type                 = get_coin_info(ticker).coin_type;
        const auto it = !(coin_type == CoinType::ERC20) ? underlying_tx_history_map->find("result") : underlying_tx_history_map->find(ticker);
        if (it == underlying_tx_history_map->cend())
        {
            ec = dextop_error::tx_history_of_a_non_enabled_coin;
            return {};
        }
        return it->second;
    }

    t_tx_state
    mm2_service::get_tx_state(t_mm2_ec& ec) const
    {
        return get_tx(ec).second;
    }

    t_transactions
    mm2_service::get_tx_history(t_mm2_ec& ec) const
    {
        return get_tx(ec).first;
    }

    std::string
    mm2_service::my_balance(const std::string& ticker, t_mm2_ec& ec) const
    {
        std::shared_lock lock(m_balance_mutex); ///! read
        auto             it = m_balance_informations.find(ticker);
        if (it == m_balance_informations.cend())
        {
            ec = dextop_error::balance_of_a_non_enabled_coin;
            return "0";
        }

        return it->second.balance;
    }

    void
    mm2_service::batch_fetch_orders_and_swap(bool after_manual_reset)
    {
        nlohmann::json batch             = nlohmann::json::array();
        nlohmann::json my_orders_request = ::mm2::api::template_request("my_orders");
        batch.push_back(my_orders_request);


        //! Swaps preparation
        std::size_t       total           = 0;
        std::size_t       nb_active_swaps = 0;
        std::size_t       current_page    = 0;
        std::size_t       limit           = 0;
        t_filtering_infos filter_infos;
        {
            auto value_ptr  = m_orders_and_swaps.synchronize();
            total           = value_ptr->total_swaps;
            nb_active_swaps = value_ptr->active_swaps;
            current_page    = value_ptr->current_page;
            limit           = value_ptr->limit;
            filter_infos    = value_ptr->filtering_infos;
        }

        //! First time fetch or current page
        nlohmann::json            my_swaps = ::mm2::api::template_request("my_recent_swaps");
        t_my_recent_swaps_request request{
            .limit          = limit,
            .page_number    = current_page,
            .my_coin        = filter_infos.my_coin,
            .other_coin     = filter_infos.other_coin,
            .from_timestamp = filter_infos.from_timestamp,
            .to_timestamp   = filter_infos.to_timestamp,
        };
        to_json(my_swaps, request);
        batch.push_back(my_swaps);

        //! Active swaps
        nlohmann::json         active_swaps = ::mm2::api::template_request("active_swaps");
        t_active_swaps_request active_swaps_request{.statuses = true};
        to_json(active_swaps, active_swaps_request);
        batch.push_back(active_swaps);

        auto answer_functor = [this, limit, filter_infos, after_manual_reset](web::http::http_response resp) {
            spdlog::stopwatch stopwatch;

            //! Parsing Resp
            orders_and_swaps result;
            auto             answers = ::mm2::api::basic_batch_answer(resp);

            //! Extract
            const auto orders_answers      = ::mm2::api::rpc_process_answer_batch<t_my_orders_answer>(answers[0], "my_orders");
            const auto swap_answer         = ::mm2::api::rpc_process_answer_batch<t_my_recent_swaps_answer>(answers[1], "my_recent_swaps");
            const auto active_swaps_answer = ::mm2::api::rpc_process_answer_batch<t_active_swaps_answer>(answers[2], "active_swaps");

            result.orders_and_swaps.reserve(orders_answers.orders.size() + limit);
            result.nb_orders        = orders_answers.orders.size();
            result.orders_and_swaps = std::move(orders_answers.orders);
            result.orders_registry  = std::move(orders_answers.orders_id);
            result.limit            = limit;
            result.filtering_infos  = filter_infos;

            //! Recent swaps
            result.active_swaps = active_swaps_answer.uuids.size();
            for (auto&& cur: active_swaps_answer.swaps)
            {
                const auto uuid = cur.order_id.toStdString();
                result.swaps_registry.emplace(uuid);
                result.orders_and_swaps.emplace_back(std::move(cur));
            }

            //! Swaps
            if (swap_answer.result.has_value())
            {
                const auto& swap_success_answer = swap_answer.result.value();
                result.total_swaps              = swap_success_answer.total;
                result.total_finished_swaps     = result.total_swaps - active_swaps_answer.uuids.size();
                result.current_page             = swap_success_answer.page_number;
                result.nb_pages                 = swap_success_answer.total_pages;
                for (auto&& cur: swap_success_answer.swaps)
                {
                    const auto uuid = cur.order_id.toStdString();
                    if (!result.swaps_registry.contains(uuid))
                    {
                        result.swaps_registry.emplace(uuid);
                        result.orders_and_swaps.emplace_back(std::move(cur));
                    }
                }
                result.average_events_time = std::move(swap_success_answer.average_events_time);
            }

            //! Post Metrics
            /*SPDLOG_INFO(
                "Metrics -> [total_swaps: {}, "
                "active_swaps: {}, "
                "nb_orders: {}, "
                "nb_pages: {}, "
                "current_page: {}, "
                "total_finished_swaps: {}]",
                result.total_swaps, result.active_swaps, result.nb_orders, result.nb_pages, result.current_page, result.total_finished_swaps);*/

            //! Compute everything
            m_orders_and_swaps = std::move(result);

            //SPDLOG_INFO("Time elasped for batch_orders_and_swaps: {} seconds", stopwatch);
            this->dispatcher_.trigger<process_swaps_and_orders_finished>(after_manual_reset);
        };

        ::mm2::api::async_rpc_batch_standalone(batch, m_mm2_client, m_token_source.get_token())
            .then(answer_functor)
            .then([this](pplx::task<void> previous_task) { this->handle_exception_pplx_task(previous_task); });
    }

    void
    mm2_service::process_tx_etherscan(const std::string& ticker, [[maybe_unused]] bool is_a_refresh)
    {
        SPDLOG_DEBUG("process_tx ticker: {}", ticker);
        std::error_code ec;
        using namespace std::string_literals;
        std::string url =
            (ticker == "ETH") ? "/api/v1/eth_tx_history/"s + address(ticker, ec) : "/api/v1/erc_tx_history/"s + ticker + "/" + address(ticker, ec);
        ::mm2::api::async_process_rpc_get(::mm2::api::g_etherscan_proxy_http_client, "tx_history", url)
            .then([this, ticker](web::http::http_response resp) {
                auto answer = ::mm2::api::rpc_process_answer<::mm2::api::tx_history_answer>(resp, "tx_history");

                if (answer.rpc_result_code != 200)
                {
                    SPDLOG_ERROR("{}", answer.raw_result);
                    this->dispatcher_.trigger<tx_fetch_finished>();
                }
                else if (answer.rpc_result_code not_eq -1 and answer.result.has_value())
                {
                    t_tx_state state;
                    state.state             = "Finished";
                    state.current_block     = 0;
                    state.blocks_left       = 0;
                    state.transactions_left = 0;

                    if (answer.result.value().sync_status.additional_info.has_value())
                    {
                        if (answer.result.value().sync_status.additional_info.value().erc_infos.has_value())
                        {
                            state.blocks_left = answer.result.value().sync_status.additional_info.value().erc_infos.value().blocks_left;
                        }
                        if (answer.result.value().sync_status.additional_info.value().regular_infos.has_value())
                        {
                            state.transactions_left = answer.result.value().sync_status.additional_info.value().regular_infos.value().transactions_left;
                        }
                    }

                    t_transactions out;
                    out.reserve(answer.result.value().transactions.size());

                    const auto& transactions = answer.result.value().transactions;
                    std::for_each(rbegin(transactions), rend(transactions), [&out, this](auto&& current) {
                        tx_infos current_info{
                            .am_i_sender       = current.my_balance_change[0] == '-',
                            .confirmations     = current.confirmations.has_value() ? current.confirmations.value() : 0,
                            .from              = current.from,
                            .to                = current.to,
                            .date              = current.timestamp_as_date,
                            .timestamp         = current.timestamp,
                            .tx_hash           = current.tx_hash,
                            .fees              = current.fee_details.normal_fees.has_value() ? current.fee_details.normal_fees.value().amount
                                                                                             : current.fee_details.erc_fees.value().total_fee,
                            .my_balance_change = current.my_balance_change,
                            .total_amount      = current.total_amount,
                            .block_height      = current.block_height,
                            .ec                = dextop_error::success,
                        };

                        const auto& wallet_manager    = this->m_system_manager.get_system<qt_wallet_manager>();
                        current_info.transaction_note = wallet_manager.retrieve_transactions_notes(current_info.tx_hash);
                        out.push_back(std::move(current_info));
                    });

                    //! History
                    m_tx_informations->insert_or_assign(ticker, std::make_pair(out, state));

                    //! Dispatch
                    this->dispatcher_.trigger<tx_fetch_finished>();
                }
            })
            .then([this](pplx::task<void> previous_task) { this->handle_exception_pplx_task(previous_task); });
    }

    void
    mm2_service::on_refresh_orderbook(const orderbook_refresh& evt)
    {
        SPDLOG_DEBUG("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

        SPDLOG_INFO("refreshing orderbook pair: [{} / {}]", evt.base, evt.rel);
        this->m_synchronized_ticker_pair = std::make_pair(evt.base, evt.rel);

        if (this->m_mm2_running)
        {
            batch_process_fees_and_fetch_current_orderbook_thread(true);
        }
    }

    void
    mm2_service::on_gui_enter_trading([[maybe_unused]] const gui_enter_trading& evt) noexcept
    {
        SPDLOG_DEBUG("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());

        m_orderbook_thread_active = true;
    }

    void
    mm2_service::on_gui_leave_trading([[maybe_unused]] const gui_leave_trading& evt) noexcept
    {
        SPDLOG_DEBUG("{} l{} f[{}]", __FUNCTION__, __LINE__, fs::path(__FILE__).filename().string());
        m_orderbook_thread_active = false;
    }

    bool
    mm2_service::do_i_have_enough_funds(const std::string& ticker, const t_float_50& amount) const
    {
        t_float_50 funds = get_balance(ticker);
        return funds >= amount;
    }

    std::string
    mm2_service::address(const std::string& ticker, t_mm2_ec& ec) const noexcept
    {
        std::shared_lock lock(m_balance_mutex);
        auto             it = m_balance_informations.find(ticker);

        if (it == m_balance_informations.cend())
        {
            ec = dextop_error::unknown_ticker;
            return "Invalid";
        }

        return it->second.address;
    }

    t_float_50
    mm2_service::get_trading_fees(const std::string& ticker, const std::string& sell_amount, bool is_max) const
    {
        t_float_50 sell_amount_f(sell_amount);
        if (is_max)
        {
            std::error_code ec;
            sell_amount_f = t_float_50(my_balance(ticker, ec));
        }

        return t_float_50(1) / t_float_50(777) * sell_amount_f;
    }

    std::string
    mm2_service::apply_specific_fees(const std::string& ticker, t_float_50& value) const
    {
        if (auto coin_info = get_coin_info(ticker);
            (coin_info.coin_type == CoinType::ERC20) || (coin_info.coin_type == CoinType::QRC20 && !coin_info.electrum_urls.has_value()))
        {
            SPDLOG_INFO("Calculating specific fees of rel ticker: {}", ticker);
            const auto& answer = get_transaction_fees(ticker);
            const auto  amount = answer.amount;
            if (not amount.empty())
            {
                value += t_float_50(amount);
            }
            return answer.coin;
        }

        return "";
    }

    t_get_trade_fee_answer
    mm2_service::get_transaction_fees(const std::string& ticker) const
    {
        auto underlying_map = m_trade_fees_registry.synchronize();
        if (auto it = underlying_map->find(ticker); it != underlying_map->end())
        {
            return it->second;
        }
        else
        {
            return {};
        }
    }

    bool
    mm2_service::is_orderbook_thread_active() const noexcept
    {
        return this->m_orderbook_thread_active.load();
    }

    nlohmann::json
    mm2_service::get_raw_mm2_ticker_cfg(const std::string& ticker) const noexcept
    {
        nlohmann::json out;

        std::shared_lock lock(m_raw_coin_cfg_mutex);
        const auto       it = m_mm2_raw_coins_cfg.find(ticker);
        if (it != m_mm2_raw_coins_cfg.end())
        {
            atomic_dex::coin_element element = it->second;
            to_json(out, element);
            return out;
        }
        return nlohmann::json::object();
    }

    mm2_service::t_pair_max_vol
    mm2_service::get_taker_vol() const noexcept
    {
        return m_synchronized_max_taker_vol.get();
    }

    bool
    mm2_service::is_pin_cfg_enabled() const noexcept
    {
        return m_balance_factor != 1.0;
    }

    void
    mm2_service::reset_fake_balance_to_zero(const std::string& ticker) noexcept
    {
        {
            std::unique_lock lock(m_balance_mutex);
            m_balance_informations.at(ticker).balance = "0";
        }
        this->dispatcher_.trigger<ticker_balance_updated>(std::vector<std::string>{ticker});
    }

    void
    mm2_service::decrease_fake_balance(const std::string& ticker, const std::string& amount) noexcept
    {
        t_float_50 balance = get_balance(ticker);
        t_float_50 amount_f(amount);
        t_float_50 result = balance - amount_f;
        SPDLOG_DEBUG(
            "decreasing {} - {} = {}", balance.str(8, std::ios_base::fixed), amount_f.str(8, std::ios_base::fixed), result.str(8, std::ios_base::fixed));
        if (result < 0)
        {
            reset_fake_balance_to_zero(ticker);
        }
        else
        {
            {
                std::unique_lock lock(m_balance_mutex); //! Write
                m_balance_informations.at(ticker).balance = result.str(8, std::ios_base::fixed);
            }
            this->dispatcher_.trigger<ticker_balance_updated>(std::vector<std::string>{ticker});
        }
    }

    void
    mm2_service::process_tx_answer(const nlohmann::json& answer_json)
    {
        ::mm2::api::tx_history_answer answer;
        ::mm2::api::from_json(answer_json, answer);
        t_tx_state state;
        state.state             = answer.result.value().sync_status.state;
        state.current_block     = answer.result.value().current_block;
        state.blocks_left       = 0;
        state.transactions_left = 0;

        if (answer.result.value().sync_status.additional_info.has_value())
        {
            if (answer.result.value().sync_status.additional_info.value().erc_infos.has_value())
            {
                state.blocks_left = answer.result.value().sync_status.additional_info.value().erc_infos.value().blocks_left;
            }
            if (answer.result.value().sync_status.additional_info.value().regular_infos.has_value())
            {
                state.transactions_left = answer.result.value().sync_status.additional_info.value().regular_infos.value().transactions_left;
            }
        }

        t_transactions out;
        out.reserve(answer.result.value().transactions.size());

        for (auto&& current: answer.result.value().transactions)
        {
            tx_infos current_info{

                .am_i_sender       = current.my_balance_change[0] == '-',
                .confirmations     = current.confirmations.has_value() ? current.confirmations.value() : 0,
                .from              = current.from,
                .to                = current.to,
                .date              = current.timestamp_as_date,
                .timestamp         = current.timestamp,
                .tx_hash           = current.tx_hash,
                .my_balance_change = current.my_balance_change,
                .total_amount      = current.total_amount,
                .block_height      = current.block_height,
                .ec                = dextop_error::success,
            };
            if (current.fee_details.normal_fees.has_value())
            {
                current_info.fees = current.fee_details.normal_fees.value().amount;
            }
            else if (current.fee_details.erc_fees.has_value())
            {
                current_info.fees = current.fee_details.erc_fees.value().total_fee;
            }
            else if (current.fee_details.qrc_fees.has_value())
            {
                current_info.fees = current.fee_details.qrc_fees->miner_fee;
            }

            if (current_info.timestamp == 0)
            {
                using namespace std::chrono;
                current_info.timestamp   = duration_cast<seconds>(system_clock::now().time_since_epoch()).count();
                current_info.date        = utils::to_human_date<std::chrono::seconds>(current_info.timestamp, "%e %b %Y, %H:%M");
                current_info.unconfirmed = true;
            }

            const auto& wallet_manager    = this->m_system_manager.get_system<qt_wallet_manager>();
            current_info.transaction_note = wallet_manager.retrieve_transactions_notes(current_info.tx_hash);

            out.push_back(std::move(current_info));
        }


        //! History
        m_tx_informations->insert_or_assign("result", std::make_pair(out, state));
        this->dispatcher_.trigger<tx_fetch_finished>();
    }

    void
    mm2_service::process_balance_answer(const nlohmann::json& answer)
    {
        t_balance_answer answer_r;
        ::mm2::api::from_json(answer, answer_r);
        // SPDLOG_INFO("Successfully fetched ticker: {} balance: {} address: {}", answer_r.coin, answer_r.balance, answer_r.address);
        if (is_pin_cfg_enabled())
        {
            std::shared_lock lock(m_balance_mutex);

            if (m_balance_informations.find(answer_r.coin) != m_balance_informations.end())
            {
                return;
            }
        }

        t_float_50 result = t_float_50(answer_r.balance) * m_balance_factor;
        answer_r.balance  = result.str(8, std::ios_base::fixed);
        {
            std::unique_lock lock(m_balance_mutex);
            m_balance_informations[answer_r.coin] = std::move(answer_r);
        }
    }

    nlohmann::json
    mm2_service::prepare_process_fees_and_current_orderbook()
    {
        auto&& [orderbook_ticker_base, orderbook_ticker_rel] = m_synchronized_ticker_pair.get();
        if (orderbook_ticker_rel.empty() || orderbook_ticker_base.empty())
            return nlohmann::json::array();
        nlohmann::json          batch = nlohmann::json::array();
        t_get_trade_fee_request req_base{.coin = orderbook_ticker_base};
        nlohmann::json          current_request = ::mm2::api::template_request("get_trade_fee");
        ::mm2::api::to_json(current_request, req_base);
        batch.push_back(current_request);
        current_request = ::mm2::api::template_request("get_trade_fee");
        t_get_trade_fee_request req_rel{.coin = orderbook_ticker_rel};
        ::mm2::api::to_json(current_request, req_rel);
        batch.push_back(current_request);
        current_request = ::mm2::api::template_request("orderbook");
        t_orderbook_request req_orderbook{.base = orderbook_ticker_base, .rel = orderbook_ticker_rel};
        ::mm2::api::to_json(current_request, req_orderbook);
        batch.push_back(current_request);
        current_request = ::mm2::api::template_request("max_taker_vol");
        ::mm2::api::max_taker_vol_request req_base_max_taker_vol{.coin = orderbook_ticker_base, .trade_with = orderbook_ticker_rel};
        ::mm2::api::to_json(current_request, req_base_max_taker_vol);
        batch.push_back(current_request);
        current_request = ::mm2::api::template_request("max_taker_vol");
        ::mm2::api::max_taker_vol_request req_rel_max_taker_vol{.coin = orderbook_ticker_rel, .trade_with = orderbook_ticker_base};
        ::mm2::api::to_json(current_request, req_rel_max_taker_vol);
        batch.push_back(current_request);

        return batch;
    }

    /*void
    mm2_service::add_orders_answer(t_my_orders_answer answer)
    {
        //m_orders = answer;
        //this->dispatcher_.trigger<process_orders_finished>();
    }*/

    std::shared_ptr<t_http_client>
    mm2_service::get_mm2_client() noexcept
    {
        return m_mm2_client;
    }

    std::string
    mm2_service::get_current_ticker() const noexcept
    {
        return m_current_ticker.get();
    }

    bool
    mm2_service::set_current_ticker(const std::string& ticker) noexcept
    {
        if (ticker != get_current_ticker())
        {
            m_current_ticker = ticker;
            return true;
        }
        return false;
    }

    pplx::cancellation_token
    mm2_service::get_cancellation_token() const noexcept
    {
        return m_token_source.get_token();
    }

    void
    mm2_service::add_new_coin(const nlohmann::json& coin_cfg_json, const nlohmann::json& raw_coin_cfg_json) noexcept
    {
        //! Normal cfg part
        SPDLOG_DEBUG("[{}], [{}]", coin_cfg_json.dump(4), raw_coin_cfg_json.dump(4));
        if (not coin_cfg_json.empty() && not is_this_ticker_present_in_normal_cfg(coin_cfg_json.begin().key()))
        {
            SPDLOG_DEBUG("Adding entry : {} to adex current wallet coins file", coin_cfg_json.dump(4));
            fs::path       cfg_path = utils::get_atomic_dex_config_folder();
            std::string    filename = std::string(atomic_dex::get_raw_version()) + "-coins." + m_current_wallet_name + ".json";
            std::ifstream  ifs((cfg_path / filename).c_str());
            nlohmann::json config_json_data;
            assert(ifs.is_open());

            //! Read Contents
            ifs >> config_json_data;

            //! Modify contents
            config_json_data[coin_cfg_json.begin().key()] = coin_cfg_json.at(coin_cfg_json.begin().key());

            //! Close
            ifs.close();

            //! Write contents
            std::ofstream ofs((cfg_path / filename).c_str(), std::ios::trunc);
            assert(ofs.is_open());
            ofs << config_json_data;
        }
        if (not raw_coin_cfg_json.empty() && not is_this_ticker_present_in_raw_cfg(raw_coin_cfg_json.at("coin").get<std::string>()))
        {
            const fs::path mm2_cfg_path{atomic_dex::utils::get_current_configs_path() / "coins.json"};
            SPDLOG_DEBUG("Adding entry : {} to mm2 coins file {}", raw_coin_cfg_json.dump(4), mm2_cfg_path.string());
            std::ifstream  ifs(mm2_cfg_path.c_str());
            nlohmann::json config_json_data;
            assert(ifs.is_open());

            //! Read Contents
            ifs >> config_json_data;

            //! Modify contents
            config_json_data.push_back(raw_coin_cfg_json);

            //! Close
            ifs.close();

            //! Write contents
            std::ofstream ofs(mm2_cfg_path.c_str(), std::ios::trunc);
            assert(ofs.is_open());
            ofs << config_json_data;
        }
    }

    bool
    mm2_service::is_this_ticker_present_in_raw_cfg(const std::string& ticker) const noexcept
    {
        std::shared_lock lock(m_raw_coin_cfg_mutex);
        return m_mm2_raw_coins_cfg.find(ticker) != m_mm2_raw_coins_cfg.end();
    }

    bool
    mm2_service::is_this_ticker_present_in_normal_cfg(const std::string& ticker) const noexcept
    {
        std::shared_lock lock(m_coin_cfg_mutex);
        return m_coins_informations.find(ticker) != m_coins_informations.end();
    }

    void
    mm2_service::remove_custom_coin(const std::string& ticker) noexcept
    {
        //! Coin need to be disabled to be removed
        assert(not get_coin_info(ticker).currently_enabled);

        //! Remove from our cfg
        if (is_this_ticker_present_in_normal_cfg(ticker))
        {
            SPDLOG_DEBUG("remove it from normal cfg: {}", ticker);
            fs::path       cfg_path = utils::get_atomic_dex_config_folder();
            std::string    filename = std::string(atomic_dex::get_raw_version()) + "-coins." + m_current_wallet_name + ".json";
            std::ifstream  ifs((cfg_path / filename).c_str());
            nlohmann::json config_json_data;
            assert(ifs.is_open());

            //! Read Contents
            ifs >> config_json_data;

            {
                std::unique_lock lock(m_coin_cfg_mutex);
                this->m_coins_informations.erase(ticker);
            }

            config_json_data.erase(config_json_data.find(ticker));

            //! Close
            ifs.close();

            //! Write contents
            std::ofstream ofs((cfg_path / filename).c_str(), std::ios::trunc);
            assert(ofs.is_open());
            ofs << config_json_data;
        }

        if (is_this_ticker_present_in_raw_cfg(ticker))
        {
            SPDLOG_DEBUG("remove it from mm2 cfg: {}", ticker);
            fs::path       mm2_cfg_path{atomic_dex::utils::get_current_configs_path() / "coins.json"};
            std::ifstream  ifs(mm2_cfg_path.c_str());
            nlohmann::json config_json_data;
            assert(ifs.is_open());

            //! Read Contents
            ifs >> config_json_data;

            config_json_data.erase(std::find_if(begin(config_json_data), end(config_json_data), [ticker](nlohmann::json current_elem) {
                return current_elem.at("coin").get<std::string>() == ticker;
            }));

            //! Close
            ifs.close();

            //! Write contents
            std::ofstream ofs(mm2_cfg_path.c_str(), std::ios::trunc);
            assert(ofs.is_open());
            ofs << config_json_data;
        }
    }

    void
    mm2_service::add_get_trade_fee_answer(const std::string& ticker, t_get_trade_fee_answer answer) noexcept
    {
        this->m_trade_fees_registry->operator[](ticker) = answer;
    }

    std::vector<electrum_server>
    mm2_service::get_electrum_server_from_token(const std::string& ticker)
    {
        std::vector<electrum_server> servers;
        const coin_config            cfg = this->get_coin_info(ticker);
        if (cfg.coin_type == CoinType::QRC20)
        {
            if (cfg.is_testnet.value())
            {
                SPDLOG_INFO("{} is from testnet picking tQTUM electrum", ticker);
                servers = std::move(get_coin_info("tQTUM").electrum_urls.value());
            }
            else
            {
                SPDLOG_INFO("{} is from mainnet picking QTUM electrum", ticker);
                servers = std::move(get_coin_info("QTUM").electrum_urls.value());
            }
        }
        return servers;
    }

    orders_and_swaps
    mm2_service::get_orders_and_swaps() const noexcept
    {
        return m_orders_and_swaps.get();
    }

    void
    mm2_service::set_orders_and_swaps_pagination_infos(std::size_t current_page, std::size_t limit, t_filtering_infos filter_infos)
    {
        {
            m_orders_and_swaps = orders_and_swaps{.current_page = current_page, .limit = limit, .filtering_infos = std::move(filter_infos)};
        }
        this->batch_fetch_orders_and_swap(true);
    }

    void
    mm2_service::handle_exception_pplx_task(pplx::task<void> previous_task)
    {
        try
        {
            previous_task.wait();
        }
        catch (const std::exception& e)
        {
            SPDLOG_ERROR("pplx task error: {}", e.what());
#if defined(linux) || defined(__APPLE__)
            SPDLOG_ERROR("stacktrace: {}", boost::stacktrace::to_string(boost::stacktrace::stacktrace()));
#endif
            if (std::string(e.what()).find("Failed to read HTTP status line") != std::string::npos ||
                std::string(e.what()).find("WinHttpReceiveResponse: 12002: The operation timed out") != std::string::npos)
            {
                const auto& internet_service = this->m_system_manager.get_system<internet_service_checker>();
                if (!internet_service.is_internet_alive())
                {
                    SPDLOG_WARN("We should reset connection here");
                    this->dispatcher_.trigger<fatal_notification>("connection dropped");
                }
            }
        }
    }
} // namespace atomic_dex
