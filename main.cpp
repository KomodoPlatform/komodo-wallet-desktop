#include <QDebug>
#include <QApplication>
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

#ifdef __APPLE__
#    include "atomic.dex.osx.manager.hpp"
#endif

#if defined(WINDOWS_RELEASE_MAIN)
INT WINAPI WinMain(HINSTANCE hInst, HINSTANCE, LPSTR strCmdLine, INT)
#else

int
main(int argc, char* argv[])
#endif
{
    //! Project
#if defined(_WIN32) || defined(WIN32) || defined(__linux__)
    assert(wally_init(0) == WALLY_OK);
#endif
    assert(sodium_init() == 0);
    atomic_dex::kill_executable("mm2");
    loguru::g_preamble_uptime = false;
    loguru::g_preamble_date   = false;
    loguru::set_thread_name("main thread");
    std::string path = get_atomic_dex_current_log_file().string();
    loguru::add_file(path.c_str(), loguru::FileMode::Truncate, loguru::Verbosity_INFO);
    atomic_dex::application atomic_app;

    //! QT
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    int ac = 0;
    QApplication       app(ac, NULL);
    atomic_app.set_qt_app(&app);
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
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
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
