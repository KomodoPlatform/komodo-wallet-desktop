import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Transaction Details Modal
DefaultModal {
    id: root

    function reset() {

    }

    property var details

    // Inside modal
    ColumnLayout {
        ModalHeader {
            title: API.get().empty_string + (qsTr("Transaction Details"))
        }

        // Amount
        TextWithTitle {
            title: API.get().empty_string + (qsTr("Amount"))
            text: API.get().empty_string + (General.formatCrypto(details.received, details.amount, API.get().current_coin_info.ticker, details.amount_fiat, API.get().fiat))
            value_color: details.received ? Style.colorGreen : Style.colorRed
        }

        // Fees
        TextWithTitle {
            title: API.get().empty_string + (qsTr("Fees"))
            text: API.get().empty_string + (General.formatCrypto("", details.fees, API.get().current_coin_info.ticker))
        }

        // Date
        TextWithTitle {
            title: API.get().empty_string + (qsTr("Date"))
            text:API.get().empty_string + (details.timestamp === 0 ? qsTr("Unconfirmed"):  details.date)
        }

        // Transaction Hash
        TextWithTitle {
            title: API.get().empty_string + (qsTr("Transaction Hash"))
            text: API.get().empty_string + (details.tx_hash)
        }

        // Confirmations
        TextWithTitle {
            title: API.get().empty_string + (qsTr("Confirmations"))
            text: API.get().empty_string + (details.confirmations)
        }

        // Block Height
        TextWithTitle {
            title: API.get().empty_string + (qsTr("Block Height"))
            text: API.get().empty_string + (details.blockheight)
        }

        AddressList {
            title: API.get().empty_string + (qsTr("From"))
            model: details.from
        }

        AddressList {
            title: API.get().empty_string + (qsTr("To"))
            model: details.to
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            }
            PrimaryButton {
                text: API.get().empty_string + (qsTr("View at Explorer"))
                Layout.fillWidth: true
                onClicked: Qt.openUrlExternally(API.get().current_coin_info.explorer_url + "tx/" + details.tx_hash)
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
