import QtQuick 2.15
import "../Constants"

Text {
    property string text_value
    property bool privacy: false

    Behavior on color { ColorAnimation { duration: Style.animationDuration } }

    font: theme.textType.body1
    color: Style.colorText
    text: privacy && General.privacy_mode ? General.privacy_text : text_value
    wrapMode: Text.WordWrap

    linkColor: color

    DefaultMouseArea {
        anchors.fill: parent
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.NoButton
    }
}
