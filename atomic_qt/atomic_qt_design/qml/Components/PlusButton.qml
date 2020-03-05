import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Constants"

// Add button
Rectangle {
    property alias mouse_area: mouse_area

    id: add_coin_button

    width: 50; height: width
    property bool hovered: false
    color: "transparent"
    border.color: hovered ? Style.colorTheme0 : Style.colorTheme3
    border.width: 2
    radius: 100

    Rectangle {
        width: parent.border.width
        height: parent.width * 0.5
        radius: parent.radius
        color: parent.border.color
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        width: parent.width * 0.5
        height: parent.border.width
        radius: parent.radius
        color: parent.border.color
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MouseArea {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: true
        onHoveredChanged: add_coin_button.hovered = containsMouse
    }
}
