import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Open Enable Coin Modal
DefaultModal {
    id: root


    function createNewOrder() {
        // Create a new order
    }

    function chooseOrder(price, volume) {
        // Choose this order
        root.close()
    }

    width: 900

    function getOrderList() {
        const ob = getCurrentOrderbook()

        return ["header"].concat(ob)
    }

    function isOrderLine(idx) {
        return idx > 0
    }

    // Inside modal
    ColumnLayout {
        id: modal_layout

        width: parent.width

        ModalHeader {
            title: qsTr("Orders")
        }

        // List
        ListView {
            id: list
            ScrollBar.vertical: ScrollBar {}
            implicitWidth: contentItem.childrenRect.width
            implicitHeight: contentItem.childrenRect.height

            model: getOrderList()

            clip: true

            delegate: Rectangle {
                property bool hovered: false

                color: hovered && model.modelData !== 'header' ? Style.colorTheme4 : "transparent"

                width: modal_layout.width
                height: 50

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: hovered = containsMouse
                    onClicked: isOrderLine(index) ? chooseOrder(model.modelData.ticker) : undefined
                }

                // Price
                DefaultText {
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width * 0.77

                    text: isOrderLine(index) ? model.modelData.price : qsTr("Price")
                    color: isOrderLine(index) ? Style.colorWhite4 : Style.colorWhite1
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Volume
                DefaultText {
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width * 0.44

                    text: isOrderLine(index) ? model.modelData.volume : qsTr("Volume")
                    color: isOrderLine(index) ? Style.colorWhite4 : Style.colorWhite1
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Receive amount
                DefaultText {
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width * 0.11

                    text: isOrderLine(index) ? getReceiveAmount(model.modelData.price) + " " + getTicker() : qsTr("Receive")
                    color: isOrderLine(index) ? Style.colorWhite4 : Style.colorWhite1
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Line
                HorizontalLine {
                    visible: index !== getOrderList().length - 1
                    width: parent.width
                    color: isOrderLine(index) ? Style.colorWhite9 : Style.colorWhite5
                    anchors.bottom: parent.bottom
                }
            }
        }

        // Buttons
        RowLayout {
            Button {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            }

            Button {
                text: qsTr("Create your own order")
                Layout.fillWidth: true
                onClicked: root.close()
            }
        }
    }
}
