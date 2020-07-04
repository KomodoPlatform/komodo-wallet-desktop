import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultListView {
    id: list

    readonly property int row_height: 45

    model: {
        const confirmed = API.get().current_coin_info.transactions.filter(t => t.timestamp !== 0)
        const unconfirmed = API.get().current_coin_info.transactions.filter(t => t.timestamp === 0)
        return unconfirmed.concat(confirmed)
    }

    // Row
    delegate: Rectangle {
        id: rectangle
        implicitWidth: list.width
        height: row_height

        color: mouse_area.containsMouse ? Style.colorTheme6 : "transparent"

        MouseArea {
            id: mouse_area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: tx_details_modal.open()
        }

        TransactionDetailsModal {
            id: tx_details_modal
            details: model.modelData
        }

        Arrow {
            id: received_icon
            up: !model.modelData.received
            color: model.modelData.received ? Style.colorGreen : Style.colorRed
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 15
        }

        // Description
        DefaultText {
            id: description
            text_value: API.get().empty_string + (model.modelData.received ? qsTr("Incoming transaction") : qsTr("Outgoing transaction"))
            font.pixelSize: Style.textSizeSmall1
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: received_icon.right
            anchors.leftMargin: 25
        }

        // Crypto
        DefaultText {
            id: crypto_amount
            text_value: API.get().empty_string + (General.formatCrypto(model.modelData.received, model.modelData.amount, API.get().current_coin_info.ticker))
            font.pixelSize: description.font.pixelSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.25
            color: model.modelData.received ? Style.colorGreen : Style.colorRed
        }

        // Fiat
        DefaultText {
            text_value: API.get().empty_string + (General.formatFiat(model.modelData.received, model.modelData.amount_fiat, API.get().fiat))
            font.pixelSize: description.font.pixelSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.45
            color: crypto_amount.color
        }

        // Fee
        DefaultText {
            text_value: API.get().empty_string + (General.formatCrypto(!(parseFloat(model.modelData.fees) > 0), Math.abs(parseFloat(model.modelData.fees)), API.get().current_coin_info.ticker) + " " + qsTr("transaction fee"))
            font.pixelSize: description.font.pixelSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.575
        }

        // Date
        DefaultText {
            font.pixelSize: description.font.pixelSize
            text_value: API.get().empty_string + (model.modelData.timestamp === 0 ? qsTr("Unconfirmed"):  model.modelData.date)
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 20
        }

        HorizontalLine {
            visible: index !== API.get().current_coin_info.transactions.length -1
            width: parent.width - 4

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -height/2
            light: true
        }
    }
}






/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
