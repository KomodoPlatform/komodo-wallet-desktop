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

    property real _categoryColumnWidth: 140
    property real _cryptoColumnWidth: 170
    property real _fiatColumnWidth: 170
    property real _feeColumnWidth: 225
    property real _dateColumnWidth: 170

    ModalLoader
    {
        id: tx_details_modal
        sourceComponent: TransactionDetailsModal {}
    }

    // Row
    delegate: DexRectangle
    {
        id: rectangle
        width: list.width
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

        RowLayout {
            id: tx_row
            anchors.fill: parent
            anchors.margins: 15

            RowLayout {
                spacing: 3
                Layout.preferredWidth: _categoryColumnWidth
                Circle
                {
                    id: note_tag
                    width: 6
                    color: Style.colorOrange
                    visible: transaction_note !== ""
                }

                TransactionArrow
                {
                    id: received_icon
                    amISender: am_i_sender ? true : false
                }

                // Description
                DexLabel
                {
                    id: description
                    horizontalAlignment: Qt.AlignLeft
                    text_value: am_i_sender ? qsTr("Sent") : qsTr("Received")
                    font.pixelSize: Style.textSizeSmall3
                }
            }

            // Crypto
            DexLabel
            {
                id: crypto_amount
                Layout.preferredWidth: _cryptoColumnWidth
                horizontalAlignment: Text.AlignRight
                text_value:
                {
                    api_wallet_page.ticker.length > 6 
                    ? General.formatCrypto(!am_i_sender, amount, '', false, false, 6, true)
                    : General.formatCrypto(!am_i_sender, amount, api_wallet_page.ticker, false, false, 6, true)

                }
                font.pixelSize: description.font.pixelSize
                color: am_i_sender ? Dex.CurrentTheme.noColor : Dex.CurrentTheme.okColor
                privacy: true
            }

            // Fiat
            DexLabel
            {
                Layout.preferredWidth: _fiatColumnWidth
                horizontalAlignment: Text.AlignRight
                text_value: General.formatFiat(!am_i_sender, amount_fiat, API.app.settings_pg.current_currency)
                font.pixelSize: description.font.pixelSize
                color: crypto_amount.color
                privacy: true
            }

            // Fee
            DexLabel
            {
                Layout.preferredWidth: _feeColumnWidth
                horizontalAlignment: Text.AlignRight
                text_value: General.formatCrypto(!(parseFloat(fees) > 0), Math.abs(parseFloat(fees)),
                                                                           current_ticker_infos.fee_ticker + " " + qsTr("fees"))
                font.pixelSize: description.font.pixelSize
                privacy: true
            }

            // Date
            DexLabel
            {
                Layout.preferredWidth: _dateColumnWidth
                horizontalAlignment: Text.AlignRight
                font.pixelSize: description.font.pixelSize
                text_value: !date || unconfirmed ? qsTr("Unconfirmed") : date
                privacy: true
            }
        }
    }
}
