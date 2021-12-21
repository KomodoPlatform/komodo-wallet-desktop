import QtQuick 2.15
import "../Constants"
import App 1.0

// Copy button
DefaultImage {
    source: General.image_path + "dashboard-copy.svg"
    visible: copyable
    scale: 0.8
    anchors.right: parent.right
    y: -height
    antialiasing: true

    opacity: mouse_area.containsMouse ? Style.hoverOpacity : 1

    DefaultMouseArea {
        id: mouse_area
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        height: input_field.height; width: input_field.height

        hoverEnabled: true
        onClicked: () => {
            input_field.selectAll()
            input_field.copy()
            toast.show(qsTr("Copied to Clipboard"), General.time_toast_basic_info, "", false)
        }
    }
}
