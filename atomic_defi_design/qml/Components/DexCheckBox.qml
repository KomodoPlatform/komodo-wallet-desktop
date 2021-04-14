import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import "../Constants"

CheckBox {
    Universal.theme: Style.dark_theme ? Universal.Dark : Universal.Light
    Universal.accent: theme.greenColor
    Universal.foreground: Style.colorQtThemeForeground
    Universal.background: Style.colorQtThemeBackground

    font.family: Style.font_family

    DefaultMouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}
