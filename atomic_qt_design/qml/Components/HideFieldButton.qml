import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

// Hide button
Image {
    property alias mouse_area: mouse_area
    property bool use_default_behaviour: true
    source: General.image_path + "dashboard-eye" + (hiding ? "" : "-hide") + ".svg"
    visible: hidable
    scale: 0.8
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: input_field.height * -0.0625
    antialiasing: true


    MouseArea {
        id: mouse_area
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        height: input_field.height; width: input_field.height
        onClicked: if(use_default_behaviour) hiding = !hiding
    }
}
