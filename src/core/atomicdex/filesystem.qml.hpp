#include <QObject>

#include "filesystem.hpp"

namespace atomic_dex
{
    class filesystem : public QObject
    {
        Q_OBJECT

    public:
        Q_INVOKABLE QString getAppDataFolder();
        Q_INVOKABLE QString getThemesFolder();
        Q_INVOKABLE QString getThemeFolder(QString theme_name);

        Q_INVOKABLE bool exists(QString path);
    };
}