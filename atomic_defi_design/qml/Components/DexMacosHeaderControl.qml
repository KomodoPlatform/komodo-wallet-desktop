import QtQuick 2.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.12

import "../Constants"
import App 1.0

Row {
    id: _headerControlRow
    property real size: 13
    property bool hovered: minimizeButton.containsMouse || closeButton.containsMouse || extendButton.containsMouse
    width: 195
    x: 15
    height: 40
    spacing: 9
    anchors.top: parent.top
    anchors.topMargin: 0
    Rectangle {
        width: parent.size
        height: width
        radius: width / 2
        color: closeButton.containsPress ? Qt.lighter("#FF5E57") : "#FF5E57"
        anchors.verticalCenter: parent.verticalCenter
        Qaterial.ColorIcon {
            visible: _headerControlRow.hovered
            anchors.centerIn: parent
            source: Qaterial.Icons.close
            iconSize: parent.width - 2
            color: 'black'
        }
        MouseArea {
            id: closeButton
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                Qt.quit()
                console.log("Window.visibility: " + window.visibility)
            }
        }
    }
    Rectangle {
        width: parent.size
        height: width
        radius: width / 2
        color: minimizeButton.containsPress ? Qt.lighter("#FFBC2C") : "#FFBC2C"
        Qaterial.ColorIcon {
            visible: _headerControlRow.hovered
            anchors.centerIn: parent
            source: Qaterial.Icons.windowMinimize
            iconSize: parent.width - 2
            color: 'black'
        }
        anchors.verticalCenter: parent.verticalCenter
        MouseArea {
            id: minimizeButton
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                window.showMinimized()
            }
        }
    }
    Rectangle {
        width: parent.size
        height: width
        radius: width / 2
        color: extendButton.containsPress ? Qt.lighter("#26CA42") : "#26CA42"
        Qaterial.ColorIcon {
            visible: _headerControlRow.hovered
            anchors.centerIn: parent
            source: window.visibility === ApplicationWindow.Maximized ? Qaterial.Icons.arrowCollapse : Qaterial.Icons.arrowExpand
            iconSize: parent.width - 2
            color: 'black'
        }
        anchors.verticalCenter: parent.verticalCenter
        MouseArea {
            id: extendButton
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                if (window.visibility === ApplicationWindow.Maximized) {
                    window.showNormal()
                } else {
                    window.showMaximized()
                }
            }
        }
    }


}