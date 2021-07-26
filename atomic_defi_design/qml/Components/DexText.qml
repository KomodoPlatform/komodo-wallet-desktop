import QtQuick 2.15
import "../Constants"
import App 1.0

Text {
    property string text_value
    property bool privacy: false

    Behavior on color {
        ColorAnimation {
            duration: Style.animationDuration
        }
    }

    font: DexTypo.body1
    color: DexTheme.foregroundColor
    text: privacy && General.privacy_mode ? General.privacy_text : text_value
    wrapMode: Text.WordWrap

    onLinkActivated: Qt.openUrlExternally(link)
    linkColor: color

    DefaultMouseArea {
        anchors.fill: parent
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.NoButton
    }
}