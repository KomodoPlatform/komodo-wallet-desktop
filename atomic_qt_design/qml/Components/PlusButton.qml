import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Constants"

// Add button
Rectangle {
    property alias mouse_area: mouse_area

    id: add_coin_button

    width: 50
    height: width

    color: mouse_area.containsMouse ? Style.colorTheme7 : "transparent"
    border.color: Style.colorThemeDark
    border.width: 2
    radius: 100

    Rectangle {
        id: vline
        width: parent.border.width
        height: parent.width * 0.30
        radius: parent.radius
        color: mouse_area.containsMouse ? Style.colorThemePassiveLight : Style.colorThemePassive
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        width: vline.height
        height: parent.border.width
        radius: parent.radius
        color: vline.color
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MouseArea {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: true
    }
}
