/******************************************************************************
 * Copyright © 2013-2021 The Komodo Platform Developers.                      *
 *                                                                            *
 * See the AUTHORS, DEVELOPER-AGREEMENT and LICENSE files at                  *
 * the top-level directory of this distribution for the individual copyright  *
 * holder information and the developer policies on copyright and licensing.  *
 *                                                                            *
 * Unless otherwise agreed in a custom licensing agreement, no part of the    *
 * Komodo Platform software, including this file may be copied, modified,     *
 * propagated or distributed except according to the terms contained in the   *
 * LICENSE file                                                               *
 *                                                                            *
 * Removal or modification of this copyright notice is prohibited.            *
 *                                                                            *
 ******************************************************************************/

//! PCH Headers
#include "atomicdex/pch.hpp"

//! C Headers
#include <csignal>

//! Qt
#include <QApplication>
#include <QDebug>
#include <QDesktopWidget>
#include <QQmlApplicationEngine>
#include <QScreen>
#include <QSettings>
#include <QWindow>
#include <QtGlobal>
#include <QtQml>
#include <QtWebEngine>

//! Qaterial
#include <Qaterial/Qaterial.hpp>
#if defined(ATOMICDEX_HOT_RELOAD)
#    include <Qaterial/HotReload/HotReload.hpp>
#    include <SortFilterProxyModel/SortFilterProxyModel.hpp>
#endif


//! Deps
#include <sodium/core.h>
#include <wally.hpp>

#if defined(linux) || defined(__APPLE__)
#    define BOOST_STACKTRACE_USE_ADDR2LINE
#    if defined(__APPLE__)
#        define _GNU_SOURCE
#    endif
#    include <boost/stacktrace.hpp>
#endif

//! Project Headers
#include "atomicdex/app.hpp"
#include "atomicdex/models/qt.portfolio.model.hpp"
#include "atomicdex/utilities/kill.hpp"
#include "atomicdex/utilities/qt.utilities.hpp"

#include "atomicdex/utilities/log.prerequisites.hpp"

#ifdef __APPLE__
#    include "atomicdex/platform/osx/manager.hpp"
#    include <sys/sysctl.h>
#endif

#if defined(ATOMICDEX_HOT_RELOAD)
void
qtMsgOutput(QtMsgType type, const QMessageLogContext& context, const QString& msg)
{
    const auto localMsg = msg.toLocal8Bit();
    switch (type)
    {
    case QtDebugMsg:
        qaterial::Logger::QATERIAL->debug(localMsg.constData());
        break;
    case QtInfoMsg:
        qaterial::Logger::QATERIAL->info(localMsg.constData());
        break;
    case QtWarningMsg:
        qaterial::Logger::QATERIAL->warn(localMsg.constData());
        break;
    case QtCriticalMsg:
        qaterial::Logger::QATERIAL->error(localMsg.constData());
        break;
    case QtFatalMsg:
        qaterial::Logger::QATERIAL->error(localMsg.constData());
        abort();
    }
}

void
installLoggers()
{
    qInstallMessageHandler(qtMsgOutput);
#    ifdef WIN32
    const auto msvcSink = std::make_shared<spdlog::sinks::msvc_sink_mt>();
    qaterial::Logger::registerSink(msvcSink);
#    endif
    const auto stdoutSink = std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
    qaterial::Logger::registerSink(stdoutSink);
    qaterial::Logger::registerSink(qaterial::HotReload::sink());
    stdoutSink->set_level(spdlog::level::debug);
    qaterial::HotReload::sink()->set_level(spdlog::level::debug);
    qaterial::Logger::QATERIAL->set_level(spdlog::level::debug);
}
#endif

static void
qt_message_handler(QtMsgType type, [[maybe_unused]] const QMessageLogContext& context, const QString& msg)
{
    const auto localMsg = msg.toLocal8Bit();
    switch (type)
    {
    case QtDebugMsg:
        SPDLOG_DEBUG("{}", localMsg.constData());
        break;
    case QtInfoMsg:
        SPDLOG_INFO("{}", localMsg.constData());
        break;
    case QtWarningMsg:
        SPDLOG_WARN("{}", localMsg.constData());
        break;
    case QtCriticalMsg:
        SPDLOG_ERROR("{}", localMsg.constData());
        break;
    case QtFatalMsg:
        SPDLOG_ERROR("{}", localMsg.constData());
        abort();
    }
}

static void
signal_handler(int signal)
{
    SPDLOG_ERROR("sigabort received, cleaning mm2");
    atomic_dex::kill_executable("mm2.service");
#if defined(linux) || defined(__APPLE__)
    boost::stacktrace::safe_dump_to("./backtrace.dump");
    std::ifstream                 ifs("./backtrace.dump");
    boost::stacktrace::stacktrace st = boost::stacktrace::stacktrace::from_dump(ifs);
    SPDLOG_ERROR("stacktrace: {}", boost::stacktrace::to_string(st));
#endif
    std::exit(signal);
}

static void
connect_signals_handler()
{
    SPDLOG_INFO("connecting signal SIGABRT to the signal handler");
#if defined(linux) || defined(__APPLE__)
    if (fs::exists("./backtrace.dump"))
    {
        // there is a backtrace
        std::ifstream ifs("./backtrace.dump");

        boost::stacktrace::stacktrace st = boost::stacktrace::stacktrace::from_dump(ifs);
        std::cout << "Previous run crashed:\n" << st << std::endl;

        // cleaning up
        ifs.close();
        fs::remove("./backtrace.dump");
    }
#endif
    std::signal(SIGABRT, &signal_handler);
    std::signal(SIGSEGV, &signal_handler);
    std::signal(SIGTERM, &signal_handler);
}

static void
init_wally()
{
    [[maybe_unused]] auto wally_res = wally_init(0);
    assert(wally_res == WALLY_OK);
    SPDLOG_INFO("wally successfully initialized");
}

static void
init_sodium()
{
    //! Sodium Initialization
    [[maybe_unused]] auto sodium_return_value = sodium_init();
    assert(sodium_return_value == 0); //< This is not executed when build = Release
    SPDLOG_INFO("libsodium successfully initialized");
}

static void
clean_previous_run()
{
    SPDLOG_INFO("cleaning previous mm2 instance");
    atomic_dex::kill_executable("mm2");
}

static void
init_logging()
{
    auto logger = atomic_dex::utils::register_logger();
    if (spdlog::get("log_mt") == nullptr)
    {
        spdlog::register_logger(logger);
        spdlog::set_default_logger(logger);
        spdlog::set_level(spdlog::level::trace);
        spdlog::set_pattern("[%T] [%^%l%$] [%s:%#]: %v");
    }
}

static void
init_dpi()
{
    SPDLOG_INFO("initializing high dpi support");
    bool should_floor = false;
#if defined(_WIN32) || defined(WIN32) || defined(__linux__)
    {
        int          ac = 0;
        QApplication tmp(ac, nullptr);
        double       min_window_size = 800.0;
        auto         screens         = tmp.screens();
        for (auto&& cur_screen: screens)
        {
            SPDLOG_DEBUG("physical dpi: {}", cur_screen->physicalDotsPerInch());
            SPDLOG_DEBUG("logical dpi: {}", cur_screen->logicalDotsPerInch());
            double scale = cur_screen->logicalDotsPerInch() / 96.0;
            SPDLOG_DEBUG("scale: {}", scale);

            double height = cur_screen->availableSize().height();
            SPDLOG_DEBUG("height: {}", height);
            if (scale * min_window_size > height)
            {
                should_floor = true;
                SPDLOG_DEBUG("should floor");
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
    SPDLOG_INFO("wally successfully cleaned");
}

static void
init_timezone_db()
{
    SPDLOG_INFO("Init timezone db");
#if defined(_WIN32) || defined(WIN32)
    using namespace std::string_literals;
    auto install_db_tz_path = std::make_unique<fs::path>(ag::core::assets_real_path() / "tools" / "timezone" / "tzdata");
    std::cout << install_db_tz_path->string() << std::endl;
    date::set_install(install_db_tz_path->string());
#endif
}

static void
handle_settings(QSettings& settings)
{
    auto create_settings_functor = [&settings](QString settings_name, QVariant value) {
        if (!settings.contains(settings_name))
        {
            SPDLOG_INFO("Settings {} doesn't exist yet for this application, creating now", settings_name.toStdString());
            settings.setValue(settings_name, value);
        }
        else
        {
            SPDLOG_INFO("Settings {} already exist - skipping", settings_name.toStdString());
        }
    };
    SPDLOG_INFO("file name settings: {}", settings.fileName().toStdString());
#ifdef __APPLE__
    create_settings_functor("FontMode", QQuickWindow::TextRenderType::NativeTextRendering);
    QQuickWindow::setTextRenderType(static_cast<QQuickWindow::TextRenderType>(settings.value("FontMode").toInt()));
#else
    create_settings_functor("FontMode", QQuickWindow::TextRenderType::QtTextRendering);
#endif
}

inline int
run_app(int argc, char** argv)
{
#if !defined(ATOMICDEX_HOT_RELOAD)
    SPDLOG_INFO("Installing qt_message_handler");
    qInstallMessageHandler(&qt_message_handler);
#endif

    init_logging();
    connect_signals_handler();
    init_timezone_db();
    init_wally();
    init_sodium();
    clean_previous_run();
    QSettings settings((atomic_dex::utils::get_current_configs_path() / "cfg.ini").string().c_str(), QSettings::IniFormat);
    handle_settings(settings);
    init_dpi();

    int res = 0;

    //! App declaration
    atomic_dex::application atomic_app;

    //! Qt utilities declaration.
    atomic_dex::qt_utilities qt_utilities;

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
    qRegisterMetaType<MarketMode>("MarketMode");
    qmlRegisterUncreatableType<atomic_dex::MarketModeGadget>("AtomicDEX.MarketMode", 1, 0, "MarketMode", "Not creatable as it is an enum type");
    qRegisterMetaType<TradingError>("TradingError");
    qmlRegisterUncreatableType<atomic_dex::TradingErrorGadget>("AtomicDEX.TradingError", 1, 0, "TradingError", "Not creatable as it is an enum type");
    qRegisterMetaType<CoinType>("CoinType");
    qmlRegisterUncreatableType<atomic_dex::CoinTypeGadget>("AtomicDEX.CoinType", 1, 0, "CoinType", "Not creatable as it is an enum type");

    engine.rootContext()->setContextProperty("atomic_app", &atomic_app);
    engine.rootContext()->setContextProperty("atomic_app_name", QString{DEX_NAME});
    engine.rootContext()->setContextProperty("atomic_qt_utilities", &qt_utilities);
    engine.rootContext()->setContextProperty("atomic_cfg_file", QString::fromStdString((atomic_dex::utils::get_current_configs_path() / "cfg.ini").string()));
    engine.rootContext()->setContextProperty("atomic_settings", &settings);
    // Load Qaterial.

    qaterial::loadQmlResources(false);
    // qaterial::registerQmlTypes("Qaterial", 1, 0);
    engine.addImportPath("qrc:/atomic_defi_design/imports");
    engine.addImportPath("qrc:/atomic_defi_design/Constants");
    qmlRegisterSingletonType(QUrl("qrc:/atomic_defi_design/qml/Constants/General.qml"), "App", 1, 0, "General");
    qmlRegisterSingletonType(QUrl("qrc:/atomic_defi_design/qml/Constants/Style.qml"), "App", 1, 0, "Style");
    qmlRegisterSingletonType(QUrl("qrc:/atomic_defi_design/qml/Constants/API.qml"), "App", 1, 0, "API");
    qRegisterMetaType<t_portfolio_roles>("PortfolioRoles");

#if defined(ATOMICDEX_HOT_RELOAD)
    engine.rootContext()->setContextProperty("debug_bar", true);
    engine.addImportPath("qrc:/");
    installLoggers();
    qaterial::registerQmlTypes();
    qaterial::HotReload::registerSingleton();
    qqsfpm::registerQmlTypes();
    engine.load(QUrl("qrc:/Qaterial/HotReload/Main.qml"));
    if (engine.rootObjects().isEmpty())
        return -1;
#else
    engine.rootContext()->setContextProperty("debug_bar", false);
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
#endif


#ifdef __APPLE__
#    if !defined(ATOMICDEX_HOT_RELOAD)
    QWindowList windows = QGuiApplication::allWindows();
    QWindow*    win     = windows.first();
    atomic_dex::mac_window_setup(win->winId());
#    endif
#endif
    atomic_app.launch();

    res = app->exec();

    clean_wally();
    return res;
}
