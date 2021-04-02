// Std headers
#include <cstdlib>

// Qt headers
#include <QJsonObject>
#include <QApplication> //> qApp
#include <QProcess>

// Deps headers
#include <antara/gaming/core/real.path.hpp>

// Project headers
#include "self.update.service.hpp"
#include "atomicdex/version/version.hpp"                //> get_version()
#include "atomicdex/utilities/cpprestsdk.utilities.hpp" //> download_file()

namespace atomic_dex
{
    const auto update_archive_path{antara::gaming::core::binary_real_path().parent_path() / ".update_archive"};
    
    self_update_service::self_update_service(entt::registry& entity_registry) :
        system(entity_registry)
    {
        fetch_last_release_info();
    }
    
    void self_update_service::update()
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
            .then([this](fs::path download_location)
            {
                SPDLOG_DEBUG("Successfully downloaded last release to {}", download_location.string());
                update_ready = true;
                emit update_readyChanged();
            })
            .then(&handle_exception_pplx_task);
    }
    
    void self_update_service::perform_update()
    {
        qApp->quit();
        
        // Installs update for MacOS.
#ifdef __APPLE__
        try
        {
            const auto image_mount_path = update_archive_path.parent_path() / ".update_image";
            auto image_mount_cmd = fmt::format("hdiutil attach {} -mountpoint {}/", update_archive_path.c_str(), image_mount_path.c_str());
            auto image_unmount_cmd = fmt::format("hdiutil detach {}", image_mount_path.c_str());
            auto image_copy_cmd = fmt::format("cp -rf {}/{}/Contents {}", image_mount_path.c_str(), DEX_PROJECT_NAME ".app",
                                              update_archive_path.parent_path().parent_path().parent_path().c_str());
        
            fs::create_directories(image_mount_path);
            if (!std::system(image_mount_cmd.c_str()))
            {
                std::system(image_copy_cmd.c_str());
    }
            std::system(image_unmount_cmd.c_str());
        }
        catch (std::exception& ex)
        {
            SPDLOG_ERROR(ex.what());
        }
#endif
    
        // Restarts application.
        bool res = QProcess::startDetached(qApp->arguments()[0], qApp->arguments(), qApp->applicationDirPath());
        if (!res)
        {
            SPDLOG_ERROR("Couldn't start a new process");
        }
        else
        {
            SPDLOG_INFO("Successfully restarted the app");
        }
    }
    
    QString self_update_service::get_last_release_tag_name() const noexcept
    {
        return QString::fromStdString(last_release_info.get().tag_name);
    }
    
    bool self_update_service::is_update_needed() const noexcept
    {
        auto tag = last_release_info.get().tag_name;
        return !tag.empty() && tag != get_version();
    }
    
    bool self_update_service::is_update_ready() const noexcept
    {
        return update_ready.get();
    }
}