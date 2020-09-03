import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../Components"
import "../Constants"

DefaultModal {
    id: root

    property alias address_field: input_address.field


    onClosed: if(stack_layout.currentIndex === 2) reset(true)

    // Local
    readonly property var default_send_result: ({ has_error: false, error_message: "", tx_hex: "", date: "", fees: "", explorer_url: "", max: false })
    property var send_result: default_send_result


    readonly property bool is_send_busy: API.get().wallet_pg.is_send_busy
    readonly property var send_rpc_result: API.get().wallet_pg.send_rpc_data

    readonly property bool is_broadcast_busy: API.get().wallet_pg.is_broadcast_busy
    readonly property string broadcast_result: API.get().wallet_pg.broadcast_rpc_data
    property bool async_param_max: false

    onSend_rpc_resultChanged: {
        send_result = General.clone(send_rpc_result)
        const max = async_param_max
        send_result.max = max

        // Local var, faster
        const result = send_result

        if(result.error_code) {
            text_error.text = result.error_message
        }
        else {
            if(!result.withdraw_answer) {
                reset()
                return
            }

            text_error.text = ""

            if(max) input_amount.field.text = API.get().is_pin_cfg_enabled() ? General.absString(result.balance_change) : result.total_amount

            // Change page
            stack_layout.currentIndex = 1
        }
    }

    function prepareSendCoin(address, amount, with_fees, fee_amount, is_erc_20, gas_limit, gas_price) {
        let max = input_max_amount.checked || parseFloat(current_ticker_infos.balance) === parseFloat(amount)

        // Save for later check
        async_param_max = max

        if(with_fees && max === false && !is_erc_20)
            max = parseFloat(amount) + parseFloat(fee_amount) >= parseFloat(current_ticker_infos.balance)

        API.get().wallet_pg.send(address, amount, max, with_fees, { fee_amount, gas_price, gas_limit })
    }

    function sendCoin() {
        API.get().send(send_result.tx_hex, send_result.max, input_amount.field.text)
        stack_layout.currentIndex = 2
    }

    function isERC20() {
        return current_ticker_infos.type === "ERC-20"
    }

    function ercToMixedCase(addr) {
        return API.get().to_eth_checksum_qt(addr.toLowerCase())
    }

    function hasErc20CaseIssue(is_erc_20, addr) {
        if(!is_erc_20) return false
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
        text_error.text = ""

        if(close) root.close()
        stack_layout.currentIndex = 0
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

        if(!General.hasEnoughFunds(true, API.get().wallet_pg.ticker, "", "", input_amount.field.text))
            return false

        if(custom_fees_switch.checked) {
            if(isERC20()) {
                const ether = 1000000000
                const gas_limit = parseFloat(input_custom_fees_gas.field.text)
                const gas_price = parseFloat(input_custom_fees_gas_price.field.text)
                const fee_eth = (gas_limit * gas_price)/ether

                if(API.get().wallet_pg.ticker === "ETH") {
                    const amount = parseFloat(input_amount.field.text)
                    const total_needed_eth = amount + fee_eth
                    if(!General.hasEnoughFunds(true, "ETH", "", "", total_needed_eth.toString()))
                        return false
                }
                else {
                    if(!General.hasEnoughFunds(true, "ETH", "", "", fee_eth.toString()))
                        return false
                }
            }
            else {
                if(feeIsHigherThanAmount()) return false

                if(!General.hasEnoughFunds(true, API.get().wallet_pg.ticker, "", "", input_custom_fees.field.text))
                    return false
            }
        }

        return true
    }

    function feesAreFilled() {
        return  (!custom_fees_switch.checked || (
                       (!isERC20() && input_custom_fees.field.acceptableInput) ||
                       (isERC20() && input_custom_fees_gas.field.acceptableInput && input_custom_fees_gas_price.field.acceptableInput &&
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
    // width: stack_layout.children[stack_layout.currentIndex].width + horizontalPadding * 2
    width: 650
    height: stack_layout.children[stack_layout.currentIndex].height + verticalPadding * 2
    StackLayout {
        width: parent.width
        id: stack_layout

        // Prepare Page
        ColumnLayout {
            Layout.fillWidth: true

            ModalHeader {
                title: API.get().settings_pg.empty_string + (qsTr("Prepare to Send"))
            }

            // Send address
            RowLayout {
                spacing: Style.buttonSpacing

                AddressFieldWithTitle {
                    id: input_address
                    Layout.alignment: Qt.AlignLeft
                    title: API.get().settings_pg.empty_string + (qsTr("Recipient's address"))
                    field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter address of the recipient"))
                }

                DefaultButton {
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                    text: API.get().settings_pg.empty_string + (qsTr("Address Book"))
                    onClicked: {
                        openAddressBook()
                        root.close()
                    }
                }
            }

            // ERC-20 Lowercase issue
            RowLayout {
                Layout.fillWidth: true
                visible: isERC20() && input_address.field.text != "" && hasErc20CaseIssue(isERC20(), input_address.field.text)
                DefaultText {
                    Layout.alignment: Qt.AlignLeft
                    color: Style.colorRed
                    text_value: API.get().settings_pg.empty_string + (qsTr("The address has to be mixed case."))
                }

                DefaultButton {
                    Layout.alignment: Qt.AlignRight
                    text: API.get().settings_pg.empty_string + (qsTr("Fix"))
                    onClicked: input_address.field.text = ercToMixedCase(input_address.field.text)
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
                }

                Switch {
                    id: input_max_amount
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                    text: API.get().settings_pg.empty_string + (qsTr("MAX"))
                    onCheckedChanged: input_amount.field.text = ""
                }
            }

            // Custom fees switch
            Switch {
                id: custom_fees_switch
                text: API.get().settings_pg.empty_string + (qsTr("Enable Custom Fees"))
                onCheckedChanged: input_custom_fees.field.text = ""
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
                    visible: !isERC20()

                    id: input_custom_fees
                    title: API.get().settings_pg.empty_string + (qsTr("Custom Fee") + " [" + API.get().wallet_pg.ticker + "]")
                    field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the custom fee"))
                }

                // ERC-20 coins
                ColumnLayout {
                    visible: isERC20()

                    // Gas input
                    AmountIntField {
                        id: input_custom_fees_gas
                        title: API.get().settings_pg.empty_string + (qsTr("Gas Limit") + " [Gwei]")
                        field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the gas limit"))
                    }

                    // Gas price input
                    AmountIntField {
                        id: input_custom_fees_gas_price
                        title: API.get().settings_pg.empty_string + (qsTr("Gas Price") + " [Gwei]")
                        field.placeholderText: API.get().settings_pg.empty_string + (qsTr("Enter the gas price"))
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

                text_value: API.get().settings_pg.empty_string + (qsTr("Not enough funds.") + "\n" + qsTr("You have %1", "AMT TICKER").arg(General.formatCrypto("", API.get().get_balance(API.get().wallet_pg.ticker), API.get().wallet_pg.ticker)))
            }

            DefaultText {
                id: text_error
                color: Style.colorRed
                visible: text !== ''
            }

            // Buttons
            RowLayout {
                DefaultButton {
                    text: API.get().settings_pg.empty_string + (qsTr("Close"))
                    Layout.fillWidth: true
                    onClicked: root.close()
                }
                PrimaryButton {
                    text: API.get().settings_pg.empty_string + (qsTr("Prepare"))
                    Layout.fillWidth: true

                    enabled: fieldAreFilled() && hasFunds() && !hasErc20CaseIssue(isERC20(), input_address.field.text)

                    onClicked: prepareSendCoin(input_address.field.text, input_amount.field.text, custom_fees_switch.checked, input_custom_fees.field.text,
                                               isERC20(), input_custom_fees_gas.field.text, input_custom_fees_gas_price.field.text)
                }
            }
        }

        // Send Page
        ColumnLayout {
            ModalHeader {
                title: API.get().settings_pg.empty_string + (qsTr("Send"))
            }

            // Address
            TextWithTitle {
                title: API.get().settings_pg.empty_string + (qsTr("Recipient's address"))
                text: API.get().settings_pg.empty_string + (input_address.field.text)
            }

            // Amount
            TextWithTitle {
                title: API.get().settings_pg.empty_string + (qsTr("Amount"))
                text: API.get().settings_pg.empty_string + (General.formatCrypto("", input_amount.field.text, API.get().wallet_pg.ticker))
            }

            // Fees
            TextWithTitle {
                title: API.get().settings_pg.empty_string + (qsTr("Fees"))
                text: API.get().settings_pg.empty_string + (General.formatCrypto("", send_result.fees, General.txFeeTicker(API.get().wallet_pg)))
            }

            // Date
            TextWithTitle {
                title: API.get().settings_pg.empty_string + (qsTr("Date"))
                text: API.get().settings_pg.empty_string + (send_result.date)
            }

            // Buttons
            RowLayout {
                DefaultButton {
                    text: API.get().settings_pg.empty_string + (qsTr("Back"))
                    Layout.fillWidth: true
                    onClicked: stack_layout.currentIndex = 0
                }
                PrimaryButton {
                    text: API.get().settings_pg.empty_string + (qsTr("Send"))
                    Layout.fillWidth: true
                    onClicked: sendCoin()
                }
            }
        }

        // Result Page
        SendResult {
            result: send_result
            address: input_address.field.text
            tx_hash: broadcast_result
            custom_amount: input_amount.field.text

            function onClose() { reset(true) }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
