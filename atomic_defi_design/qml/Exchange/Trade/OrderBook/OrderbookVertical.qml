import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import "../../../Components"

Item {
    id: orderBook
    visible: isUltraLarge

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        InnerBackground {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 2
            color: 'transparent'
            ColumnLayout {
                anchors.fill: parent
                spacing: 5
                OrderBookListView {
                    isAsk: true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
                OrderBookListView {
                    isAsk: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
        }
    }
}
