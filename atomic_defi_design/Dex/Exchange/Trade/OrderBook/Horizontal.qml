import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import App 1.0

import "../../../Components"

Item {
    id: orderBook
    Layout.fillHeight: true
    Layout.fillWidth: true

    InnerBackground {
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        radius: 6
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            spacing: 0

            List {
                isAsk: false
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            List {
                isAsk: true
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}
