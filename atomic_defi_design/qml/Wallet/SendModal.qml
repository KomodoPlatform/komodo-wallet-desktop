import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

BasicModal {
    id: root

    property alias address_field: input_address.field
    property alias amount_field: input_amount.field


    onClosed: if(root.currentIndex === 2) reset(true)

    // Local
    readonly property var default_send_result: ({ has_error: false, error_message: "",
                                                    withdraw_answer: {
                                                        tx_hex: "", date: "", "fee_details": { total_fee: "" }
                                                    },
                                                    explorer_url: "", max: false })
    property var send_result: default_send_result


    readonly property bool is_send_busy: api_wallet_page.is_send_busy
    readonly property var send_rpc_result: api_wallet_page.send_rpc_data

    readonly property bool is_broadcast_busy: api_wallet_page.is_broadcast_busy
    readonly property string broadcast_result: api_wallet_page.broadcast_rpc_data
    property bool async_param_max: false

    onSend_rpc_resultChanged: {
        send_result = General.clone(send_rpc_result)

        // Local var, faster
        const result = send_result

        if(result.error_code) {
            root.close()
            console.log("Send Error:", result.error_code, " Message:", result.error_message)
            toast.show(qsTr("Failed to send"), General.time_toast_important_error, result.error_message)
        }
        else {
            if(!result.withdraw_answer) {
                reset()
                return
            }

            const max = async_param_max
            send_result.withdraw_answer.max = max

            if(max) input_amount.field.text = API.get().is_pin_cfg_enabled() ? General.absString(result.withdraw_answer.my_balance_change) : result.withdraw_answer.total_amount

            // Change page
            root.currentIndex = 1
        }
    }

    onBroadcast_resultChanged: {
        if(root.visible && broadcast_result !== "")
            root.currentIndex = 2
    }

    function prepareSendCoin(address, amount, with_fees, fees_amount, is_special_token, gas_limit, gas_price) {
        let max = input_max_amount.checked || parseFloat(current_ticker_infos.balance) === parseFloat(amount)

        // Save for later check
        async_param_max = max

        if(with_fees && max === false && !is_special_token)
            max = parseFloat(amount) + parseFloat(fees_amount) >= parseFloat(current_ticker_infos.balance)

        const fees_info = {
            fees_amount,
            gas_price,
            gas_limit: gas_limit === "" ? 0 : parseInt(gas_limit)
        }

        console.log("Passing fees info: ", JSON.stringify(fees_info))
        api_wallet_page.send(address, amount, max, with_fees, fees_info)
    }

    function sendCoin() {
        api_wallet_page.broadcast(send_result.withdraw_answer.tx_hex, false, send_result.withdraw_answer.max, input_amount.field.text)
    }

    function isSpecialToken() {
        return General.isTokenType(current_ticker_infos.type)
    }

    function isERC20() {
        return current_ticker_infos.type === "ERC-20"
    }

    function hasErc20CaseIssue(addr) {
        if(!isERC20()) return false
        if(addr.length <= 2) return false

        addr = addr.substring(2) // Remove 0x
        return addr === addr.toLowerCase() || addr === addr.toUpperCase()
    }

    function reset(close = false) {
        send_result = default_send_result

        input_address.field.text = ""
        input_amount.field.text = ""
        input_custom_fees.field.text = ""
        input_custom_fees_gas.field.text = ""
        input_custom_fees_gas_price.field.text = ""
        custom_fees_switch.checked = false
        input_max_amount.checked = false

        if(close) root.close()
        root.currentIndex = 0
    }

    function feeIsHigherThanAmount() {
        if(!custom_fees_switch.checked) return false
        if(input_max_amount.checked) return false

        const amt = parseFloat(input_amount.field.text)
        const fee_amt = parseFloat(input_custom_fees.field.text)

        return amt < fee_amt
    }

    function hasFunds() {
        if(input_max_amount.checked) return true

        if(!General.hasEnoughFunds(true, api_wallet_page.ticker, "", "", input_amount.field.text))
            return false

        if(custom_fees_switch.checked) {
            if(isSpecialToken()) {
                const gas_limit = parseFloat(input_custom_fees_gas.field.text)
                const gas_price = parseFloat(input_custom_fees_gas_price.field.text)

                const unit = current_ticker_infos.type === "ERC-20" ? 1000000000 : 100000000
                const fee_parent_token = (gas_limit * gas_price)/unit

                const parent_ticker = current_ticker_infos.type === "ERC-20" ? "ETH" : "QTUM"
                if(api_wallet_page.ticker === parent_ticker) {
                    const amount = parseFloat(input_amount.field.text)
                    const total_needed = amount + fee_parent_token
                    if(!General.hasEnoughFunds(true, parent_ticker, "", "", total_needed.toString()))
                        return false
                }
                else {
                    if(!General.hasEnoughFunds(true, parent_ticker, "", "", fee_parent_token.toString()))
                        return false
                }
            }
            else {
                if(feeIsHigherThanAmount()) return false

                if(!General.hasEnoughFunds(true, api_wallet_page.ticker, "", "", input_custom_fees.field.text))
                    return false
            }
        }

        return true
    }

    function feesAreFilled() {
        return  (!custom_fees_switch.checked || (
                       (!isSpecialToken() && input_custom_fees.field.acceptableInput) ||
                       (isSpecialToken() && input_custom_fees_gas.field.acceptableInput && input_custom_fees_gas_price.field.acceptableInput &&
                                       parseFloat(input_custom_fees_gas.field.text) > 0 && parseFloat(input_custom_fees_gas_price.field.text) > 0)
                     )
                 )
    }

    function fieldAreFilled() {
        return input_address.field.text != "" &&
             (input_max_amount.checked || (input_amount.field.text != "" && input_amount.field.acceptableInput && parseFloat(input_amount.field.text) > 0)) &&
             input_address.field.acceptableInput &&
             feesAreFilled()
    }

    function setMax() {
        input_amount.field.text = current_ticker_infos.balance
    }

    // Inside modal
    // width: stack_layout.children[root.currentIndex].width + horizontalPadding * 2
    width: 650

    // Prepare Page
    ModalContent {
        Layout.fillWidth: true

        title: API.get().settings_pg.empty_string + (qsTr("Prepare to Send"))

        // Send address
        RowLayout {
            spacing: Style.buttonSpacing

            AddressFieldWithTitle {
                id: input_address
                Layout.alignment: Qt.AlignLeft
                title: API.get().settings_pg.empty_string + (qsTr("Recipient's address"))
                field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter address of the recipient"))
                field.enabled: !root.is_send_busy
            }

            DefaultButton {
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                text: API.get().settings_pg.empty_string + (qsTr("Address Book"))
                onClicked: {
                    openAddressBook()
                    root.close()
                }
                enabled: !root.is_send_busy
            }
        }

        // ERC-20 Lowercase issue
        RowLayout {
            Layout.fillWidth: true
            visible: isERC20() && input_address.field.text != "" && hasErc20CaseIssue(input_address.field.text)
            DefaultText {
                Layout.alignment: Qt.AlignLeft
                color: Style.colorRed
                text_value: API.get().settings_pg.empty_string + (qsTr("The address has to be mixed case."))
            }

            DefaultButton {
                Layout.alignment: Qt.AlignRight
                text: API.get().settings_pg.empty_string + (qsTr("Fix"))
                onClicked: input_address.field.text = API.get().to_eth_checksum_qt(input_address.field.text.toLowerCase())
                enabled: !root.is_send_busy
            }
        }

        RowLayout {
            spacing: Style.buttonSpacing

            // Amount input
            AmountField {
                id: input_amount

                field.visible: !input_max_amount.checked
                title: API.get().settings_pg.empty_string + (qsTr("Amount to send"))
                field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the amount to send"))
                field.enabled: !root.is_send_busy
            }

            Switch {
                id: input_max_amount
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                text: API.get().settings_pg.empty_string + (qsTr("MAX"))
                onCheckedChanged: input_amount.field.text = ""
                enabled: !root.is_send_busy
            }
        }

        // Custom fees switch
        Switch {
            id: custom_fees_switch
            text: API.get().settings_pg.empty_string + (qsTr("Enable Custom Fees"))
            onCheckedChanged: input_custom_fees.field.text = ""
            enabled: !root.is_send_busy
        }

        // Custom Fees section
        ColumnLayout {
            visible: custom_fees_switch.checked

            DefaultText {
                font.pixelSize: Style.textSize
                color: Style.colorRed
                text_value: API.get().settings_pg.empty_string + (qsTr("Only use custom fees if you know what you are doing!"))
            }

            // Normal coins, Custom fees input
            AmountField {
                visible: !isSpecialToken()

                id: input_custom_fees
                title: API.get().settings_pg.empty_string + (qsTr("Custom Fee") + " [" + api_wallet_page.ticker + "]")
                field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the custom fee"))
                field.enabled: !root.is_send_busy
            }

            // Token coins
            ColumnLayout {
                visible: isSpecialToken()

                // Gas input
                AmountIntField {
                    id: input_custom_fees_gas
                    title: API.get().settings_pg.empty_string + (qsTr("Gas Limit") + " [" + General.tokenUnitName(current_ticker_infos.type) + "]")
                    field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the gas limit"))
                    field.enabled: !root.is_send_busy
                }

                // Gas price input
                AmountIntField {
                    id: input_custom_fees_gas_price
                    title: API.get().settings_pg.empty_string + (qsTr("Gas Price") + " [" + General.tokenUnitName(current_ticker_infos.type) + "]")
                    field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the gas price"))
                    field.enabled: !root.is_send_busy
                }
            }
        }


        // Fee is higher than amount error
        DefaultText {
            id: fee_error
            wrapMode: Text.Wrap
            visible: feeIsHigherThanAmount()

            color: Style.colorRed

            text_value: API.get().settings_pg.empty_string + (qsTr("Custom Fee can't be higher than the amount"))
        }

        // Not enough funds error
        DefaultText {
            wrapMode: Text.Wrap
            visible: !fee_error.visible && fieldAreFilled() && !hasFunds()

            color: Style.colorRed

            text_value: API.get().settings_pg.empty_string + (qsTr("Not enough funds.") + "\n" + qsTr("You have %1", "AMT TICKER").arg(General.formatCrypto("", API.get().get_balance(api_wallet_page.ticker), api_wallet_page.ticker)))
        }

        DefaultBusyIndicator {
            visible: root.is_send_busy
        }

        // Buttons
        footer: [
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Close"))
                Layout.fillWidth: true
                onClicked: root.close()
            },

            PrimaryButton {
                text: API.get().settings_pg.empty_string + (qsTr("Prepare"))
                Layout.fillWidth: true

                enabled: fieldAreFilled() && hasFunds() && !hasErc20CaseIssue(input_address.field.text) && !root.is_send_busy

                onClicked: prepareSendCoin(input_address.field.text, input_amount.field.text, custom_fees_switch.checked, input_custom_fees.field.text,
                                           isSpecialToken(), input_custom_fees_gas.field.text, input_custom_fees_gas_price.field.text)
            }
        ]
    }

    // Send Page
    ModalContent {
        title: API.get().settings_pg.empty_string + (qsTr("Send"))

        // Address
        TextWithTitle {
            title: API.get().settings_pg.empty_string + (qsTr("Recipient's address"))
            text: API.get().settings_pg.empty_string + (input_address.field.text)
        }

        // Amount
        TextWithTitle {
            title: API.get().settings_pg.empty_string + (qsTr("Amount"))
            text: API.get().settings_pg.empty_string + (General.formatCrypto("", input_amount.field.text, api_wallet_page.ticker))
        }

        // Fees
        TextWithTitle {
            title: API.get().settings_pg.empty_string + (qsTr("Fees"))
            text: API.get().settings_pg.empty_string + (General.formatCrypto("", send_result.withdraw_answer.fee_details.amount, current_ticker_infos.fee_ticker))
        }

        // Date
        TextWithTitle {
            title: API.get().settings_pg.empty_string + (qsTr("Date"))
            text: API.get().settings_pg.empty_string + (send_result.withdraw_answer.date)
        }

        DefaultBusyIndicator {
            visible: root.is_broadcast_busy
        }

        // Buttons
        footer: [
            DefaultButton {
                text: API.get().settings_pg.empty_string + (qsTr("Back"))
                Layout.fillWidth: true
                onClicked: root.currentIndex = 0
                enabled: !root.is_broadcast_busy
            },

            PrimaryButton {
                text: API.get().settings_pg.empty_string + (qsTr("Send"))
                Layout.fillWidth: true
                onClicked: sendCoin()
                enabled: !root.is_broadcast_busy
            }
        ]
    }

    // Result Page
    SendResult {
        result: ({
            balance_change: send_result.withdraw_answer.my_balance_change,
            fees: send_result.withdraw_answer.fee_details.amount,
            date: send_result.withdraw_answer.date
        })
        address: input_address.field.text
        tx_hash: broadcast_result
        custom_amount: input_amount.field.text

        function onClose() { reset(true) }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
