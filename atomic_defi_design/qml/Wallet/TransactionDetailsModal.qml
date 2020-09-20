import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

// Open Transaction Details Modal
BasicModal {
    id: root

    function reset() {

    }

    property var details

    onClosed: {
        if(notes.field.enabled) notes.save_button.clicked()
        details = undefined
    }

    ModalContent {
        title: API.app.settings_pg.empty_string + (qsTr("Transaction Details"))

        // Amount
        TextWithTitle {
            title: API.app.settings_pg.empty_string + (qsTr("Amount"))
            text: API.app.settings_pg.empty_string + (!details ? "" :
                                                        General.formatCrypto(!details.am_i_sender, details.amount, api_wallet_page.ticker, details.amount_fiat, API.app.settings_pg.current_currency))
            value_color: !details ? "white" :
                         details.am_i_sender ? Style.colorRed : Style.colorGreen
            privacy: true
        }

        // Fees
        TextWithTitle {
            title: API.app.settings_pg.empty_string + (qsTr("Fees"))
            text: API.app.settings_pg.empty_string + (!details ? "" :
                                                        General.formatCrypto("", details.fees, current_ticker_infos.fee_ticker))
            privacy: true
        }

        // Date
        TextWithTitle {
            title: API.app.settings_pg.empty_string + (qsTr("Date"))
            text: API.app.settings_pg.empty_string + (!details ? "" :
                                                        details.timestamp === 0 ? qsTr("Unconfirmed"):  details.date)
        }

        // Transaction Hash
        TextWithTitle {
            title: API.app.settings_pg.empty_string + (qsTr("Transaction Hash"))
            text: API.app.settings_pg.empty_string + (!details ? "" :
                                                        details.tx_hash)
            privacy: true
        }

        // Confirmations
        TextWithTitle {
            title: API.app.settings_pg.empty_string + (qsTr("Confirmations"))
            text: API.app.settings_pg.empty_string + (!details ? "" :
                                                        details.confirmations)
        }

        // Block Height
        TextWithTitle {
            title: API.app.settings_pg.empty_string + (qsTr("Block Height"))
            text: API.app.settings_pg.empty_string + (!details ? "" :
                                                        details.blockheight)
        }

        AddressList {
            title: API.app.settings_pg.empty_string + (qsTr("From"))
            model: !details ? [] :
                   details.from
        }

        AddressList {
            title: API.app.settings_pg.empty_string + (qsTr("To"))
            model: !details ? [] :
                   details.to
        }

        // Notes
        TextAreaWithTitle {
            id: notes
            title: API.app.settings_pg.empty_string + (qsTr("Notes"))
            remove_newline: false
            field.text: !details ? "" :
                        details.transaction_note


            property string prev_text: ""
            field.onTextChanged: {
                if(field.text.length > 500)
                    field.text = prev_text
                else prev_text = field.text
            }

            onSaved: details.transaction_note = field.text
            saveable: true
        }

        // Buttons
        footer: [
            DefaultButton {
                text: API.app.settings_pg.empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            },

            DangerButton {
                visible: !details ? false :
                         !details.am_i_sender

                text: API.app.settings_pg.empty_string + (qsTr("Refund"))
                Layout.fillWidth: true
                onClicked: {
                    const address = details.from[0]
                    const amount = details.amount
                    root.close()
                    send_modal.address_field.text = address
                    send_modal.amount_field.text = amount
                    send_modal.open()
                }
            },

            PrimaryButton {
                text: API.app.settings_pg.empty_string + (qsTr("View at Explorer"))
                Layout.fillWidth: true
                onClicked: General.viewTxAtExplorer(api_wallet_page.ticker, details.tx_hash, false)
            }
        ]
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
