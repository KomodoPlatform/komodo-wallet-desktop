import QtQuick 2.15
import QtQuick.Controls 2.15
import "../Constants"
import App 1.0
Slider {
    id: control
    value: 0.5
    opacity: enabled ? 1 : .5

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: "#bdbebf"

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: DexTheme.accentColor
            radius: 2
        }
    }
    handle: FloatingBackground {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 26
        implicitHeight: 26
        radius: 13
        Rectangle {
            anchors.centerIn: parent
            width: 10
            height: 10
            radius: 10
            color: DexTheme.accentColor
        }
    }
}