pragma Singleton

// Qt Imports
import QtQuick 2.15

QtObject {
    readonly property var    app: atomic_app
    readonly property string app_name: atomic_app_name
    readonly property string app_website_url: atomic_app_website_url
    readonly property string app_support_url: atomic_app_support_url
    readonly property string app_discord_url: atomic_app_discord_url
    readonly property string app_twitter_url: atomic_app_twitter_url
    readonly property var    qt_utilities: atomic_qt_utilities
    readonly property string current_version: dex_current_version
}
