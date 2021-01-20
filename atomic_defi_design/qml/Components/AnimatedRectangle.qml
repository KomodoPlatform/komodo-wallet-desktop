import QtQuick 2.15
import "../Constants"

Rectangle {
    Behavior on color { ColorAnimation { duration: Style.animationDuration } }
}
