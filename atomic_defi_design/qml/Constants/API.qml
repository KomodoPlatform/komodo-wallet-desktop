pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property var app: atomic_app
    readonly property var qt_utilities: atomic_qt_utilities
}
