//! 3rdParty
#include <nlohmann/json.hpp>
#include <optional>

//! Project
#include "checksum.api.hpp"

namespace atomic_dex::checksum::api
{
    const auto api_client = std::make_unique<web::http::client::http_client>(FROM_STD_STR(DEX_CHECKSUM_API_URL));

    // Helper function for platform-specific file identifiers
    std::string get_platform_file_identifier()
    {
#ifdef __APPLE__
        return "osx.dmg";
#elif __linux__
        return "linux.AppImage";
#elif _WIN32
        return "windows.zip";
#else
        return "";
#endif
    }

    pplx::task<std::optional<std::string>>
    get_latest_checksum()
    {
        return api_client->request(web::http::methods::GET)
            .then([](web::http::http_response resp) -> std::optional<std::string>
            {
                if (resp.status_code() != 200)
                {
                    SPDLOG_ERROR("Failed to fetch checksum. HTTP status: {}", resp.status_code());
                    return std::nullopt;
                }

                // Cache the response body to avoid multiple calls to extract_string
                std::string body = TO_STD_STR(resp.extract_string(true).get());

                try
                {
                    SPDLOG_DEBUG("Checksum API response: {}", body);
                    const auto json_answer = nlohmann::json::parse(body);

                    std::string platform_identifier = get_platform_file_identifier();

                    if (platform_identifier.empty())
                    {
                        SPDLOG_ERROR("Unknown platform! Unable to fetch the correct checksum.");
                        return std::nullopt;
                    }

                    // Look for the platform-specific checksum
                    for (const auto& item : json_answer.items())
                    {
                        if (item.key().find(platform_identifier) != std::string::npos)
                        {
                            SPDLOG_DEBUG("Found checksum for platform: {}", item.key());
                            return item.value().get<std::string>();
                        }
                    }

                    SPDLOG_WARN("Valid checksum not found in the response.");
                    return std::nullopt;
                }
                catch (const nlohmann::json::exception& e)
                {
                    SPDLOG_ERROR("JSON parsing error: {}", e.what());
                    return std::nullopt;
                }
                catch (const std::exception& e)
                {
                    SPDLOG_ERROR("Exception while processing checksum: {}", e.what());
                    return std::nullopt;
                }
            })
            .then([](pplx::task<std::optional<std::string>> previous_task) -> std::optional<std::string>
            {
                try
                {
                    return previous_task.get();  // Get the result of the task, or throw if it failed
                }
                catch (const web::http::http_exception& e)
                {
                    SPDLOG_ERROR("HTTP exception in get_latest_checksum: {}", e.what());
                    return std::nullopt;
                }
                catch (const std::exception& e)
                {
                    SPDLOG_ERROR("Standard exception in get_latest_checksum: {}", e.what());
                    return std::nullopt;
                }
                catch (...)
                {
                    SPDLOG_ERROR("Unknown exception in get_latest_checksum.");
                    return std::nullopt;
                }
            });
    }
}
