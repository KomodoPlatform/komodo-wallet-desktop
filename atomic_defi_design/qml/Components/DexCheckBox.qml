import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import "../Constants"

CheckBox {
    id: control
    Universal.theme: Style.dark_theme ? Universal.Dark : Universal.Light
    Universal.accent: theme.greenColor
    Universal.foreground: Style.colorQtThemeForeground
    Universal.background: Style.colorQtThemeBackground

    font.family: Style.font_family
    contentItem: DexLabel {
        text: control.text
        font: control.font
        horizontalAlignment: DexLabel.AlignLeft
        verticalAlignment: DexLabel.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
        wrapMode: Label.Wrap
    }
    DefaultMouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
    }
}
