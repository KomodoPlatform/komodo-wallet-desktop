import QtQuick 2.15
import "../Constants"
import App 1.0

Rectangle {
    property bool colorAnimation: true
    Behavior on color { ColorAnimation { duration: colorAnimation ? Style.animationDuration : 0; } }
}
