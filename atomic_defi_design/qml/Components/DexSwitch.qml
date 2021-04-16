import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import "../Constants"

Switch {
    id: control
    Universal.theme: Style.dark_theme ? Universal.Dark : Universal.Light
    Universal.accent: theme.accent
    Universal.foreground: theme.foregroundColor
    Universal.background: Style.colorQtThemeBackground

    font.family:theme.textType.fontFamily
    indicator: Rectangle {
        implicitWidth: 52
        implicitHeight: 22
        //x: control.width - width - control.rightPadding
        y: parent.height / 2 - height / 2
        radius: 13
        color: control.checked ? theme.accentColor : 'transparent'
        border.color: theme.foregroundColor

        Rectangle {
            x: control.checked ? parent.width - width : 0
            width: 22
            height: 22
            radius: 11
            border.color: theme.foregroundColor
        }
    }
    DefaultMouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}
