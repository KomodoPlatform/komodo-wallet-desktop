import QtQuick 2.15
import "../Constants"
import App 1.0

Rectangle {
    Behavior on color { ColorAnimation { duration: Style.animationDuration } }
}
