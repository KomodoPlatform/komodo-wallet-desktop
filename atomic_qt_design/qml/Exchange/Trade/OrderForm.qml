import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import "../../Components"
import "../../Constants"

FloatingBackground {
    id: root

    property alias field: input_volume.field
    property alias price_field: input_price.field
    property bool my_side: false
    property bool enabled: true
    property alias column_layout: form_layout
    property string receive_amount: "0"

    function updateRelAmount(set_order_volume) {
        const price = parseFloat(getCurrentPrice())
        const base_volume = parseFloat(getVolume())
        let new_receive = base_volume * price

        // If an order is selected
        if(orderIsSelected()) {
            const selected_order = preffered_order
            // If it's a bid order, This is the sell side,
            // Cap the volume with the order volume
            if(!selected_order.is_asks) {
                const order_buy_volume = parseFloat(selected_order.volume)
                if(set_order_volume || parseFloat(getVolume()) > order_buy_volume) {
                    const new_sell_volume = General.formatDouble(order_buy_volume)
                    input_volume.field.text = new_sell_volume

                    // Calculate new receive amount
                    new_receive = order_buy_volume * price
                }

//                // If new rel volume is higher than the order max volume
//                const max_rel_volume = parseFloat(selected_order.volume)
//                if(new_receive > max_rel_volume) {
//                    new_receive = max_rel_volume

//                    // Set base depending on the capped rel
//                    const max_base_volume = max_rel_volume / price
//                    if(base_volume !== max_base_volume) {
//                        const new_base_text = General.formatDouble(max_base_volume)
//                        if(input_volume.field.text !== new_base_text)
//                            input_volume.field.text = new_base_text
//                    }
//                }
            }
        }

        // Set rel
        const new_receive_text = General.formatDouble(new_receive)
        if(receive_amount !== new_receive_text)
            receive_amount = new_receive_text
    }

    function getFiatText(v, ticker) {
        return General.formatFiat('', v === '' ? 0 : API.get().get_fiat_from_amount(ticker, v), API.get().current_fiat) + " " +  General.cex_icon
    }

    function canShowFees() {
        return my_side && valid_trade_info && !General.isZero(getVolume())
    }

    function getVolume() {
        return input_volume.field.text === '' ? '0' :  input_volume.field.text
    }

    function fieldsAreFilled() {
        return input_volume.field.text !== ''
    }

    function hasEthFees() {
        return General.fieldExists(curr_trade_info.erc_fees) && parseFloat(curr_trade_info.erc_fees) > 0
    }

    function hasEnoughEthForFees() {
        return General.isEthEnabled() && API.get().do_i_have_enough_funds("ETH", curr_trade_info.erc_fees)
    }

    function higherThanMinTradeAmount() {
        return input_volume.field.text !== '' && parseFloat(input_volume.field.text) >= General.getMinTradeAmount()
    }

    function isValid() {
        let valid = true

        // Both sides
        if(valid) valid = fieldsAreFilled()
        if(valid) valid = higherThanMinTradeAmount()

        if(!my_side) return valid

        // Sell side
        if(valid) valid = !notEnoughBalance()
        if(valid) valid = API.get().do_i_have_enough_funds(getTicker(my_side), input_volume.field.text)
        if(valid && hasEthFees()) valid = hasEnoughEthForFees()

        return valid
    }

    function getMaxVolume() {
        return API.get().get_balance(getTicker(my_side))
    }

    function getMaxTradableVolume(set_as_current) {
        // set_as_current should be true if input_volume is updated
        // if it's called for cap check, it should be false because that's not the current input_volume
        return getSendAmountAfterFees(getMaxVolume(), set_as_current)
    }

    function setMax() {
        input_volume.field.text = getMaxTradableVolume(true)
    }

    function reset(is_base) {
        input_price.field.text = ''

        if(my_side) {
            // is_base info comes from the ComboBox ticker change in OrderForm.
            // At other places it's not given.
            // We don't want to reset base balance at rel ticker change
            // Therefore it will reset only if this info is set from ComboBox -> setPair
            // Or if it's from somewhere else like page change, in that case is_base is undefined
            if(is_base === undefined || is_base) setMax()
        }
        else {
            input_volume.field.text = ''
        }
    }

    function capVolume() {
        if(inCurrentPage() && my_side && input_volume.field.acceptableInput) {
            const amt = parseFloat(input_volume.field.text)
            const cap_with_fees = getMaxTradableVolume(false)
            if(amt > cap_with_fees) {
                input_volume.field.text = cap_with_fees.toString()
                return true
            }
        }

        return false
    }

    function notEnoughBalance() {
        return my_side && parseFloat(getMaxVolume()) < General.getMinTradeAmount()
    }

    function shouldBlockInput() {
        return my_side && (notEnoughBalance() || notEnoughBalanceForFees())
    }

    function onInputChanged() {
        if(capVolume()) updateTradeInfo()

        if(my_side) {
            // Rel is dependant on Base if price is set so update that
            updateRelAmount()

            // Update the new fees, input_volume might be changed
            updateTradeInfo()
        }
    }

    implicitHeight: form_layout.height

    ColumnLayout {
        id: form_layout
        width: parent.width

        ColumnLayout {
            Layout.alignment: Qt.AlignTop

            Layout.fillWidth: true
            spacing: 15

            // Top Line
            RowLayout {
                id: top_line
                spacing: 20
                Layout.topMargin: parent.spacing
                Layout.leftMargin: parent.spacing
                Layout.rightMargin: Layout.leftMargin
                Layout.alignment: Qt.AlignHCenter

                DefaultButton {
                    font.pixelSize: Style.textSize
                    text: API.get().empty_string + (qsTr("Sell"))
                    color: sell_mode ? Style.colorRed : Style.colorRed3
                    colorTextEnabled: sell_mode ? Style.colorWhite1 : Style.colorWhite6
                    font.weight: Font.Bold
                    onClicked: sell_mode = true
                }
                DefaultButton {
                    font.pixelSize: Style.textSize
                    text: API.get().empty_string + (qsTr("Buy"))
                    color: sell_mode ? Style.colorGreen3 : Style.colorGreen
                    colorTextEnabled: sell_mode ? Style.colorWhite8 : Style.colorWhite1
                    font.weight: Font.Bold
                    onClicked: sell_mode = false
                }
            }


            HorizontalLine {
                Layout.fillWidth: true
            }

            AmountFieldWithInfo {
                id: input_price
                Layout.leftMargin: top_line.Layout.leftMargin
                Layout.rightMargin: top_line.Layout.rightMargin
                Layout.bottomMargin: -6
                Layout.fillWidth: true
                field.enabled: root.enabled && !shouldBlockInput()

                field.left_text: API.get().empty_string + (qsTr("Price"))
                field.right_text: getTicker(false)

                field.onTextChanged: {
                    onInputChanged()
                }

                function resetPrice() {
                    if(orderIsSelected()) resetPreferredPrice()
                }

                field.onPressed: resetPrice()
                field.onFocusChanged: {
                    if(field.activeFocus) resetPrice()
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.leftMargin: top_line.Layout.leftMargin
                Layout.rightMargin: top_line.Layout.rightMargin
                height: input_volume.height

                AmountFieldWithInfo {
                    id: input_volume
                    width: parent.width
                    field.enabled: root.enabled && !shouldBlockInput()

                    field.left_text: API.get().empty_string + (qsTr("Volume"))
                    field.right_text: getTicker(true)
                    field.placeholderText: API.get().empty_string + (my_side ? qsTr("Amount to sell") : qsTr("Amount to receive"))
                    field.onTextChanged: {
                        const before_checks = field.text
                        onInputChanged()
                        const after_checks = field.text

                        // Update slider only if the value is not from slider, or value got corrected here
                        if(before_checks !== after_checks || !input_volume_slider.updating_text_field) {
                            input_volume_slider.updating_from_text_field = true
                            input_volume_slider.value = parseFloat(field.text)
                            input_volume_slider.updating_from_text_field = false
                        }
                    }
                }

                DefaultText {
                    anchors.left: input_volume.left
                    anchors.top: input_volume.bottom
                    anchors.topMargin: 5

                    text_value: getFiatText(input_volume.field.text, getTicker(my_side))
                    font.pixelSize: input_volume.field.font.pixelSize

                    CexInfoTrigger {}
                }
            }

            Slider {
                id: input_volume_slider
                function getRealValue() {
                    return input_volume_slider.position * (input_volume_slider.to - input_volume_slider.from)
                }

                enabled: input_volume.field.enabled
                property bool updating_from_text_field: false
                property bool updating_text_field: false
                readonly property int precision: General.getRecommendedPrecision(to)
                visible: my_side
                Layout.fillWidth: true
                Layout.leftMargin: top_line.Layout.leftMargin
                Layout.rightMargin: top_line.Layout.rightMargin
                Layout.bottomMargin: top_line.Layout.rightMargin*0.25
                from: 0
                stepSize: 1/Math.pow(10, precision)
                to: parseFloat(getMaxVolume())
                live: false

                onValueChanged: {
                    if(updating_from_text_field) return

                    if(pressed) {
                        updating_text_field = true
                        input_volume.field.text = General.formatDouble(value)
                        updating_text_field = false
                    }
                }

                DefaultText {
                    visible: parent.pressed
                    anchors.horizontalCenter: parent.handle.horizontalCenter
                    anchors.bottom: parent.handle.top

                    text_value: General.formatDouble(input_volume_slider.getRealValue(), input_volume_slider.precision)
                    font.pixelSize: input_volume.field.font.pixelSize
                }

                DefaultText {
                    anchors.left: parent.left
                    anchors.top: parent.bottom

                    text_value: API.get().empty_string + (qsTr("Min"))
                    font.pixelSize: input_volume.field.font.pixelSize
                }
                DefaultText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.bottom

                    text_value: API.get().empty_string + (qsTr("Half"))
                    font.pixelSize: input_volume.field.font.pixelSize
                }
                DefaultText {
                    anchors.right: parent.right
                    anchors.top: parent.bottom

                    text_value: API.get().empty_string + (qsTr("Max"))
                    font.pixelSize: input_volume.field.font.pixelSize
                }
            }


            // Fees
            InnerBackground {
                visible: my_side

                radius: 100
                id: bg
                Layout.fillWidth: true
                Layout.leftMargin: top_line.Layout.leftMargin
                Layout.rightMargin: top_line.Layout.rightMargin

                content: RowLayout {
                    width: bg.width
                    height: tx_fee_text.font.pixelSize * 4

                    ColumnLayout {
                        id: fees
                        visible: canShowFees()

                        spacing: -2
                        Layout.leftMargin: 10
                        Layout.rightMargin: Layout.leftMargin
                        Layout.alignment: Qt.AlignLeft

                        DefaultText {
                            id: tx_fee_text
                            text_value: API.get().empty_string + ((qsTr('Transaction Fee') + ': ' + General.formatCrypto("", curr_trade_info.tx_fee, curr_trade_info.is_ticker_of_fees_eth ? "ETH" : getTicker(true))) +
                                                                    // ETH Fees
                                                                    (hasEthFees() ? " + " + General.formatCrypto("", curr_trade_info.erc_fees, 'ETH') : '') +

                                                                  // Fiat part
                                                                  (" ("+
                                                                      getFiatText(!hasEthFees() ? curr_trade_info.tx_fee : General.formatDouble((parseFloat(curr_trade_info.tx_fee) + parseFloat(curr_trade_info.erc_fees))),
                                                                                  curr_trade_info.is_ticker_of_fees_eth ? 'ETH' : getTicker(true))
                                                                   +")")


                                                                  )
                            font.pixelSize: Style.textSizeSmall1

                            CexInfoTrigger {}
                        }

                        DefaultText {
                            text_value: API.get().empty_string + (qsTr('Trading Fee') + ': ' + General.formatCrypto("", curr_trade_info.trade_fee, getTicker(true)) +

                                                                  // Fiat part
                                                                  (" ("+
                                                                      getFiatText(curr_trade_info.trade_fee, getTicker(true))
                                                                   +")")
                                                                  )
                            font.pixelSize: tx_fee_text.font.pixelSize

                            CexInfoTrigger {}
                        }
                    }


                    DefaultText {
                        visible: !fees.visible

                        text_value: API.get().empty_string + (qsTr('Fees will be calculated'))
                        Layout.alignment: Qt.AlignCenter
                        font.pixelSize: tx_fee_text.font.pixelSize
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignBottom
            Layout.topMargin: 5
            Layout.fillWidth: true
            Layout.leftMargin: top_line.Layout.rightMargin
            Layout.rightMargin: Layout.leftMargin
            Layout.bottomMargin: layout_margin

            DefaultText {
                Layout.alignment: Qt.AlignLeft
                text_value: API.get().empty_string + (qsTr("Receive") + ": " + General.formatCrypto("", receive_amount, getTicker(!my_side)))
                font.pixelSize: Style.textSizeSmall3
            }

            // Trade button
            DefaultButton {
                Layout.alignment: Qt.AlignRight
                Layout.fillWidth: true
                Layout.leftMargin: 30

                button_type: my_side ? "danger" : "primary"

                width: 170

                text: API.get().empty_string + (my_side ? qsTr("Sell %1", "TICKER").arg(getTicker(true)) : qsTr("Buy %1", "TICKER").arg(getTicker(true)))
                enabled: valid_trade_info && !notEnoughBalanceForFees() && isValid()
                onClicked: confirm_trade_modal.open()
            }
        }
    }
}
