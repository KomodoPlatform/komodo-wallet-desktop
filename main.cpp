#include <QApplication>
#include <QDebug>
#include <QQmlApplicationEngine>
#include <QWindow>
#include <QtQml>

#define QZXING_QML

#include "QZXing.h"

//! PCH Headers
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.app.hpp"
#include "atomic.dex.kill.hpp"
#include "atomic.threadpool.hpp"

#ifdef __APPLE__
#    include "atomic.dex.osx.manager.hpp"
#endif

inline constexpr size_t g_qsize_spdlog             = 10240;
inline constexpr size_t g_spdlog_thread_count      = 4;
inline constexpr size_t g_spdlog_max_file_size     = 7777777;
inline constexpr size_t g_spdlog_max_file_rotation = 3;

#if defined(WINDOWS_RELEASE_MAIN)
INT WINAPI
WinMain(HINSTANCE hInst, HINSTANCE, LPSTR strCmdLine, INT)
#else

int
main([[maybe_unused]] int argc, [[maybe_unused]] char* argv[])
#endif
{
    //! Project
#if defined(_WIN32) || defined(WIN32)
	using namespace std::string_literals;
	auto install_db_tz_path = std::make_unique<fs::path>(ag::core::assets_real_path() / "tools" / "timezone" / "tzdata");
	std::cout << install_db_tz_path->string() << std::endl;
	date::set_install(install_db_tz_path->string());
    //fs::path file_db_gz_path = fs::path(std::string(std::getenv("APPDATA"))) / "atomic_qt" / ("tzdata"s + "2020a"s + ".tar.gz"s);
    //std::cout << file_db_gz_path.string() << std::endl;
    /*if (not fs::exists(file_db_gz_path))
    {
			
            std::cout << "2020a" << std::endl;
            bool res_tz = date::remote_download("2020a");
			std::cout << "Pass here" << std::endl;
            assert(res_tz == true);
            if (not fs::exists(install_db_tz_path / "version"))
            {
                //! We need to untar
                boost::system::error_code ec;
                fs::create_directory(install_db_tz_path, ec);
                std::string cmd_line = "tar -xf ";
                cmd_line += file_db_gz_path.string();
                cmd_line += " -C ";
                cmd_line += install_db_tz_path.string();
                std::cout << cmd_line << std::endl;
                system(cmd_line.c_str());
                fs::path xml_windows_tdata_path =
                    fs::path(std::string(std::getenv("APPDATA"))) / "atomic_qt" / ("tzdata" + date::remote_version() + "windowsZones.xml");
                fs::copy(xml_windows_tdata_path, install_db_tz_path / "windowsZones.xml");
            }
        //atomic_dex::spawn([&file_db_gz_path]() {
		//
        //});
        
    }*/
#endif

#if defined(_WIN32) || defined(WIN32) || defined(__linux__)
    assert(wally_init(0) == WALLY_OK);
#endif

    //! Sodium Initialization
    [[maybe_unused]] auto sodium_return_value = sodium_init();
    assert(sodium_return_value == 0); //< This is not executed when build = Release

    //! Kill precedence instance if still alive
    atomic_dex::kill_executable("mm2");

    //! Log Initialization
    std::string path = get_atomic_dex_current_log_file().string();
    spdlog::init_thread_pool(g_qsize_spdlog, g_spdlog_thread_count);
    auto tp            = spdlog::thread_pool();
    auto stdout_sink   = std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
    auto rotating_sink = std::make_shared<spdlog::sinks::rotating_file_sink_mt>(path.c_str(), g_spdlog_max_file_size, g_spdlog_max_file_rotation);

    std::vector<spdlog::sink_ptr> sinks{stdout_sink, rotating_sink};
    auto logger = std::make_shared<spdlog::async_logger>("log_mt", sinks.begin(), sinks.end(), tp, spdlog::async_overflow_policy::block);
    spdlog::register_logger(logger);
    spdlog::set_default_logger(logger);
    spdlog::set_level(spdlog::level::trace);
    spdlog::set_pattern("[%H:%M:%S %z] [%L] [thr %t] %v");
    spdlog::info("Logger successfully initialized");

    //! App declaration
    atomic_dex::application atomic_app;

    //! QT
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    int          ac = 0;
    QApplication app(ac, nullptr);

    atomic_app.set_qt_app(&app);

    //! QT QML
    QQmlApplicationEngine engine;
    QZXing::registerQMLTypes();
    QZXing::registerQMLImageProvider(engine);
    engine.rootContext()->setContextProperty("atomic_app", &atomic_app);

    engine.addImportPath("qrc:/atomic_qt_design/imports");
    engine.addImportPath("qrc:/atomic_qt_design/Constants");
    qmlRegisterSingletonType(QUrl("qrc:/atomic_qt_design/qml/Constants/General.qml"), "App", 1, 0, "General");
    qmlRegisterSingletonType(QUrl("qrc:/atomic_qt_design/qml/Constants/Style.qml"), "App", 1, 0, "Style");
    qmlRegisterSingletonType(QUrl("qrc:/atomic_qt_design/qml/Constants/API.qml"), "App", 1, 0, "API");

    const QUrl url(QStringLiteral("qrc:/atomic_qt_design/qml/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject* obj, const QUrl& objUrl) {
            if ((obj == nullptr) && url == objUrl)
            {
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection);

    engine.load(url);


#ifdef __APPLE__
    QWindowList windows = QGuiApplication::allWindows();
    QWindow*    win     = windows.first();
    atomic_dex::mac_window_setup(win->winId());
#endif
    atomic_app.launch();

    auto res = app.exec();
#if defined(_WIN32) || defined(WIN32) || defined(__linux__)
    assert(wally_cleanup(0) == WALLY_OK);
#endif
    return res;
}
