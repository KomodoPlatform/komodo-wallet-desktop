import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../Components"
import "../Constants"

// Open Enable Coin Modal
Popup {
    id: root
    anchors.centerIn: Overlay.overlay
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var details

    // Inside modal
    ColumnLayout {
        ModalHeader {
            title: qsTr("Transaction Details")
        }

        // Amount
        TextWithTitle {
            title: qsTr("Amount:")
            text: (details.received ? "+" : "-") + General.formatCrypto(details.amount, API.get().current_coin_info.ticker, details.amount_fiat, API.get().fiat)
            value_color: details.received ? Style.colorGreen : Style.colorRed
        }

        // Fees
        TextWithTitle {
            title: qsTr("Fees:")
            text: General.formatCrypto(details.fees, API.get().current_coin_info.ticker)
        }

        // Date
        TextWithTitle {
            title: qsTr("Date:")
            text: details.date
        }

        // Transaction Hash
        TextWithTitle {
            title: qsTr("Transaction Hash:")
            text: details.tx_hash
        }

        // Confirmations
        TextWithTitle {
            title: qsTr("Confirmations:")
            text: details.confirmations
        }

        // Block Height
        TextWithTitle {
            title: qsTr("Block Height:")
            text: details.blockheight
        }

        AddressList {
            title: qsTr("From")
            model: details.from
        }

        AddressList {
            title: qsTr("To")
            model: details.to
        }

        // Buttons
        RowLayout {
            Button {
                text: qsTr("Close")
                Layout.fillWidth: true
                onClicked: root.close()
            }
            Button {
                text: qsTr("View at Explorer")
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
