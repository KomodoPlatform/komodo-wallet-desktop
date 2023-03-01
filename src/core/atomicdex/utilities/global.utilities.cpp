//! STD Headers
#include <random>

#if defined(_WIN32) || defined(WIN32)
# define _UNICODE
# define UNICODE
# include <Windows.h>
#endif

//! Qt Headers
#include <QCryptographicHash>
#include <QString>

//! Project Headers
#include "atomicdex/utilities/global.utilities.hpp"
#include "atomicdex/version/version.hpp"

namespace
{
    std::string
    dex_sha256(const std::string& str)
    {
        QString res = QString(QCryptographicHash::hash((str.c_str()), QCryptographicHash::Keccak_256).toHex());
        return res.toStdString();
    }
} // namespace

namespace atomic_dex::utils
{
    std::string
    get_formated_float(t_float_50 value)
    {
        std::stringstream ss;
        ss.precision(8);
        ss << std::fixed << value;
        return ss.str();
    }

    std::string
    format_float(t_float_50 value)
    {
        std::string result = value.str(8, std::ios_base::fixed);
        boost::trim_right_if(result, boost::is_any_of("0"));
        boost::trim_right_if(result, boost::is_any_of("."));
        return result;
    }

    std::string
    adjust_precision(const std::string& current)
    {
        std::string       result;
        std::stringstream ss;
        t_float_50        current_f(safe_float(current));

        return format_float(current_f);
    }

    bool
    create_if_doesnt_exist(const fs::path& path)
    {
        if (not fs::exists(path))
        {
            LOG_PATH("creating directory {}", path);
            //SPDLOG_INFO("creating directory {}", path.string());
            fs::create_directories(path);
            return true;
        }
        return false;
    }

    double
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

    fs::path
    get_atomic_dex_data_folder()
    {
        fs::path appdata_path;
#if defined(_WIN32) || defined(WIN32)
        std::wstring out = _wgetenv(L"APPDATA");
        appdata_path = fs::path(out) / DEX_APPDATA_FOLDER;
#elif defined(__APPLE__)
        appdata_path = fs::path(std::getenv("HOME")) / "Library" / "Application Support" / DEX_APPDATA_FOLDER;
#else
        appdata_path = fs::path(std::getenv("HOME")) / (std::string(".") + std::string(DEX_APPDATA_FOLDER));
#endif
        return appdata_path;
    }

    std::string
    u8string(const fs::path& p)
    {
#if defined(PREFER_BOOST_FILESYSTEM)
        return p.string();
#else
        auto res = p.u8string();

        auto functor = [](auto&& r) {
          if constexpr (std::is_same_v<std::remove_cvref_t<decltype(r)>, std::string>)
          {
              return r;
          }
          else
          {
              return std::string(r.begin(), r.end());
          }
        };
        return functor(res);
#endif
    }

    fs::path
    get_atomic_dex_addressbook_folder()
    {
        const auto fs_addr_book_path = get_atomic_dex_data_folder() / "addressbook";
        create_if_doesnt_exist(fs_addr_book_path);
        return fs_addr_book_path;
    }

    fs::path
    get_runtime_coins_path()
    {
        const auto fs_coins_path = get_atomic_dex_data_folder() / "custom_coins_icons";
        create_if_doesnt_exist(fs_coins_path);
        return fs_coins_path;
    }

    fs::path
    get_atomic_dex_logs_folder()
    {
        const auto fs_logs_path = get_atomic_dex_data_folder() / "logs";
        create_if_doesnt_exist(fs_logs_path);
        return fs_logs_path;
    }

    ENTT_API fs::path
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

    fs::path
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

    fs::path
    get_atomic_dex_config_folder()
    {
        const auto fs_cfg_path = get_atomic_dex_data_folder() / "config";
        create_if_doesnt_exist(fs_cfg_path);
        return fs_cfg_path;
    }

    fs::path
    get_atomic_dex_export_folder()
    {
        const auto fs_export_folder = get_atomic_dex_data_folder() / "exports";
        create_if_doesnt_exist(fs_export_folder);
        return fs_export_folder;
    }

    fs::path
    get_atomic_dex_current_export_recent_swaps_file()
    {
        return get_atomic_dex_export_folder() / ("swap-export.json");
    }

    void
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

    fs::path
    get_current_configs_path()
    {
        const auto fs_raw_mm2_shared_folder = get_atomic_dex_data_folder() / get_raw_version() / "configs";
        create_if_doesnt_exist(fs_raw_mm2_shared_folder);
        return fs_raw_mm2_shared_folder;
    }

    std::string
    extract_large_float(const std::string& current)
    {
        if (auto pos = current.find('.'); pos != std::string::npos)
        {
            return current.substr(0, pos + 9);
        }
        return current;
    }

    fs::path
    get_themes_path()
    {
        fs::path theme_path = get_atomic_dex_data_folder() / "themes";
        create_if_doesnt_exist(theme_path);
        return theme_path;
    }

    fs::path
    get_logo_path()
    {
        fs::path logo_path = get_atomic_dex_data_folder() / "logo";
        create_if_doesnt_exist(logo_path);
        return logo_path;
    }

    std::string
    retrieve_main_ticker(const std::string& ticker)
    {
        if (const auto pos = ticker.find('-'); pos != std::string::npos)
        {
            return ticker.substr(0, pos);
        }
        return ticker;
    }

    std::vector<std::string>
    coin_cfg_to_ticker_cfg(std::vector<coin_config> in)
    {
        std::vector<std::string> out;
        out.reserve(in.size());

        for (auto&& coin : in)
        {
            out.push_back(coin.ticker);
        }
        return out;
    }
} // namespace atomic_dex::utils
