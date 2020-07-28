import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"

// Open Enable Coin Modal
FloatingBackground {
    ColumnLayout {
        anchors.fill: parent

        function chooseOrder(order) {
            // Choose this order
            selectOrder(order)
        }

//        // List header
//        Item {
//            Layout.alignment: Qt.AlignTop

//            Layout.fillWidth: true

//            height: 50

//            // Price
//            DefaultText {
//                id: price_header
//                anchors.right: parent.right
//                anchors.rightMargin: parent.width * 0.77

//                text_value: API.get().empty_string + (qsTr("Price"))
//                color: Style.colorWhite1
//                anchors.verticalCenter: parent.verticalCenter
//            }

//            // Volume
//            DefaultText {
//                id: volume_header
//                anchors.right: parent.right
//                anchors.rightMargin: parent.width * 0.44

//                text_value: API.get().empty_string + (qsTr("Volume"))
//                color: Style.colorWhite1
//                anchors.verticalCenter: parent.verticalCenter
//            }

//            // Receive amount
//            DefaultText {
//                id: receive_header
//                anchors.right: parent.right
//                anchors.rightMargin: parent.width * 0.11

//                text_value: API.get().empty_string + (qsTr("Receive"))
//                color: Style.colorWhite1
//                anchors.verticalCenter: parent.verticalCenter
//            }

//            // Line
//            HorizontalLine {
//                width: parent.width
//                color: Style.colorWhite5
//                anchors.bottom: parent.bottom
//            }
//        }

        // List
        DefaultListView {
            id: list
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: getCurrentOrderbook().sort((a, b) => parseFloat(b.price) - parseFloat(a.price))

            delegate: Rectangle {
                color: mouse_area.containsMouse ? Style.colorTheme4 : "transparent"

                width: modal_layout.width
                height: 50

                MouseArea {
                    id: mouse_area
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: chooseOrder(model.modelData)
                }

                // Price
                DefaultText {
                    anchors.right: parent.right
                    anchors.rightMargin: price_header.anchors.rightMargin

                    text_value: API.get().empty_string + (General.formatDouble(model.modelData.price))
                    color: Style.colorWhite4
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Volume
                DefaultText {
                    anchors.right: parent.right
                    anchors.rightMargin: volume_header.anchors.rightMargin

                    text_value: API.get().empty_string + (model.modelData.volume)
                    color: Style.colorWhite4
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Receive amount
                DefaultText {
                    anchors.right: parent.right
                    anchors.rightMargin: receive_header.anchors.rightMargin

                    text_value: API.get().empty_string + (getReceiveAmount(model.modelData.price, model.modelData.volume) + " " + getTicker())
                    color: Style.colorWhite4
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Line
                HorizontalLine {
                    visible: index !== getCurrentOrderbook().length - 1
                    width: parent.width
                    color: Style.colorWhite9
                    anchors.bottom: parent.bottom
                }
            }
        }
    }
}
