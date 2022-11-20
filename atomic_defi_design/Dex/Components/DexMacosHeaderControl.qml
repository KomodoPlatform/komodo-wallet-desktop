import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.12

import Qaterial 1.0 as Qaterial
import ModelHelper 0.1

import "../Constants"

Row
{
    id: _headerControlRow

    property real size: 13
    property bool hovered: minimizeButton.containsMouse || closeButton.containsMouse || extendButton.containsMouse
    property var  orders: API.app.orders_mdl.orders_proxy_mdl.ModelHelper

    anchors.top: parent.top
    width: 195
    x: 15
    height: 40
    spacing: 9

    Rectangle
    {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.size
        height: width
        radius: width / 2
        color: closeButton.containsPress ? Qt.lighter("#FF5E57") : "#FF5E57"

        Qaterial.ColorIcon
        {
            visible: _headerControlRow.hovered
            anchors.centerIn: parent
            source: Qaterial.Icons.close
            iconSize: parent.width - 2
            color: 'black'
        }

        MouseArea
        {
            id: closeButton
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                if (orders.count === 0 || !API.app.wallet_mgr.log_status()) Qt.quit()
                else app.logout_confirm_modal.open()
            }
        }
    }

    Rectangle
    {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.size
        height: width
        radius: width / 2
        color: minimizeButton.containsPress ? Qt.lighter("#FFBC2C") : "#FFBC2C"

        Qaterial.ColorIcon
        {
            anchors.centerIn: parent
            visible: _headerControlRow.hovered
            source: Qaterial.Icons.windowMinimize
            iconSize: parent.width - 2
            color: 'black'
        }

        MouseArea
        {
            id: minimizeButton
            hoverEnabled: true
            anchors.fill: parent
            onClicked: window.showMinimized()
        }
    }

    Rectangle
    {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.size
        height: width
        radius: width / 2
        color: extendButton.containsPress ? Qt.lighter("#26CA42") : "#26CA42"

        Qaterial.ColorIcon
        {
            visible: _headerControlRow.hovered
            anchors.centerIn: parent
            source: window.visibility === ApplicationWindow.Maximized ? Qaterial.Icons.arrowCollapse : Qaterial.Icons.arrowExpand
            iconSize: parent.width - 2
            color: 'black'
        }

        MouseArea
        {
            id: extendButton
            hoverEnabled: true
            anchors.fill: parent
            onClicked:
            {
                if (window.visibility === ApplicationWindow.Maximized) window.showNormal()
                else window.showMaximized()
            }
        }
    }


}
