import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

// Open Enable Coin Modal
DefaultModal {
    id: root

    width: 650
    readonly property var default_details: ({"is_default": true, "price":"","date":"","base":"","rel":"","cancellable":true,"am_i_maker":true,"base_amount":"1","rel_amount":"1","uuid":""})
    property var details
    property string current_item_uuid: ""

    // Inside modal
    ColumnLayout {
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter

        ModalHeader {
            title: API.get().empty_string + (details.is_recent_swap ? qsTr("Swap Details") : qsTr("Order Details"))
        }

        // Complete image
        Image {
            visible: details.is_recent_swap !== undefined && getStatus(details) === status_swap_successful
            Layout.alignment: Qt.AlignHCenter
            source: General.image_path + "exchange-trade-complete.svg"
        }

        DefaultBusyIndicator {
            visible: details.is_recent_swap !== undefined &&
                     getStatus(details) !== status_swap_successful &&
                     getStatus(details) !== status_swap_failed
            Layout.alignment: Qt.AlignHCenter
        }

        // Status Text
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            font.pixelSize: Style.textSize3
            visible: getStatus(details) !== status_swap_not_swap &&  // Is order
                     (details.events !== undefined || // Has events, ongoing or
                    details.am_i_maker === false) // Taker order with no events
            color: visible ? getStatusColor(details) : ''
            text_value: API.get().empty_string + (visible ? getStatusTextWithPrefix(details) : '')
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

        // Maker/Taker
        DefaultText {
            text_value: API.get().empty_string + (details.am_i_maker ? qsTr("Maker Order"): qsTr("Taker Order"))
            color: Style.colorThemeDarkLight
            Layout.alignment: Qt.AlignRight
        }

        // Refund state
        TextFieldWithTitle {
            Layout.topMargin: -20

            title: API.get().empty_string + (qsTr("Refund State"))
            field.text: {
                let str = API.get().empty_string
                const e = getLastEvent(details)

                if(e.state === "TakerPaymentWaitRefundStarted" ||
                   e.state === "MakerPaymentWaitRefundStarted") {
                    str += qsTr("Your swap failed but the auto-refund process for your payment started already. Please wait and keep application opened until you receive your payment back")
                }

                return str
            }
            field.readOnly: true

            visible: field.text !== ''
        }

        // Date
        TextWithTitle {
            title: API.get().empty_string + (qsTr("Date"))
            text: API.get().empty_string + (details.date)
            visible: text !== ''
        }

        // Swap ID / UUID
        TextWithTitle {
            title: API.get().empty_string + (details.is_recent_swap ? qsTr("Swap ID") : qsTr("UUID"))
            text: API.get().empty_string + (details.uuid)
            visible: text !== ''
        }

        // Payment ID
        TextWithTitle {
            title: API.get().empty_string + (details.am_i_maker ? qsTr("Maker Payment Sent ID") : qsTr("Maker Payment Spent ID"))
            text: API.get().empty_string + (getSwapPaymentID(details, false))
            visible: text !== ''
        }

        // Payment ID
        TextWithTitle {
            title: API.get().empty_string + (details.am_i_maker ? qsTr("Taker Payment Spent ID") : qsTr("Taker Payment Sent ID"))
            text: API.get().empty_string + (getSwapPaymentID(details, true))
            visible: text !== ''
        }

        // Error ID
        TextWithTitle {
            title: API.get().empty_string + (qsTr("Error ID"))
            text: API.get().empty_string + (getSwapError(details).state)
            visible: text !== ''
        }

        // Error Details
        TextFieldWithTitle {
            title: API.get().empty_string + (qsTr("Error Log"))
            field.text: API.get().empty_string + (getSwapError(details).data.error)
            field.readOnly: true
            copyable: true

            visible: field.text !== ''
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            }

            // Cancel button
            DangerButton {
                visible: details.cancellable !== undefined && details.cancellable
                Layout.fillWidth: true
                text: API.get().empty_string + (qsTr("Cancel Order"))
                onClicked: onCancelOrder(details.uuid)
            }

            PrimaryButton {
                text: API.get().empty_string + (qsTr("View at Explorer"))
                Layout.fillWidth: true
                visible: getSwapPaymentID(details, false) !== '' || getSwapPaymentID(details, true) !== ''
                onClicked: {
                    const maker_id = getSwapPaymentID(details, false)
                    const taker_id = getSwapPaymentID(details, true)
                    if(maker_id !== '') General.viewTxAtExplorer(details.maker_coin, maker_id, true)
                    if(taker_id !== '') General.viewTxAtExplorer(details.taker_coin, taker_id, true)
                }
            }
        }
    }
}
