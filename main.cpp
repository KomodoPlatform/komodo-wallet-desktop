#include <csignal>

#include <QApplication>
#include <QDebug>
#include <QDesktopWidget>
#include <QQmlApplicationEngine>
#include <QScreen>
#include <QWindow>
#include <Qaterial/Qaterial.hpp>
#include <QtQml>
#include <QtWebEngine>

#define QZXING_QML

#include "QZXing.h"

//! PCH Headers
#include "atomicdex/pch.hpp"

//! Deps
#include <sodium/core.h>
#include <wally.hpp>

#if defined(linux)
#    define BOOST_STACKTRACE_USE_ADDR2LINE
#    include <boost/stacktrace.hpp>
#endif

//! Project Headers
#include "atomicdex/app.hpp"
#include "atomicdex/models/qt.portfolio.model.hpp"
#include "atomicdex/utilities/kill.hpp"

#ifdef __APPLE__
#    include "atomicdex/platform/osx/manager.hpp"
#endif

inline constexpr size_t g_qsize_spdlog             = 10240;
inline constexpr size_t g_spdlog_thread_count      = 2;
inline constexpr size_t g_spdlog_max_file_size     = 7777777;
inline constexpr size_t g_spdlog_max_file_rotation = 3;


void
signal_handler(int signal)
{
    spdlog::trace("sigabort received, cleaning mm2.service");
    atomic_dex::kill_executable("mm2.service");
#if defined(linux)
    boost::stacktrace::safe_dump_to("./backtrace.dump");
#endif
    std::exit(signal);
}

static void
connect_signals_handler()
{
    spdlog::info("connecting signal SIGABRT to the signal handler");
#if defined(linux)
    if (boost::filesystem::exists("./backtrace.dump"))
    {
        // there is a backtrace
        std::ifstream ifs("./backtrace.dump");

        boost::stacktrace::stacktrace st = boost::stacktrace::stacktrace::from_dump(ifs);
        std::cout << "Previous run crashed:\n" << st << std::endl;

        // cleaning up
        ifs.close();
        boost::filesystem::remove("./backtrace.dump");
    }
#endif
    std::signal(SIGABRT, signal_handler);
    std::signal(SIGSEGV, signal_handler);
}

static void
init_wally()
{
    [[maybe_unused]] auto wally_res = wally_init(0);
    assert(wally_res == WALLY_OK);
    spdlog::info("wally successfully initialized");
}

static void
init_sodium()
{
    //! Sodium Initialization
    [[maybe_unused]] auto sodium_return_value = sodium_init();
    assert(sodium_return_value == 0); //< This is not executed when build = Release
    spdlog::info("libsodium successfully initialized");
}

static void
clean_previous_run()
{
    spdlog::info("cleaning previous mm2 instance");
    atomic_dex::kill_executable("mm2");
}

static void
init_logging()
{
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
}

static void
init_dpi()
{
    spdlog::info("initializing high dpi support");
    bool should_floor = false;
#if defined(_WIN32) || defined(WIN32) || defined(__linux__)
    {
        int          ac = 0;
        QApplication tmp(ac, nullptr);
        double       min_window_size = 800.0;
        auto         screens         = tmp.screens();
        for (auto&& cur_screen: screens)
        {
            spdlog::trace("physical dpi: {}", cur_screen->physicalDotsPerInch());
            spdlog::trace("logical dpi: {}", cur_screen->logicalDotsPerInch());
            double scale = cur_screen->logicalDotsPerInch() / 96.0;
            spdlog::trace("scale: {}", scale);

            double height = cur_screen->availableSize().height();
            spdlog::trace("height: {}", height);
            if (scale * min_window_size > height)
            {
                should_floor = true;
                spdlog::trace("should floor");
            }
        }
    }
#endif
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        should_floor ? Qt::HighDpiScaleFactorRoundingPolicy::Floor : Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
    QGuiApplication::setAttribute(should_floor ? Qt::AA_DisableHighDpiScaling : Qt::AA_EnableHighDpiScaling);
}

static void
clean_wally()
{
    [[maybe_unused]] auto wallet_exit_res = wally_cleanup(0);
    assert(wallet_exit_res == WALLY_OK);
    spdlog::info("wally successfully cleaned");
}

static void
init_timezone_db()
{
    spdlog::info("Init timezone db");
#if defined(_WIN32) || defined(WIN32)
    using namespace std::string_literals;
    auto install_db_tz_path = std::make_unique<fs::path>(ag::core::assets_real_path() / "tools" / "timezone" / "tzdata");
    std::cout << install_db_tz_path->string() << std::endl;
    date::set_install(install_db_tz_path->string());
#endif
}

#if defined(WINDOWS_RELEASE_MAIN)
INT WINAPI
WinMain([[maybe_unused]] HINSTANCE hInst, HINSTANCE, [[maybe_unused]] LPSTR strCmdLine, INT)
#else

int
main([[maybe_unused]] int argc, [[maybe_unused]] char* argv[])
#endif
{
#if defined(WINDOWS_RELEASE_MAIN)
    int    argc = __argc;
    char** argv = __argv;
#endif
    init_logging();
    connect_signals_handler();
    init_timezone_db();
    init_wally();
    init_sodium();
    clean_previous_run();
    init_dpi();

    //! App declaration
    atomic_dex::application atomic_app;

    //! QT
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    QtWebEngine::initialize();
    std::shared_ptr<QApplication> app = std::make_shared<QApplication>(argc, argv);
    app->setOrganizationName("KomodoPlatform");
    app->setOrganizationDomain("com");
    QQmlApplicationEngine engine;

    atomic_app.set_qt_app(app, &engine);

    //! QT QML
    engine.addImportPath("qrc:///");
    QZXing::registerQMLTypes();
    QZXing::registerQMLImageProvider(engine);
    engine.rootContext()->setContextProperty("atomic_app", &atomic_app);
    // Load Qaterial.

    qaterial::loadQmlResources(false);
    // qaterial::registerQmlTypes("Qaterial", 1, 0);
    engine.addImportPath("qrc:/atomic_defi_design/imports");
    engine.addImportPath("qrc:/atomic_defi_design/Constants");
    qmlRegisterSingletonType(QUrl("qrc:/atomic_defi_design/qml/Constants/General.qml"), "App", 1, 0, "General");
    qmlRegisterSingletonType(QUrl("qrc:/atomic_defi_design/qml/Constants/Style.qml"), "App", 1, 0, "Style");
    qmlRegisterSingletonType(QUrl("qrc:/atomic_defi_design/qml/Constants/API.qml"), "App", 1, 0, "API");
    qRegisterMetaType<t_portfolio_roles>("PortfolioRoles");

    const QUrl url(QStringLiteral("qrc:/atomic_defi_design/qml/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, app.get(),
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

    auto res = app->exec();

    clean_wally();

    return res;
}
