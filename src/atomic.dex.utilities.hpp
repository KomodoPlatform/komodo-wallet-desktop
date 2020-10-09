#pragma once

//! STD
#include <random>

//! Deps
#include <nlohmann/json.hpp>
#include <date/date.h>
#include <date/tz.h>

//! QT Headers
#include <QCryptographicHash>
#include <QString>

static inline void
create_if_doesnt_exist(const fs::path& path)
{
    if (not fs::exists(path))
    {
        fs::create_directories(path);
    }
}

inline double
determine_balance_factor(bool with_pin_cfg)
{
    if (not with_pin_cfg)
    {
        return 1.0;
    }

    std::random_device               rd;
    std::mt19937                     gen(rd());
    std::uniform_real_distribution<> distr(0.01, 0.05);
    return distr(gen);
}

template <typename TimeFormat = std::chrono::milliseconds>
inline std::string
to_human_date(std::size_t timestamp, std::string format)
{
    using namespace date;

    const sys_time<TimeFormat> tp{TimeFormat{timestamp}};

    try
    {
        const auto tp_zoned = date::make_zoned(current_zone(), tp);
        return date::format(std::move(format), tp_zoned);
    }
    catch (const std::exception& error)
    {
        return date::format(std::move(format), tp);
    }
}

inline fs::path
get_atomic_dex_data_folder()
{
    fs::path appdata_path;
#if defined(_WIN32) || defined(WIN32)
    appdata_path = fs::path(std::getenv("APPDATA")) / "atomic_qt";
#else
    appdata_path = fs::path(std::getenv("HOME")) / ".atomic_qt";
#endif
    return appdata_path;
}

inline fs::path
get_runtime_coins_path() noexcept
{
    const auto fs_coins_path = get_atomic_dex_data_folder() / "custom_coins_icons";
    create_if_doesnt_exist(fs_coins_path);
    return fs_coins_path;
}

inline fs::path
get_atomic_dex_logs_folder() noexcept
{
    const auto fs_logs_path = get_atomic_dex_data_folder() / "logs";
    create_if_doesnt_exist(fs_logs_path);
    return fs_logs_path;
}

inline fs::path
get_atomic_dex_current_log_file()
{
    using namespace std::chrono;
    using namespace date;
    static auto              timestamp = duration_cast<seconds>(system_clock::now().time_since_epoch()).count();
    static date::sys_seconds tp{seconds{timestamp}};
    static std::string       s        = date::format("%Y-%m-%d-%H-%M-%S", tp);
    static const fs::path    log_path = get_atomic_dex_logs_folder() / (s + ".log");
    return log_path;
}

inline fs::path
get_mm2_atomic_dex_current_log_file()
{
    using namespace std::chrono;
    using namespace date;
    static auto              timestamp = duration_cast<seconds>(system_clock::now().time_since_epoch()).count();
    static date::sys_seconds tp{seconds{timestamp}};
    static std::string       s        = date::format("%Y-%m-%d-%H-%M-%S", tp);
    static const fs::path    log_path = get_atomic_dex_logs_folder() / (s + ".mm2.log");
    return log_path;
}

inline fs::path
get_atomic_dex_config_folder()
{
    const auto fs_cfg_path = get_atomic_dex_data_folder() / "config";
    create_if_doesnt_exist(fs_cfg_path);
    return fs_cfg_path;
}

inline const std::string
minimal_trade_amount_str()
{
    return "0.00777";
}

inline const t_float_50
minimal_trade_amount()
{
    return t_float_50(minimal_trade_amount_str());
}

inline fs::path
get_atomic_dex_export_folder()
{
    const auto fs_export_folder = get_atomic_dex_data_folder() / "exports";
    create_if_doesnt_exist(fs_export_folder);
    return fs_export_folder;
}

inline fs::path
get_atomic_dex_current_export_recent_swaps_file()
{
    return get_atomic_dex_export_folder() / ("swap-export.json");
}

inline std::string
dex_sha256(const std::string& str)
{
    QString res = QString(QCryptographicHash::hash((str.c_str()), QCryptographicHash::Keccak_256).toHex());
    return res.toStdString();
}

inline void
to_eth_checksum(std::string& address)
{
    address                = address.substr(2);
    auto hex_str           = dex_sha256(address);
    auto final_eth_address = std::string("0x");

    for (std::string::size_type i = 0; i < address.size(); i++)
    {
        std::string actual(1, hex_str[i]);
        try
        {
            auto value = std::stoi(actual, nullptr, 16);
            if (value >= 8)
            {
                final_eth_address += toupper(address[i]);
            }
            else
            {
                final_eth_address += address[i];
            }
        }
        catch (const std::invalid_argument& e)
        {
            final_eth_address += address[i];
        }
    }
    address = final_eth_address;
}

struct timed_waiter
{
    void
    interrupt()
    {
        auto l      = lock();
        interrupted = true;
        cv.notify_one();
    }

    template <class Rep, class Period>
    bool
    wait_for(std::chrono::duration<Rep, Period> how_long) const
    {
        auto l = lock();
        return cv.wait_for(l, how_long, [&] { return interrupted; });
    }

  private:
    std::unique_lock<std::mutex>
    lock() const
    {
        return std::unique_lock<std::mutex>(m, std::try_to_lock);
    }

    mutable std::mutex              m;
    mutable std::condition_variable cv;
    bool                            interrupted = false;
};


namespace atomic_dex::utils
{
    struct my_json_sax : nlohmann::json_sax<nlohmann::json>
    {
        bool binary([[maybe_unused]] binary_t& val) override
        {
            return true;
        }

        bool
        null() override
        {
            return true;
        }

        bool
        boolean([[maybe_unused]] bool val) override
        {
            return true;
        }

        bool
        number_integer([[maybe_unused]] number_integer_t val) override
        {
            return true;
        };

        bool
        number_unsigned([[maybe_unused]] number_unsigned_t val) override
        {
            return true;
        };

        bool
        number_float([[maybe_unused]] number_float_t val, [[maybe_unused]] const string_t& s) override
        {
            this->float_as_string = s;
            return true;
        }

        bool
        string([[maybe_unused]] string_t& val) override
        {
            return true;
        }

        bool
        start_object([[maybe_unused]] std::size_t elements) override
        {
            return true;
        }

        bool
        key([[maybe_unused]] string_t& val) override
        {
            return true;
        }

        bool
        end_object() override
        {
            return true;
        }

        bool
        start_array([[maybe_unused]] std::size_t elements) override
        {
            return true;
        }

        bool
        end_array() override
        {
            return true;
        }

        bool
        parse_error(
            [[maybe_unused]] std::size_t position, [[maybe_unused]] const std::string& last_token,
            [[maybe_unused]] const nlohmann::detail::exception& ex) override
        {
            return false;
        };

        std::string float_as_string;
    };
} // namespace atomic_dex::utils