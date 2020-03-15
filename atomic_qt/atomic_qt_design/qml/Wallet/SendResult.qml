import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

ColumnLayout {
    property var result: ({ balance_change:"", fees: "", date: "", explorer_url: "" })
    property alias address: address.text
    property string custom_amount
    property alias tx_hash: tx_hash.text

    function onClose() {}

    ModalHeader {
        title: qsTr("Transaction Complete!")
    }

    // Address
    TextWithTitle {
        id: address
        title: qsTr("Recipient's address")
        visible: text !== ""
    }

    // Amount
    TextWithTitle {
        title: qsTr("Amount")
        text: API.get().empty_string + (General.formatCrypto("", custom_amount !== "" ? custom_amount : result.balance_change, API.get().current_coin_info.ticker))
    }

    // Fees
    TextWithTitle {
        title: qsTr("Fees")
        text: API.get().empty_string + (result.fees)
    }

    // Date
    TextWithTitle {
        title: qsTr("Date")
        text: API.get().empty_string + (result.date)
    }

    // Transaction Hash
    TextWithTitle {
        id: tx_hash
        title: qsTr("Transaction Hash")
    }

    // Buttons
    RowLayout {
        DefaultButton {
            text: API.get().empty_string + (qsTr("Close"))
            Layout.fillWidth: true
            onClicked: onClose()
        }
        PrimaryButton {
            text: API.get().empty_string + (qsTr("View at Explorer"))
            Layout.fillWidth: true
            onClicked: Qt.openUrlExternally(result.explorer_url + "tx/" + tx_hash.text)
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
