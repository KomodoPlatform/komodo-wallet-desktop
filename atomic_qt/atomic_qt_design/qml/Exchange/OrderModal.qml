import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Enable Coin Modal
Popup {
    id: root
    anchors.centerIn: Overlay.overlay
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: Style.colorTheme6
        width: root.width
        height: root.height
    }


    width: 650
    property var details

    // Inside modal
    ColumnLayout {
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter

        ModalHeader {
            title: details.is_recent_swap ? qsTr("Swap Details") : qsTr("Order Details")
        }

        // Base
        Image {
            visible: getStatus(details) === status_swap_successful
            Layout.alignment: Qt.AlignHCenter
            source: General.image_path + "exchange-trade-complete.svg"
        }

        OrderContent {
            Layout.topMargin: 10
            width: 500
            height: 150
            Layout.alignment: Qt.AlignHCenter
            item: details
        }

        // Error ID
        TextWithTitle {
            title: qsTr("Error ID:")
            text: getSwapError(details)
            visible: text !== ''
        }

        // Taker Payment ID
        TextWithTitle {
            title: qsTr("Taker Payment ID:")
            text: getSwapPaymentID(details, true)
            visible: text !== ''
        }

        // Maker Payment ID
        TextWithTitle {
            title: qsTr("Maker Payment ID:")
            text: getSwapPaymentID(details, false)
            visible: text !== ''
        }

        // Buttons
        RowLayout {
            Button {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            }
            Button {
                text: qsTr("View at Explorer")
                Layout.fillWidth: true
                visible: getSwapPaymentID(details, false) !== ''|| getSwapPaymentID(details, true) !== ''
                onClicked: {
                    const maker_id = getSwapPaymentID(details, false)
                    const taker_id = getSwapPaymentID(details, true)
                    if(maker_id !== '') Qt.openUrlExternally(API.get().get_coin_info(details.maker_coin).explorer_url + "tx/" + maker_id)
                    if(taker_id !== '') Qt.openUrlExternally(API.get().get_coin_info(details.taker_coin).explorer_url + "tx/" + taker_id)
                }
            }
        }
    }
}
