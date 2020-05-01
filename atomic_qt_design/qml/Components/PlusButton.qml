import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Constants"

// Add button
FloatingBackground {
    property alias mouse_area: mouse_area

    id: button_bg

    width: 50
    height: width

    rect.radius: 100
    rect.color: mouse_area.containsMouse ? Style.colorTheme6 : Style.colorTheme8

    MouseArea {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: true
    }

    content: Item {
        width: button_bg.width
        height: button_bg.height

        Rectangle {
            id: vline
            width: button_bg.rect.border.width*2
            height: button_bg.width * 0.30
            color: mouse_area.containsMouse ? Style.colorThemePassiveLight : Style.colorThemePassive
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: vline.height
            height: vline.width
            color: vline.color
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
