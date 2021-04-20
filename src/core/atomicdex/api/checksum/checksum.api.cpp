//! 3rdParty
#include <nlohmann/json.hpp>

//! Project
#include "checksum.api.hpp"

namespace atomic_dex::checksum::api
{
    const auto api_client = std::make_unique<web::http::client::http_client>(FROM_STD_STR(DEX_CHECKSUM_API_URL));
    
    pplx::task<std::string>
    get_latest_checksum()
    {
        return api_client->request(web::http::methods::GET)
            .then([](web::http::http_response resp)
            {
                if (resp.status_code() != 200)
                {
                    return TO_STD_STR(resp.extract_string(true).get());
                }
  
                const auto json_answer = nlohmann::json::parse(TO_STD_STR(resp.extract_string(true).get()));
                
                for (auto it = json_answer.begin(); it != json_answer.end(); ++it)
                {
                    if (it.key().find(
#ifdef __APPLE__
                            "osx.dmg"
#elif __linux__
                            "linux.AppImage"
#elif _WIN32
                            "windows.zip"
#endif
                        ) != std::string::npos)
                        return it.value().get<std::string>();
                }
                
                return std::string{"Cannot found valid checksum."};
            });
    }
}