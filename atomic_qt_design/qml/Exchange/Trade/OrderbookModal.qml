import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Open Enable Coin Modal
DefaultModal {
    id: root

    function createNewOrder() {
        prepareCreateMyOwnOrder()
        root.close()
    }

    function chooseOrder(price, volume) {
        // Choose this order
        selectOrder(price, volume)
        root.close()
    }

    width: 900
    height: 600

    // Inside modal
    ColumnLayout {
        id: modal_layout

        width: parent.width
        height: parent.height

        ModalHeader {
            title: API.get().empty_string + (qsTr("Orderbook"))
            bottomMargin: 0
        }

        // List header
        Rectangle {
            color: "transparent"

            Layout.alignment: Qt.AlignTop

            Layout.fillWidth: true

            height: 50

            // Price
            DefaultText {
                id: price_header
                anchors.right: parent.right
                anchors.rightMargin: parent.width * 0.77

                text: API.get().empty_string + (qsTr("Price"))
                color: Style.colorWhite1
                anchors.verticalCenter: parent.verticalCenter
            }

            // Volume
            DefaultText {
                id: volume_header
                anchors.right: parent.right
                anchors.rightMargin: parent.width * 0.44

                text: API.get().empty_string + (qsTr("Volume"))
                color: Style.colorWhite1
                anchors.verticalCenter: parent.verticalCenter
            }

            // Receive amount
            DefaultText {
                id: receive_header
                anchors.right: parent.right
                anchors.rightMargin: parent.width * 0.11

                text: API.get().empty_string + (qsTr("Receive"))
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
        ListView {
            id: list
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.vertical: ScrollBar {}

            model: getCurrentOrderbook().sort((a, b) => parseFloat(b.price) - parseFloat(a.price))

            clip: true

            delegate: Rectangle {
                property bool hovered: false

                color: hovered ? Style.colorTheme4 : "transparent"

                width: modal_layout.width
                height: 50

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: hovered = containsMouse
                    onClicked: chooseOrder(model.modelData.price, model.modelData.volume)
                }

                // Price
                DefaultText {
                    anchors.right: parent.right
                    anchors.rightMargin: price_header.anchors.rightMargin

                    text: API.get().empty_string + (General.formatDouble(model.modelData.price))
                    color: Style.colorWhite4
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Volume
                DefaultText {
                    anchors.right: parent.right
                    anchors.rightMargin: volume_header.anchors.rightMargin

                    text: API.get().empty_string + (model.modelData.volume)
                    color: Style.colorWhite4
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Receive amount
                DefaultText {
                    anchors.right: parent.right
                    anchors.rightMargin: receive_header.anchors.rightMargin

                    text: API.get().empty_string + (getReceiveAmount(model.modelData.price) + " " + getTicker())
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

        // Buttons
        RowLayout {
            Layout.alignment: Qt.AlignBottom
            DefaultButton {
                text: API.get().empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            PrimaryButton {
                text: API.get().empty_string + (qsTr("Create your own order"))
                Layout.fillWidth: true
                onClicked: createNewOrder()
            }
        }
    }
}
