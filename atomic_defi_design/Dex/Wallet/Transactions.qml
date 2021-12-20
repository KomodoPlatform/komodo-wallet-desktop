import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import Dex.Themes 1.0 as Dex

DefaultListView
{
    id: list

    readonly property int row_height: 45

    ModalLoader
    {
        id: tx_details_modal
        sourceComponent: TransactionDetailsModal {}
    }

    // Row
    delegate: DexRectangle
    {
        id: rectangle
        implicitWidth: list.width
        height: row_height
        radius: 0
        border.width: 0
        colorAnimation: false
        color: mouse_area.containsMouse ? Dex.CurrentTheme.buttonColorHovered : 'transparent'

        DexMouseArea
        {
            id: mouse_area
            anchors.fill: parent
            hoverEnabled: true
            onClicked:
            {
                tx_details_modal.open()
                tx_details_modal.item.details = model
            }
        }

        Circle
        {
            id: note_tag
            width: 6
            color: Style.colorOrange
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            visible: transaction_note !== ""
        }

        Arrow
        {
            id: received_icon
            up: am_i_sender ? true : false
            color: !am_i_sender ? Dex.CurrentTheme.arrowUpColor : Dex.CurrentTheme.arrowDownColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: note_tag.right
            anchors.leftMargin: 10
        }

        // Description
        DefaultText
        {
            id: description
            text_value: am_i_sender ? qsTr("Sent") : qsTr("Received")
            font.pixelSize: Style.textSizeSmall3
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: received_icon.right
            anchors.leftMargin: 10
        }

        // Crypto
        DefaultText
        {
            id: crypto_amount
            text_value: General.formatCrypto(!am_i_sender, amount, api_wallet_page.ticker)
            font.pixelSize: description.font.pixelSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.2
            color: am_i_sender ? Dex.CurrentTheme.noColor : Dex.CurrentTheme.okColor
            privacy: true
        }

        // Fiat
        DefaultText
        {
            text_value: General.formatFiat(!am_i_sender, amount_fiat, API.app.settings_pg.current_currency)
            font.pixelSize: description.font.pixelSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.4
            color: crypto_amount.color
            privacy: true
        }

        // Fee
        DefaultText
        {
            text_value: General.formatCrypto(!(parseFloat(fees) > 0), Math.abs(parseFloat(fees)),
                                                                       current_ticker_infos.fee_ticker + " " + qsTr("fees"))
            font.pixelSize: description.font.pixelSize
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.575
            privacy: true
        }

        // Date
        DefaultText
        {
            font.pixelSize: description.font.pixelSize
            text_value: !date || unconfirmed ? qsTr("Unconfirmed") : date
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 20
            privacy: true
        }
    }
}
