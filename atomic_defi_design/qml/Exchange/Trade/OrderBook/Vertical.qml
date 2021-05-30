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
                spacing: 2
                List {
                    isAsk: true
                    isVertical: true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
                Item {
                    Layout.preferredHeight: 4
                    Layout.fillWidth: true
                    Rectangle {
                        width: parent.width
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: theme.surfaceColor
                    }
                }
                List {
                    isAsk: false
                    hide_header: true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
        }
    }
}
