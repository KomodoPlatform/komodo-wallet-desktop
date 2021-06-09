import QtQuick 2.15
import "../Constants"

Text {
    property string text_value
    property bool privacy: false

    Behavior on color { ColorAnimation { duration: Style.animationDuration } }

    font: Qt.font({
                  pixelSize: 13,
                  letterSpacing: 0.25,
                  weight: Font.Normal
              })

    color: try {
            theme.foregroundColor?? "white"
        } catch(e) {
            "white"
        }

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
