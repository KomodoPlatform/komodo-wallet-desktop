#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QWindow>
#include <QDebug>
#include <QtQml>

//! PCH Headers
#include "atomic.dex.pch.hpp"

//! Project Headers
#include "atomic.dex.app.hpp"
#include "atomic.dex.kill.hpp"

#ifdef __APPLE__
#    include "atomic.dex.osx.manager.hpp"
#endif

class my_gui_app : public QGuiApplication
{
  public:
    template <typename... Args>
    my_gui_app(Args&&... args) : QGuiApplication(std::forward<Args>(args)...)
    {
    }
  public slots:
    void onApplicationStateChanged(Qt::ApplicationState state)
    {
        qDebug() << "something happen";
    };

};

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
    my_gui_app            app(argc, argv);
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("atomic_app", &atomic_app);

    engine.addImportPath("qrc:/atomic_qt_design/imports");
    engine.addImportPath("qrc:/atomic_qt_design/Constants");
    qmlRegisterSingletonType(QUrl("qrc:/atomic_qt_design/qml/Constants/General.qml"), "App", 1, 0, "General");
    qmlRegisterSingletonType(QUrl("qrc:/atomic_qt_design/qml/Constants/Style.qml"), "App", 1, 0, "Style");
    qmlRegisterSingletonType(QUrl("qrc:/atomic_qt_design/qml/Constants/MockAPI.qml"), "App", 1, 0, "MockAPI");
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

    return app.exec();
}
