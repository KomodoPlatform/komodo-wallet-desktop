import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

// Open Enable Coin Modal
ColumnLayout {
    id: root

    property bool is_asks: false
    property alias model: list.model
    function chooseOrder(order) {
        // Choose this order
        selectOrder(order)
    }

    // List header
    Item {
        Layout.fillWidth: true

        height: 50

        DefaultText {
            id: title
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: anchors.topMargin

            font.pixelSize: Style.textSizeSmall2

            text_value: API.get().empty_string + ((is_asks ? qsTr("Asks") : qsTr("Bids")) + " (" + model.length + ")")
            color: is_asks ? Style.colorRed : Style.colorGreen
            anchors.verticalCenter: parent.verticalCenter
        }

        // Price
        DefaultText {
            id: price_header
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.77

            text_value: API.get().empty_string + (qsTr("Price"))
            color: Style.colorWhite1
            anchors.verticalCenter: parent.verticalCenter
        }

        // Volume
        DefaultText {
            id: quantity_header
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.44

            text_value: API.get().empty_string + (qsTr("Volume"))
            color: Style.colorWhite1
            anchors.verticalCenter: parent.verticalCenter
        }

        // Total
        DefaultText {
            id: total_header
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.11

            text_value: API.get().empty_string + (qsTr("Total"))
            color: Style.colorWhite1
            anchors.verticalCenter: parent.verticalCenter
        }

        // Line
        HorizontalLine {
            width: parent.width
            color: Style.colorWhite5
            anchors.bottom: parent.bottom
        }
    }

    // List
    DefaultListView {
        id: list

        Layout.fillWidth: true
        Layout.fillHeight: true

        delegate: Rectangle {
            color: mouse_area.containsMouse ? Style.colorTheme4 : "transparent"

            width: root.width
            height: 50

            MouseArea {
                id: mouse_area
                anchors.fill: parent
                hoverEnabled: true
                //onClicked: chooseOrder(model.modelData)
            }

            // Price
            DefaultText {
                anchors.right: parent.right
                anchors.rightMargin: price_header.anchors.rightMargin

                text_value: API.get().empty_string + (General.formatDouble(price))
                color: title.color
                anchors.verticalCenter: parent.verticalCenter
            }

            // Quantity
            DefaultText {
                anchors.right: parent.right
                anchors.rightMargin: quantity_header.anchors.rightMargin

                text_value: API.get().empty_string + (quantity)
                color: Style.colorWhite4
                anchors.verticalCenter: parent.verticalCenter
            }

            // Total
            DefaultText {
                anchors.right: parent.right
                anchors.rightMargin: total_header.anchors.rightMargin

                text_value: API.get().empty_string + (total)
                color: Style.colorWhite4
                anchors.verticalCenter: parent.verticalCenter
            }

            // Line
            HorizontalLine {
                visible: index !== root.model.length - 1
                width: parent.width
                color: Style.colorWhite9
                anchors.bottom: parent.bottom
            }
        }
    }
}
