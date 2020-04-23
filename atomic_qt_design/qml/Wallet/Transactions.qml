import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// List
ListView {
    ScrollBar.vertical: DefaultScrollBar {}
    implicitWidth: contentItem.childrenRect.width
    implicitHeight: contentItem.childrenRect.height

    model: API.get().current_coin_info.transactions
    clip: true

    function reset() {

    }

    // Row
    delegate: Rectangle {
        id: rectangle
        implicitWidth: parent.width
        height: 65

        visible: model.modelData.timestamp !== 0

        color: mouse_area.containsMouse ? Style.colorTheme8 : "transparent"

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

        // Icon
        Image {
            id: received_icon
            source: General.image_path + "circle-" + (model.modelData.received ? "success" : "failed") + ".png"
            fillMode: Image.PreserveAspectFit
            width: Style.textSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 15
        }

        // Description
        DefaultText {
            id: description
            text: API.get().empty_string + (model.modelData.received ? qsTr("Incoming transaction") : qsTr("Outgoing transaction"))
            font.pixelSize: Style.textSizeSmall3
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: received_icon.right
            anchors.leftMargin: 25
        }

        // Crypto
        DefaultText {
            id: crypto_amount
            text: API.get().empty_string + (General.formatCrypto(model.modelData.received, model.modelData.amount, API.get().current_coin_info.ticker))
            font.pixelSize: description.font.pixelSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.25
            color: model.modelData.received ? Style.colorGreen : Style.colorRed
        }

        // Fiat
        DefaultText {
            text: API.get().empty_string + (General.formatFiat(model.modelData.received, model.modelData.amount_fiat, API.get().fiat))
            font.pixelSize: description.font.pixelSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.45
            color: crypto_amount.color
        }

        // Fee
        DefaultText {
            text: API.get().empty_string + (General.formatCrypto(false, model.modelData.fees, API.get().current_coin_info.ticker) + " " + qsTr("transaction fee"))
            font.pixelSize: description.font.pixelSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.575
            color: Style.colorWhite4
        }

        // Date
        DefaultText {
            text: API.get().empty_string + (model.modelData.date)
            font.pixelSize: description.font.pixelSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 20
            color: Style.colorWhite4
        }

        HorizontalLine {
            visible: index !== API.get().current_coin_info.transactions.length -1
            width: parent.width
            color: Style.colorWhite7
            anchors.bottom: parent.bottom
        }
    }
}







/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
