import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

ModalContent {
    property var result: ({ balance_change:"", fees: "", date: "", explorer_url: "" })
    property alias address: address.text
    property string custom_amount
    property alias tx_hash: tx_hash.text

    function onClose() {}

    title: API.app.settings_pg.empty_string + (qsTr("Transaction Complete!"))

    // Address
    TextWithTitle {
        id: address
        title: API.app.settings_pg.empty_string + (qsTr("Recipient's address"))
        visible: text !== ""
    }

    // Amount
    TextWithTitle {
        title: API.app.settings_pg.empty_string + (qsTr("Amount"))
        text: API.app.settings_pg.empty_string + (General.formatCrypto("", custom_amount !== "" ? custom_amount : result.balance_change, api_wallet_page.ticker))
    }

    // Fees
    TextWithTitle {
        title: API.app.settings_pg.empty_string + (qsTr("Fees"))
        text: API.app.settings_pg.empty_string + (General.formatCrypto("", result.fees, current_ticker_infos.fee_ticker))
    }

    // Date
    TextWithTitle {
        title: API.app.settings_pg.empty_string + (qsTr("Date"))
        text: API.app.settings_pg.empty_string + (result.date)
    }

    // Transaction Hash
    TextWithTitle {
        id: tx_hash
        title: API.app.settings_pg.empty_string + (qsTr("Transaction Hash"))
    }

    // Buttons
    footer: [
        DefaultButton {
            text: API.app.settings_pg.empty_string + (qsTr("Close"))
            Layout.fillWidth: true
            onClicked: onClose()
        },

        PrimaryButton {
            text: API.app.settings_pg.empty_string + (qsTr("View at Explorer"))
            Layout.fillWidth: true
            onClicked: General.viewTxAtExplorer(api_wallet_page.ticker, tx_hash.text)
        }
    ]
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
