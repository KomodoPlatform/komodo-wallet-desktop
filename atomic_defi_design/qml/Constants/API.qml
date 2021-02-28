pragma Singleton

// Qt Imports
import QtQuick 2.15

QtObject {
    readonly property var    app: atomic_app
    readonly property string app_name: atomic_app_name
    readonly property var    qt_utilities: atomic_qt_utilities
}
