import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

ColumnLayout {
    id: root

    property bool is_asks: false
    property alias model: list.model

    spacing: 0

    // List header
    Item {
        Layout.fillWidth: true

        height: 40

        // Price
        DefaultText {
            id: price_header
            font.pixelSize: Style.textSizeSmall2

            text_value: API.get().empty_string + (is_asks ? qsTr("Ask Price") + "\n(" + getTicker(false) + ")":
                                                            qsTr("Bid Price") + "\n(" + getTicker(false) + ")")

            color: is_asks ? Style.colorRed : Style.colorGreen
            horizontalAlignment: is_asks ? Text.AlignLeft : Text.AlignRight

            anchors.left: is_asks ? parent.left : undefined
            anchors.right: is_asks ? undefined : parent.right
            anchors.leftMargin: is_asks ? parent.width * 0.03 : undefined
            anchors.rightMargin: is_asks ? undefined : parent.width * 0.03

            anchors.verticalCenter: parent.verticalCenter
        }

        // Quantity
        DefaultText {
            id: quantity_header
            anchors.left: is_asks ? parent.left : undefined
            anchors.right: is_asks ? undefined : parent.right
            anchors.leftMargin: is_asks ? parent.width * 0.32 : undefined
            anchors.rightMargin: is_asks ? undefined : parent.width * 0.32

            horizontalAlignment: price_header.horizontalAlignment

            font.pixelSize: price_header.font.pixelSize

            text_value: API.get().empty_string + (qsTr("Quantity") + "\n(" + getTicker(true) + ")")
            color: Style.colorWhite1
            anchors.verticalCenter: parent.verticalCenter
        }

        // Total
        DefaultText {
            id: total_header
            anchors.left: is_asks ? parent.left : undefined
            anchors.right: is_asks ? undefined : parent.right
            anchors.leftMargin: is_asks ? parent.width * 0.65 : undefined
            anchors.rightMargin: is_asks ? undefined : parent.width * 0.65

            horizontalAlignment: price_header.horizontalAlignment

            font.pixelSize: price_header.font.pixelSize

            text_value: API.get().empty_string + (qsTr("Total") + "\n(" + getTicker(false) + ")")
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

        scrollbar_visible: false

        Layout.fillWidth: true
        Layout.fillHeight: true

        delegate: Item {
            width: root.width
            height: 20

            Rectangle {
                visible: mouse_area.containsMouse
                width: parent.width
                height: parent.height
                color: Style.colorWhite1
                opacity: 0.2

                anchors.left: is_asks ? parent.left : undefined
                anchors.right: is_asks ? undefined : parent.right
            }

            Rectangle {
                width: parent.width * depth
                height: parent.height
                color: price_value.color
                opacity: 0.1

                anchors.left: is_asks ? parent.left : undefined
                anchors.right: is_asks ? undefined : parent.right
            }

            MouseArea {
                id: mouse_area
                anchors.fill: parent
                hoverEnabled: true
                //onClicked: selectOrder(model.modelData)
            }

            // Price
            DefaultText {
                id: price_value

                anchors.left: is_asks ? parent.left : undefined
                anchors.right: is_asks ? undefined : parent.right
                anchors.leftMargin: price_header.anchors.leftMargin
                anchors.rightMargin: price_header.anchors.rightMargin

                font.pixelSize: Style.textSizeSmall1

                text_value: API.get().empty_string + (General.formatDouble(price))
                color: price_header.color
                anchors.verticalCenter: parent.verticalCenter
            }

            // Quantity
            DefaultText {
                id: quantity_value
                anchors.left: is_asks ? parent.left : undefined
                anchors.right: is_asks ? undefined : parent.right
                anchors.leftMargin: quantity_header.anchors.leftMargin
                anchors.rightMargin: quantity_header.anchors.rightMargin

                font.pixelSize: price_value.font.pixelSize

                text_value: API.get().empty_string + (quantity)
                color: Style.colorWhite4
                anchors.verticalCenter: parent.verticalCenter
            }

            // Total
            DefaultText {
                id: total_value
                anchors.left: is_asks ? parent.left : undefined
                anchors.right: is_asks ? undefined : parent.right
                anchors.leftMargin: total_header.anchors.leftMargin
                anchors.rightMargin: total_header.anchors.rightMargin

                font.pixelSize: price_value.font.pixelSize

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
