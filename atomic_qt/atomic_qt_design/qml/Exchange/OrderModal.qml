import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Enable Coin Modal
DefaultModal {
    id: root

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

        // Complete image
        Image {
            visible: details.is_recent_swap !== undefined && getStatus(details) === status_swap_successful
            Layout.alignment: Qt.AlignHCenter
            source: General.image_path + "exchange-trade-complete.svg"
        }

        BusyIndicator {
            visible: details.is_recent_swap !== undefined &&
                     getStatus(details) !== status_swap_successful &&
                     getStatus(details) !== status_swap_failed
            Layout.alignment: Qt.AlignHCenter
        }

        // Status Text
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            font.pointSize: Style.textSize3
            visible: getStatus(details) !== status_swap_not_swap && (details.events !== undefined || details.am_i_maker === false)
            color: visible ? getStatusColor(item) : ''
            text: visible ? qsTr(getStatusTextWithPrefix(item)) : ''
        }

        OrderContent {
            Layout.topMargin: 25
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: Layout.leftMargin
            height: 120
            Layout.alignment: Qt.AlignHCenter
            item: details
            in_modal: true
        }

        HorizontalLine {
            Layout.fillWidth: true
            Layout.bottomMargin: 20
            color: Style.colorWhite8
        }

        // Date
        TextWithTitle {
            title: qsTr("Date:")
            text: details.date
            visible: text !== ''
        }

        // Swap ID / UUID
        TextWithTitle {
            title: (item.is_recent_swap ? qsTr("Swap ID") : qsTr("UUID")) + ": "
            text: details.uuid
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

        // Error ID
        TextWithTitle {
            title: qsTr("Error ID:")
            text: getSwapError(details).state
            visible: text !== ''
        }

        // Error Details
        TextFieldWithTitle {
            title: qsTr("Error Log:")
            field.text: getSwapError(details).data.error
            field.readOnly: true
            copyable: true

            visible: field.text !== ''
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            }

            // Cancel button
            DangerButton {
                visible: details.cancellable !== undefined && details.cancellable
                Layout.fillWidth: true
                text: qsTr("Cancel")
                onClicked: onCancelOrder(details.uuid)
            }

            PrimaryButton {
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
