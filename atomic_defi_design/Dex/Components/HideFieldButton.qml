import QtQuick 2.15
import "../Constants"
import App 1.0

DefaultImage {
    property alias mouse_area: mouse_area
    property bool use_default_behaviour: true
    source: General.image_path + "dashboard-eye" + (hiding ? "" : "-hide") + ".svg"
    visible: hidable
    scale: 0.8
    anchors.right: parent.right
    anchors.rightMargin: 5
    anchors.verticalCenter: parent.verticalCenter
    antialiasing: true

    opacity: mouse_area.containsMouse ? Style.hoverOpacity : 1

    DefaultMouseArea {
        id: mouse_area
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        height: input_field.height; width: input_field.height

        hoverEnabled: true
        onClicked: if(use_default_behaviour) hiding = !hiding
    }
}
