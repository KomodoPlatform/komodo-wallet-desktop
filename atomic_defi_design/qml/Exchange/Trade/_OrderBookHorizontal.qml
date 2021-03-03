import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../Components"
import "../../Constants"

Item {
    id: rootHort
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
            OrderBookListView {
                isAsk: false
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            OrderBookListView {
                isAsk: true
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}
