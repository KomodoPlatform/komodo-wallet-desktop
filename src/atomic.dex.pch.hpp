#pragma once

#if defined(_WIN32) || defined(WIN32)
	#define GLOG_NO_ABBREVIATED_SEVERITIES
#endif

//! Global Helpers
#include <boost/filesystem.hpp>

namespace fs = boost::filesystem;

constexpr std::size_t operator"" _sz(unsigned long long n) { return n; }

template <typename T>
constexpr std::size_t
bit_size() noexcept
{
    return sizeof(T) * CHAR_BIT;
}

template <class Key, class T, class Compare, class Alloc, class Pred>
void
erase_if(std::map<Key, T, Compare, Alloc>& c, Pred pred)
{
    for (auto i = c.begin(), last = c.end(); i != last;)
    {
        if (pred(*i))
        {
            i = c.erase(i);
        }
        else
        {
            ++i;
        }
    }
}

template <class... Ts>
struct overloaded : Ts...
{
    using Ts::operator()...;
};
template <class... Ts>
overloaded(Ts...) -> overloaded<Ts...>;



//! Boost Headers
#include <boost/algorithm/string/trim.hpp>
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
#include <boost/multiprecision/cpp_dec_float.hpp>
#include <boost/multiprecision/cpp_int.hpp>
using t_float_50 = boost::multiprecision::cpp_dec_float_50;
using t_rational = boost::multiprecision::cpp_rational;

inline std::string
get_formated_float(t_float_50 value)
{
    std::stringstream ss;
    ss.precision(8);
    ss << std::fixed << value;
    return ss.str();
}

inline std::string
adjust_precision(const std::string& current)
{
    std::string       result;
    std::stringstream ss;
    t_float_50        current_f(current);

    ss << std::fixed << std::setprecision(8) << current_f;
    result = ss.str();

    boost::trim_right_if(result, boost::is_any_of("0"));
    boost::trim_right_if(result, boost::is_any_of("."));
    return result;
}

#pragma clang diagnostic pop

#if defined(_WIN32) || defined(WIN32)
#    define and &&
#    define or ||
#    define not !
#endif

#include <nlohmann/json.hpp>
#include <spdlog/async.h>
#include <spdlog/sinks/rotating_file_sink.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/spdlog.h>
/*#include <entt/entity/helper.hpp>
#include <entt/signal/dispatcher.hpp>
#include <meta/detection/detection.hpp>



#include <reproc++/reproc.hpp>
#include <restclient-cpp/connection.h>
#include <restclient-cpp/restclient.h>
#include <sodium.h>*/

//! CPPRESTSDK
#define _TURN_OFF_PLATFORM_STRING
#include <cpprest/http_client.h>
#ifdef _WIN32
#    define TO_STD_STR(ws_str) utility::conversions::to_utf8string(ws_str)
#    define FROM_STD_STR(utf8str) utility::conversions::to_string_t(utf8str)
#else
#    define TO_STD_STR(ws_str) ws_str
#    define FROM_STD_STR(utf8str) utf8str
#endif
using t_http_client_ptr = std::unique_ptr<web::http::client::http_client>;
using t_http_client     = web::http::client::http_client;
using t_http_request    = web::http::http_request;

inline t_http_request
create_json_post_request(nlohmann::json&& json_data)
{
    t_http_request req;
    req.set_method(web::http::methods::POST);
    req.headers().set_content_type(FROM_STD_STR("application/json"));
    req.set_body(json_data.dump());
    return req;
}

inline void
handle_exception_pplx_task(pplx::task<void> previous_task)
{
    try
    {
        previous_task.wait();
    }
    catch (const std::exception& e)
    {
        spdlog::error("pplx task error: {}", e.what());
    }
}


//! SDK Headers
#include <antara/gaming/core/open.url.browser.hpp>

namespace ag = antara::gaming;