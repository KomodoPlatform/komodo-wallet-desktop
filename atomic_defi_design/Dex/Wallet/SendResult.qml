import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import App 1.0

MultipageModalContent
{
    id: root

    property var    result
    property alias  address: address.text
    property string custom_amount
    property alias  tx_hash: tx_hash.text

    titleText: qsTr("Transaction Complete!")

    // Address
    TextEditWithTitle
    {
        id: address
        title: qsTr("Recipient's address")
        visible: text !== ""
    }

    // Amount
    TextEditWithTitle
    {
        title: qsTr("Amount")

        text:
        {
            let amount = custom_amount !== "" ? custom_amount : result.withdraw_answer.my_balance_change
            !amount ? "" : General.formatCrypto(
                '',
                amount,
                api_wallet_page.ticker,
                API.app.get_fiat_from_amount(api_wallet_page.ticker, amount),
                API.app.settings_pg.current_fiat
            )
        }
    }

    // Fees
    TextEditWithTitle
    {
        title: qsTr("Fees")

        text:
        {
            let amount = result.withdraw_answer.fee_details.amount
            !amount ? "" : General.formatCrypto(
                '',
                amount,
                current_ticker_infos.fee_ticker,
                API.app.get_fiat_from_amount(current_ticker_infos.fee_ticker, amount),
                API.app.settings_pg.current_fiat
            )
        }
    }

    // Date
    TextEditWithTitle
    {
        title: qsTr("Date")
        text: result.withdraw_answer.date
    }

    // Transaction Hash
    TextEditWithTitle
    {
        id: tx_hash
        Layout.fillWidth: true
        title: qsTr("Transaction Hash")
    }

    // Buttons
    footer:
    [
        DexButton
        {
            Layout.fillWidth: true
            text: qsTr("Close")
            radius: 18
            onClicked: close()
        },
        DexAppOutlineButton
        {
            Layout.fillWidth: true
            text: qsTr("View on Explorer")
            radius: 18
            onClicked: General.viewTxAtExplorer(api_wallet_page.ticker, tx_hash.text)
        }
    ]
}
