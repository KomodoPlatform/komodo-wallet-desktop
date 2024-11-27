import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import Qaterial 1.0 as Qaterial
import Qt.labs.settings 1.0

import AtomicDEX.MarketMode 1.0
import AtomicDEX.TradingError 1.0


import "../../../../Components"
import "../../../../Constants"
import "../../../../Wallet"


Column
{
    id: bg
    Row
    {
        width: bg.width
        height: tx_fee_text.implicitHeight+25
        visible: false

        ColumnLayout
        {
            id: fees
            visible: valid_fee_info && !General.isZero(non_null_volume)

            Layout.leftMargin: 10
            Layout.rightMargin: Layout.leftMargin
            Layout.alignment: Qt.AlignLeft

            DexLabel
            {
                id: tx_fee_text
                text_value: General.feeText(curr_fee_info, base_ticker, true, true)
                font.pixelSize: Style.textSizeSmall1
                width: parent.width
                wrapMode: Text.Wrap
                DefaultInfoTrigger { triggerModal: cex_info_modal }
            }
        }


        DexLabel
        {
            //visible: !fees.visible
            visible: false
            text_value: !visible ? "" :
                                   last_trading_error === TradingError.BalanceIsLessThanTheMinimalTradingAmount
                                   ? (qsTr('Minimum fee') + ":     " + General.formatCrypto("", General.formatDouble(parseFloat(form_base.getMaxBalance()) - parseFloat(form_base.getMaxVolume())), base_ticker))
                                   : qsTr('Fees will be calculated')
            Layout.alignment: Qt.AlignCenter
            font.pixelSize: tx_fee_text.font.pixelSize
        }
    }
}
