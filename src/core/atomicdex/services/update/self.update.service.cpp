// Std headers
#include <algorithm>
#include <cctype> //> std::isdigit
#include <cstdlib>

// Qt headers
#include <QApplication> //> qApp
#include <QJsonObject>
#include <QProcess>

// Deps headers
#include <antara/gaming/core/real.path.hpp>

// Project headers
#include "atomicdex/utilities/cpprestsdk.utilities.hpp" //> download_file()
#include "atomicdex/version/version.hpp"                //> get_version()
#include "self.update.service.hpp"

namespace atomic_dex
{
    const auto update_archive_path{antara::gaming::core::binary_real_path().parent_path() / ".update_archive"};

    self_update_service::self_update_service(entt::registry& entity_registry) : system(entity_registry), m_download_mgr(dispatcher_)
    {
        dispatcher_.sink<download_release_finished>().connect<&self_update_service::on_download_release_finished>(*this);
        fetch_last_release_info();
    }

    void
    self_update_service::update()
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

    void
    self_update_service::fetch_last_release_info()
    {
        auto releases_request = github_api::repository_releases_request{.owner = "KomodoPlatform", .repository = "atomicDEX-Desktop"};

        github_api::get_repository_releases_async(releases_request)
            .then([this](web::http::http_response resp) {
                auto last_release = github_api::get_last_repository_release_from_http_response(resp);
                last_release_info = last_release;
                emit last_release_tag_nameChanged();
            })
            .then(&handle_exception_pplx_task);
    }

    void
    self_update_service::download_update()
    {
        auto release_info     = last_release_info.get();
        auto download_request = github_api::download_repository_release_request{
            .owner = "KomodoPlatform", .repository = "atomicDEX-Desktop", .tag_name = release_info.tag_name, .name = release_info.name};

        auto url = fmt::format(
            "https://github.com/{}/{}/{}/{}/{}/{}", download_request.owner, download_request.repository, "releases", "download", download_request.tag_name,
            download_request.name);
        m_download_mgr.do_download(QUrl(QString::fromStdString(url)));
    }

    void
    self_update_service::perform_update()
    {
        const auto&                  cmd      = qApp->arguments()[0];
        [[maybe_unused]] const auto& args     = qApp->arguments();
        [[maybe_unused]] const auto& dir_path = qApp->applicationDirPath();
        qApp->quit();
        bool res = false;

        // Installs update for MacOS.
#ifdef __APPLE__
        try
        {
            const auto image_mount_path = fs::path("/Volumes") / DEX_PROJECT_NAME;
            const auto image_mount_cmd =
                fmt::format("hdiutil attach -mountpoint {} {}", image_mount_path.c_str(), m_download_mgr.get_last_download_path().c_str());
            const auto image_unmount_cmd = fmt::format("hdiutil detach {}", image_mount_path.c_str());

            //! Mounting
            SPDLOG_INFO("Executing: {}", image_mount_cmd);
            std::system(image_mount_cmd.c_str());

            //! Retrieve App path
            fs::path app_path = ag::core::binary_real_path().parent_path().parent_path().parent_path();

            //! Deleting old
            SPDLOG_INFO("Deleting: {}", app_path.c_str());
            fs::remove_all(app_path);

            //! Copying
            SPDLOG_INFO("Copying: {} to {}", (image_mount_path / (std::string(DEX_PROJECT_NAME) + ".app")).c_str(), app_path.c_str());
            fs::copy(image_mount_path / (std::string(DEX_PROJECT_NAME) + ".app"), app_path, fs::copy_options::recursive);

            //! Unmount
            SPDLOG_INFO("Executing: {}", image_unmount_cmd);
            std::system(image_unmount_cmd.c_str());

            //! DL download tmp path
            SPDLOG_INFO("Removing: {}", m_download_mgr.get_last_download_path().c_str());
            fs::remove(m_download_mgr.get_last_download_path());
        }
        catch (std::exception& ex)
        {
            SPDLOG_ERROR(ex.what());
        }
        qDebug() << "cmd: " << cmd;
        res = QProcess::startDetached(cmd, args);
#endif

        // Restarts application.
        if (!res)
        {
            SPDLOG_ERROR("Couldn't start a new process");
        }
        else
        {
            SPDLOG_INFO("Successfully restarted the app");
        }
    }

    QString
    self_update_service::get_last_release_tag_name() const noexcept
    {
        return QString::fromStdString(last_release_info.get().tag_name);
    }

    bool
    self_update_service::is_update_needed() const noexcept
    {
        auto tag = last_release_info.get().tag_name;
        tag.erase(std::remove_if(tag.begin(), tag.end(), [](char c) { return not std::isdigit(c); }), tag.end());
        return std::stoi(tag) > get_num_version();
    }

    bool
    self_update_service::is_update_ready() const noexcept
    {
        return update_ready.get();
    }

    void
    self_update_service::on_download_release_finished([[maybe_unused]] const download_release_finished& evt)
    {
        SPDLOG_DEBUG("Successfully downloaded last release to {}", m_download_mgr.get_last_download_path().c_str());
        update_ready = true;
        emit update_readyChanged();
    }
} // namespace atomic_dex