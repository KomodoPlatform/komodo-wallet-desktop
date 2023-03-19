#include "filesystem.qml.hpp"

namespace atomic_dex
{
    QString filesystem::getAppDataFolder()
    {
        return QString::fromStdString(get_appdata_folder().string());
    }

    QString filesystem::getThemesFolder()
    {
        return QString::fromStdString(get_themes_folder().string());
    }

    QString filesystem::getThemeFolder(QString theme_name)
    {
        return QString::fromStdString(get_theme_folder(theme_name.toStdString()).string());
    }

    bool filesystem::exists(QString path)
    {
        return std::filesystem::exists(path.toStdString());
    }
}