#include <QJsonDocument>

//! Project Headers
#include "atomicdex/api/coingecko/coingecko.hpp"
#include "atomicdex/models/qt.portfolio.model.hpp"
#include "atomicdex/pages/qt.portfolio.page.hpp"
#include "atomicdex/pages/qt.settings.page.hpp"
#include "atomicdex/services/price/coingecko/coingecko.wallet.charts.hpp"
#include "atomicdex/services/price/global.provider.hpp"
#include "atomicdex/utilities/qt.utilities.hpp"

namespace
{
    std::string
    get_days_from_wallet_category(WalletChartsCategories category)
    {
        switch (category)
        {
        case atomic_dex::WalletChartsCategoriesGadget::OneDay:
            return "1";
        case atomic_dex::WalletChartsCategoriesGadget::OneWeek:
            return "7";
        case atomic_dex::WalletChartsCategoriesGadget::OneMonth:
            return "30";
        case atomic_dex::WalletChartsCategoriesGadget::Ytd:
            return "";
        case atomic_dex::WalletChartsCategoriesGadget::Size:
            return "";
        }
    }
} // namespace

//! Constructor / Destructor
namespace atomic_dex
{
    coingecko_wallet_charts_service::coingecko_wallet_charts_service(entt::registry& registry, ag::ecs::system_manager& system_manager) :
        system(registry), m_system_manager(system_manager)
    {
        SPDLOG_INFO("coingecko_wallet_charts_service created");
        m_update_clock = std::chrono::high_resolution_clock::now();
        this->disable();
    }

    coingecko_wallet_charts_service::~coingecko_wallet_charts_service() { SPDLOG_INFO("coingecko_wallet_charts_service destroyed"); }
} // namespace atomic_dex

//! Private member functions
namespace atomic_dex
{
    void
    coingecko_wallet_charts_service::generate_fiat_chart()
    {
        auto functor = [this]()
        {
            try
            {
                SPDLOG_INFO("Generate fiat chart");
                const auto     fiat           = m_system_manager.get_system<settings_page>().get_current_fiat().toStdString();
                t_float_50     rate           = safe_float(m_system_manager.get_system<global_price_service>().get_fiat_rates(fiat));
                auto           chart_registry = this->m_chart_data_registry.get();
                nlohmann::json out            = nlohmann::json::array();
                const auto&    data           = chart_registry.begin()->second;
                const auto&    kdf            = m_system_manager.get_system<kdf_service>();
                t_float_50     first_total    = 0;
                for (std::size_t idx = 0; idx < data.size(); idx++)
                {
                    nlohmann::json cur = nlohmann::json::object();
                    cur["timestamp"]   = data[idx][0].get<std::size_t>() / 1000;
                    // cur["human_date"]  = utils::to_human_date<std::chrono::milliseconds>(cur.at("timestamp").get<std::size_t>(), "%e %b %Y, %H:%M");
                    t_float_50 total(0);
                    bool       to_skip = false;
                    for (auto&& [key, value]: chart_registry)
                    {
                        if (idx >= value.size())
                        {
                            SPDLOG_ERROR("skipping idx: {}", idx);
                            to_skip = true;
                            continue;
                        }
                        t_float_50 cur_total = (t_float_50(value[idx][1].get<float>()) * kdf.get_balance_info_f(key)) * rate;
                        total += cur_total;
                    }
                    if (to_skip)
                    {
                        continue;
                    }
                    if (safe_float(m_min_value) <= 0 || total < safe_float(m_min_value))
                    {
                        m_min_value = utils::format_float(total);
                    }
                    if (total > safe_float(m_max_value))
                    {
                        m_max_value = utils::format_float(total);
                    }
                    cur["total"] = utils::format_float(total);
                    if (idx == 0)
                    {
                        first_total = total;
                    }
                    out.push_back(cur);
                }
                auto        now                  = std::chrono::system_clock::now();
                std::size_t timestamp            = std::chrono::duration_cast<std::chrono::seconds>(now.time_since_epoch()).count();
                out[out.size() - 1]["timestamp"] = timestamp;
                out[out.size() - 1]["total"]     = m_system_manager.get_system<portfolio_page>().get_main_balance_fiat_all().toStdString();
                t_float_50 total                 = safe_float(out[out.size() - 1].at("total").get<std::string>());
                if (total > safe_float(m_max_value))
                {
                    m_max_value = out[out.size() - 1].at("total").get<std::string>();
                }
                t_float_50  wallet_perf_f = total - first_total;
                std::string wallet_perf   = utils::format_float(wallet_perf_f);
                std::string ratio         = utils::format_float(wallet_perf_f / first_total);
                std::string percent       = utils::format_float((wallet_perf_f / first_total) * 100);
                QJsonObject obj;
                obj.insert("change", QString::fromStdString(wallet_perf));
                obj.insert("ratio", QString::fromStdString(ratio));
                obj.insert("percent", QString::fromStdString(percent));
                obj.insert("last_total_balance_fiat_all", m_system_manager.get_system<portfolio_page>().get_main_balance_fiat_all());
                obj.insert("initial_total_balance_fiat_all", QString::fromStdString(utils::format_float(first_total)));
                obj.insert("all_time_low", QString::fromStdString(m_min_value));
                obj.insert("all_time_high", QString::fromStdString(m_max_value));
                obj.insert("nb_elements", qint64(out.size()));
                m_wallet_performance->insert("wallet_evolution", obj);
                m_min_value = utils::format_float(safe_float(m_min_value) * 0.9);
                m_max_value = utils::format_float(safe_float(m_max_value) * 1.1);
                // SPDLOG_INFO("metrics: {}", QString(QJsonDocument(*m_wallet_performance).toJson()).toStdString());
                m_fiat_charts = std::move(out);
            }
            catch (const std::exception& error)
            {
                SPDLOG_ERROR("Exception caught: {}", error.what());
            }
        };
        functor();
        SPDLOG_INFO("Fetching new charts is finished, emitting event to front-end");
        this->m_is_busy    = false;
        auto& portfolio_pg = m_system_manager.get_system<portfolio_page>();
        emit  portfolio_pg.chartBusyChanged();
        emit  portfolio_pg.chartsChanged();
        emit  portfolio_pg.minTotalChartChanged();
        emit  portfolio_pg.maxTotalChartChanged();
        emit  portfolio_pg.walletStatsChanged();
    }

    QVariant
    coingecko_wallet_charts_service::get_wallet_stats() const
    {
        return QVariant(m_wallet_performance.get());
    }

    void
    coingecko_wallet_charts_service::fetch_data_of_single_coin(const coin_config_t& cfg)
    {
        using namespace std::chrono_literals;
        SPDLOG_INFO("fetch charts data of {} {}", cfg.ticker, cfg.coingecko_id);
        std::function<void(WalletChartsCategories, std::string)> market_functor;

        market_functor = [this, cfg, &market_functor](WalletChartsCategories category, std::string days)
        {
            //! 30 days
            {
                try
                {
                    web::http::http_response resp;
                    if (days.empty() && category >= WalletChartsCategories::Ytd)
                    {
                        auto                 now           = std::chrono::system_clock::now();
                        std::size_t          timestamp     = std::chrono::duration_cast<std::chrono::seconds>(now.time_since_epoch()).count();
                        date::year_month_day today         = date::floor<date::days>(std::chrono::system_clock::now());
                        std::size_t          ytd_timestamp = date::sys_seconds{date::sys_days{today.year() / 1 / 1}}.time_since_epoch().count();
                        t_coingecko_market_chart_range_request request{
                            .id = cfg.coingecko_id, .vs_currency = "usd", .from = std::to_string(ytd_timestamp), .to = std::to_string(timestamp)};
                        resp = atomic_dex::coingecko::api::async_market_charts_range(std::move(request)).get();
                    }
                    else
                    {
                        t_coingecko_market_chart_request request{.id = cfg.coingecko_id, .vs_currency = "usd", .days = days, .interval = "daily"};
                        resp = atomic_dex::coingecko::api::async_market_charts(std::move(request)).get();
                    }
                    std::string body = TO_STD_STR(resp.extract_string(true).get());
                    if (resp.status_code() == 200)
                    {
                        m_chart_data_registry->operator[](cfg.ticker) = nlohmann::json::parse(body).at("prices");
                        SPDLOG_INFO("Successfully retrieve chart data for: {} {}", cfg.ticker, cfg.coingecko_id);
                    }
                    else
                    {
                        std::this_thread::sleep_for(1s);
                        market_functor(category, days);
                    }
                }
                catch (const std::exception& error)
                {
                    SPDLOG_ERROR("Caught exception: {} - retrying.", error.what());
                    std::this_thread::sleep_for(1s);
                    market_functor(category, days);
                }
            }
        };
        auto current_category = m_system_manager.get_system<portfolio_page>().get_chart_category();
        market_functor(current_category, get_days_from_wallet_category(current_category));
    }

    void
    coingecko_wallet_charts_service::fetch_all_charts_data()
    {
        SPDLOG_INFO("fetch all charts data");

        const auto coins           = this->m_system_manager.get_system<portfolio_page>().get_global_cfg()->get_enabled_coins();
        auto*      portfolio_model = this->m_system_manager.get_system<portfolio_page>().get_portfolio();
        auto       final_task      = m_taskflow.emplace([this]() { this->generate_fiat_chart(); }).name("Post task");
        auto       active_coins    = m_system_manager.get_system<kdf_service>().get_active_coins().size();

        SPDLOG_INFO("active_coins: {} coins_size: {}", active_coins, coins.size());
        if (active_coins == coins.size())
        {
            this->m_is_busy = true;
            emit        m_system_manager.get_system<portfolio_page>().chartBusyChanged();
            QJsonObject best_performer;
            QJsonObject worst_performer;
            std::string best_change_24h("");
            std::string worst_change_24h("");
            for (auto&& [coin, cfg]: coins)
            {
                if (cfg.coingecko_id == "test-coin")
                {
                    continue;
                }
                // SPDLOG_INFO("retrieve coin: {}", coin);
                auto res = portfolio_model->match(
                    portfolio_model->index(0, 0), portfolio_model::TickerRole, QString::fromStdString(coin), 1, Qt::MatchFlag::MatchExactly);
                // assert(not res.empty());
                if (not res.empty())
                {
                    t_float_50 balance = safe_float(portfolio_model->data(res.at(0), portfolio_model::MainCurrencyBalanceRole).toString().toStdString());
                    // SPDLOG_INFO("coin: {} not empty - checking now - balance: {}", coin, utils::format_float(balance));
                    if (balance > 0)
                    {
                        t_float_50 cur_change_24h = safe_float(portfolio_model->data(res.at(0), portfolio_model::Change24H).toString().toStdString());

                        if (worst_change_24h.empty() || cur_change_24h < safe_float(worst_change_24h))
                        {
                            worst_change_24h           = utils::format_float(cur_change_24h);
                            worst_performer["ticker"]  = QString::fromStdString(coin);
                            worst_performer["percent"] = QString::fromStdString(worst_change_24h);
                        }
                        if (best_change_24h.empty() || cur_change_24h > safe_float(best_change_24h))
                        {
                            best_change_24h           = utils::format_float(cur_change_24h);
                            best_performer["ticker"]  = QString::fromStdString(coin);
                            best_performer["percent"] = QString::fromStdString(best_change_24h);
                        }
                        final_task.succeed(m_taskflow.emplace([this, cfg = cfg]() { fetch_data_of_single_coin(cfg); }).name(cfg.ticker));
                    }
                }
            }
            if (m_taskflow.num_tasks() == 1)
            {
                SPDLOG_INFO("taskflow: {}", m_taskflow.dump());
                SPDLOG_WARN("No coins available for chart update - skipping");
                m_is_busy = false;
                emit m_system_manager.get_system<portfolio_page>().chartBusyChanged();
            }
            else
            {
                m_wallet_performance->insert("best_performance", best_performer);
                m_wallet_performance->insert("worst_performance", worst_performer);
                SPDLOG_INFO("taskflow: {}", m_taskflow.dump());
                m_executor.run(m_taskflow);
            }
        }
    }
} // namespace atomic_dex

//! Public override
namespace atomic_dex
{
    void
    coingecko_wallet_charts_service::update()
    {
        using namespace std::chrono_literals;

        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - m_update_clock);
        if (s >= 1h)
        {
            {
                SPDLOG_INFO("Waiting for previous call to be finished");
                m_executor.wait_for_all();
                m_taskflow.clear();
                m_chart_data_registry->clear();
                m_min_value          = "0";
                m_max_value          = "0";
                m_wallet_performance = QJsonObject();
            }
            fetch_all_charts_data();
            m_update_clock = std::chrono::high_resolution_clock::now();
        }
    }
} // namespace atomic_dex

//! Public member functions
namespace atomic_dex
{
    void
    coingecko_wallet_charts_service::manual_refresh(const std::string& from)
    {
        if (this->is_enabled())
        {
            SPDLOG_INFO("manual refresh from: {}", from);
            const auto wallet_obj       = m_wallet_performance.get();
            const bool is_valid         = wallet_obj.contains("wallet_evolution");
            const auto balance_fiat_all = m_system_manager.get_system<portfolio_page>().get_main_balance_fiat_all();
            if (is_valid && from.find("set_chart_category") == std::string::npos)
            {
                const auto previous = wallet_obj["wallet_evolution"].toObject().value("last_total_balance_fiat_all").toString();
                if (previous == balance_fiat_all)
                {
                    SPDLOG_INFO("Skipping refresh, balance doesn't change between last calls");
                    return;
                }
            }
            if (m_is_busy)
            {
                SPDLOG_WARN("Service is busy, try later");
                return;
            }
            auto functor = [this]()
            {
                try
                {
                    {
                        SPDLOG_INFO("Waiting for previous call to be finished");
                        m_executor.wait_for_all();
                        m_taskflow.clear();
                        m_chart_data_registry->clear();
                        m_min_value          = "0";
                        m_max_value          = "0";
                        m_wallet_performance = QJsonObject();
                    }
                    fetch_all_charts_data();
                    m_update_clock = std::chrono::high_resolution_clock::now();
                }
                catch (const std::exception& error)
                {
                    SPDLOG_ERROR("Exception caught: {}", error.what());
                }
            };
            //[[maybe_unused]] auto res = std::async(functor);
            functor();
        }
    }

    bool
    coingecko_wallet_charts_service::is_busy() const
    {
        return m_is_busy.load();
    }

    QVariant
    coingecko_wallet_charts_service::get_charts() const
    {
        return atomic_dex::nlohmann_json_array_to_qt_json_array(m_fiat_charts.get());
    }

    QString
    coingecko_wallet_charts_service::get_min_total() const
    {
        return QString::fromStdString(m_min_value);
    }
    QString
    coingecko_wallet_charts_service::get_max_total() const
    {
        return QString::fromStdString(m_max_value);
    }

    int
    coingecko_wallet_charts_service::get_neareast_point(int timestamp)
    {
        nlohmann::json res = m_fiat_charts.get();
        auto it = std::lower_bound(begin(res), end(res), timestamp, [](const nlohmann::json& current_json, int timestamp) {
          int res = current_json.at("timestamp").get<std::size_t>();
          return res < timestamp;
        });
        if (it != res.end())
        {
            auto idx = std::distance(begin(res), it);
            return idx;
        }
        return 0;
    }
} // namespace atomic_dex