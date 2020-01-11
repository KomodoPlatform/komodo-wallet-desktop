#include <QGuiApplication>
#include <QQmlApplicationEngine>

//! PCH Headers
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.app.hpp"
#include "atomic.dex.kill.hpp"

int
main(int argc, char* argv[])
{
    //! Project
    assert(sodium_init() == 0);
    atomic_dex::kill_executable("mm2");
    loguru::g_preamble_uptime = false;
    loguru::g_preamble_date   = false;
    loguru::set_thread_name("main thread");
    atomic_dex::application atomic_app;

    //! QT
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    const QUrl            url(QStringLiteral("qrc:/qt_assets/gui/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject* obj, const QUrl& objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(url);

    atomic_app.launch();
    return app.exec();
}
