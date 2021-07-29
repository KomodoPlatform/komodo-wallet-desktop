import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import App 1.0

CheckBox {
    id: control
    Universal.accent: DexTheme.accentColor
    Universal.foreground: DexTheme.foregroundColor
    Universal.background: DexTheme.backgroundColor

    font.family: Style.font_family
    contentItem: DexLabel {
        text: control.text
        font: control.font
        color: DexTheme.foregroundColor
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