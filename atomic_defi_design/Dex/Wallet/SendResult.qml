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
        text: "%1 %2 (%3 %4)"
            .arg(api_wallet_page.ticker)
            .arg(custom_amount !== "" ? custom_amount : result.withdraw_answer.my_balance_change)
            .arg(API.app.settings_pg.current_fiat_sign)
            .arg(result.withdraw_answer.total_amount_fiat)
    }

    // Fees
    TextEditWithTitle
    {
        title: qsTr("Fees")
        text: "%1 %2 (%3 %4)".arg(current_ticker_infos.fee_ticker)
            .arg(result.withdraw_answer.fee_details.amount)
            .arg(API.app.settings_pg.current_fiat_sign)
            .arg(result.withdraw_answer.fee_details.amount_fiat)
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
        title: qsTr("Transaction Hash")
    }

    // Buttons
    footer:
    [
        Item
        {
            Layout.fillWidth: true
        },
        DexButton
        {
            text: qsTr("Close")
            leftPadding: 40
            rightPadding: 40
            radius: 18
            onClicked: close()
        },
        Item
        {
            Layout.fillWidth: true
        },
        DexAppOutlineButton
        {
            text: qsTr("View on Explorer")
            leftPadding: 40
            rightPadding: 40
            radius: 18
            onClicked: General.viewTxAtExplorer(api_wallet_page.ticker, tx_hash.text)
        },
        Item
        {
            Layout.fillWidth: true
        }
    ]
}
