import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

Circle {
    property string link
    property alias source: icon.source

    Layout.preferredWidth: 60
    Layout.preferredHeight: Layout.preferredWidth

    color: Style.colorOnlyIf(mouse_area.containsMouse, Style.colorTheme4)
    Behavior on color { ColorAnimation { duration: Style.animationDuration } }

    radius: 100

    DefaultImage {
        id: icon

        width: parent.width * 0.9
        height: parent.height * 0.9

        anchors.centerIn: parent

        MouseArea {
            id: mouse_area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Qt.openUrlExternally(link)
        }
    }
}
