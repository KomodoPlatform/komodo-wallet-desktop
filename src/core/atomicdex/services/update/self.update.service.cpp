// Qt headers
#include <QJsonObject>

// Deps headers
#include <antara/gaming/core/real.path.hpp>

// Project headers
#include "self.update.service.hpp"
#include "atomicdex/version/version.hpp"                //> get_version()
#include "atomicdex/utilities/cpprestsdk.utilities.hpp" //> download_file()

namespace atomic_dex
{
    const auto update_archive_path{antara::gaming::core::binary_real_path().parent_path() / "update.archive"};
    
    self_update_service::self_update_service(entt::registry& entity_registry) :
        system(entity_registry)
    {
        fetch_last_release_info();
    }
    
    void self_update_service::update() noexcept
    {
        using namespace std::chrono_literals;
        
        const auto now = std::chrono::high_resolution_clock::now();
        const auto s   = std::chrono::duration_cast<std::chrono::seconds>(now - clock);
        if (s >= 1h)
        {
            fetch_last_release_info();
            clock = std::chrono::high_resolution_clock::now();
        }
    }
    
    void self_update_service::fetch_last_release_info()
    {
        auto releases_request =
            github_api::repository_releases_request{.owner = "KomodoPlatform", .repository = "atomicDEX-Desktop"};
        
        github_api::get_repository_releases_async(releases_request)
            .then([this](web::http::http_response resp) {
                auto last_release = github_api::get_last_repository_release_from_http_response(resp);
                last_release_info = last_release;
                emit last_release_tag_nameChanged();
            })
            .then(&handle_exception_pplx_task);
    }
    
    void self_update_service::download_update()
    {
        auto release_info = last_release_info.get();
        auto download_request = github_api::download_repository_release_request{.owner = "KomodoPlatform", .repository = "atomicDEX-Desktop",
                                                                                .tag_name = release_info.tag_name, .name = release_info.name};
        
        github_api::download_repository_release(download_request, update_archive_path)
            .then([this](std::filesystem::path download_location)
            {
                SPDLOG_DEBUG("Successfully downloaded last release to {}", download_location.string());
                update_ready = true;
                emit update_readyChanged();
            })
            .then(&handle_exception_pplx_task);
    }
    
    void self_update_service::perform_update()
    {
    
    QString self_update_service::get_last_release_tag_name() const noexcept
    {
        return QString::fromStdString(last_release_info.get().tag_name);
    }
    
    bool self_update_service::is_update_needed() const noexcept
    {
        return last_release_info.get().tag_name != get_version();
    }
    
    bool self_update_service::is_update_ready() const noexcept
    {
        return update_ready.get();
    }
}