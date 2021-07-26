import QtQuick 2.15
import "../Constants"
import App 1.0

TextEdit {
    property string text_value
    property bool privacy: false

    font.family: Style.font_family
    font.pixelSize: Style.textSize
    text: privacy && General.privacy_mode ? General.privacy_text : text_value
    wrapMode: Text.WordWrap
    selectByMouse: true
    readOnly: true

    color: Style.colorText
    selectedTextColor: Style.colorSelectedText
    selectionColor: Style.colorSelection

    Behavior on color {
        ColorAnimation {
            duration: Style.animationDuration
        }
    }

    onLinkActivated: Qt.openUrlExternally(link)

    DefaultMouseArea {
        anchors.fill: parent
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.NoButton
    }
}