import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

// Open Transaction Details Modal
DefaultModal {
    id: root

    function reset() {

    }

    property var details
    contentWidth: layout.width

    onClosed: details = undefined


    // Inside modal
    ColumnLayout {
        id: layout
        width: 700

        ModalHeader {
            title: API.get().settings_pg.empty_string + (qsTr("Transaction Details"))
        }

        // Amount
        TextWithTitle {
            title: API.get().settings_pg.empty_string + (qsTr("Amount"))
            text: API.get().settings_pg.empty_string + (!details ? "" :
                                                        General.formatCrypto(!details.am_i_sender, details.amount, api_wallet_page.ticker, details.amount_fiat, API.get().settings_pg.current_currency))
            value_color: !details ? "white" :
                         details.am_i_sender ? Style.colorRed : Style.colorGreen
            privacy: true
        }

        // Fees
        TextWithTitle {
            title: API.get().settings_pg.empty_string + (qsTr("Fees"))
            text: API.get().settings_pg.empty_string + (!details ? "" :
                                                        General.formatCrypto("", details.fees, General.txFeeTicker(api_wallet_page)))
            privacy: true
        }

        // Date
        TextWithTitle {
            title: API.get().settings_pg.empty_string + (qsTr("Date"))
            text: API.get().settings_pg.empty_string + (!details ? "" :
                                                        details.timestamp === 0 ? qsTr("Unconfirmed"):  details.date)
        }

        // Transaction Hash
        TextWithTitle {
            title: API.get().settings_pg.empty_string + (qsTr("Transaction Hash"))
            text: API.get().settings_pg.empty_string + (!details ? "" :
                                                        details.tx_hash)
            privacy: true
        }

        // Confirmations
        TextWithTitle {
            title: API.get().settings_pg.empty_string + (qsTr("Confirmations"))
            text: API.get().settings_pg.empty_string + (!details ? "" :
                                                        details.confirmations)
        }

        // Block Height
        TextWithTitle {
            title: API.get().settings_pg.empty_string + (qsTr("Block Height"))
            text: API.get().settings_pg.empty_string + (!details ? "" :
                                                        details.blockheight)
        }

        AddressList {
            title: API.get().settings_pg.empty_string + (qsTr("From"))
            model: !details ? [] : details.from
        }

        AddressList {
            title: API.get().settings_pg.empty_string + (qsTr("To"))
            model: !details ? [] : details.to
        }

        // Buttons
        RowLayout {
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            }
            PrimaryButton {
                text: API.get().settings_pg.empty_string + (qsTr("View at Explorer"))
                Layout.fillWidth: true
                onClicked: General.viewTxAtExplorer(api_wallet_page.ticker, details.tx_hash, false)
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
