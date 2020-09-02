import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

ColumnLayout {
    property var result: ({ balance_change:"", fees: "", date: "", explorer_url: "" })
    property alias address: address.text
    property string custom_amount
    property alias tx_hash: tx_hash.text

    function onClose() {}

    ModalHeader {
        title: API.get().settings_pg.empty_string + (qsTr("Transaction Complete!"))
    }

    // Address
    TextWithTitle {
        id: address
        title: API.get().settings_pg.empty_string + (qsTr("Recipient's address"))
        visible: text !== ""
    }

    // Amount
    TextWithTitle {
        title: API.get().settings_pg.empty_string + (qsTr("Amount"))
        text: API.get().settings_pg.empty_string + (General.formatCrypto("", custom_amount !== "" ? custom_amount : result.balance_change, API.get().wallet_pg.ticker))
    }

    // Fees
    TextWithTitle {
        title: API.get().settings_pg.empty_string + (qsTr("Fees"))
        text: API.get().settings_pg.empty_string + (General.formatCrypto("", result.fees, General.txFeeTicker(API.get().wallet_pg)))
    }

    // Date
    TextWithTitle {
        title: API.get().settings_pg.empty_string + (qsTr("Date"))
        text: API.get().settings_pg.empty_string + (result.date)
    }

    // Transaction Hash
    TextWithTitle {
        id: tx_hash
        title: API.get().settings_pg.empty_string + (qsTr("Transaction Hash"))
    }

    // Buttons
    RowLayout {
        DefaultButton {
            text: API.get().settings_pg.empty_string + (qsTr("Close"))
            Layout.fillWidth: true
            onClicked: onClose()
        }
        PrimaryButton {
            text: API.get().settings_pg.empty_string + (qsTr("View at Explorer"))
            Layout.fillWidth: true
            onClicked: General.viewTxAtExplorer(API.get().wallet_pg.ticker, tx_hash.text)
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
