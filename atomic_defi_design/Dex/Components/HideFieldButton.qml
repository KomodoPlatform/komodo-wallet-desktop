import QtQuick 2.15
import "../Constants"
import App 1.0

DefaultImage {
    property alias mouseArea: mouseArea
    property bool use_default_behaviour: true
    source: General.image_path + "dashboard-eye" + (hiding ? "" : "-hide") + ".svg"
    visible: hidable
    scale: 0.8
    anchors.right: parent.right
    anchors.rightMargin: 5
    anchors.verticalCenter: parent.verticalCenter
    antialiasing: true

    opacity: mouseArea.containsMouse ? Style.hoverOpacity : 1

    DefaultMouseArea {
        id: mouseArea
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        height: input_field.height; width: input_field.height

        hoverEnabled: true
        onClicked: if(use_default_behaviour) hiding = !hiding
    }
}
