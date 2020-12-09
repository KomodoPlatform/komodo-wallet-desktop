import QtQuick 2.15
import "../Constants/Style.qml" as Style

Rectangle {
    Behavior on color { ColorAnimation { duration: Style.animationDuration } }
}
