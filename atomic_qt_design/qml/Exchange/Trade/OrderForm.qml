import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import "../../Components"
import "../../Constants"

FloatingBackground {
    id: root

    property alias field: input_volume.field
    property bool my_side: false
    property bool enabled: true
    property alias column_layout: form_layout

    property bool recursive_update: false

    function update(new_ticker) {
        updateTickerList(new_ticker)
    }

    function inCurrentPage() {
        return exchange_trade.inCurrentPage()
    }

    property var ticker_list: ([])

    function updateTickerList(new_ticker) {
        recursive_update = new_ticker !== undefined

        ticker_list = my_side ? General.getTickersAndBalances(getFilteredCoins()) : General.getTickers(getFilteredCoins())
        update_timer.running = true
    }

    Timer {
        id: update_timer
        running: inCurrentPage()
        repeat: true
        interval: 1000
        onTriggered: {
            if(inCurrentPage()) updateTickerList()
        }
    }


    function setAnyTicker() {
        setTicker(getAnyAvailableCoin())
    }

    function fillIfEmpty() {
        if(getTicker() === '') setAnyTicker()
    }

    function canShowFees() {
        return my_side && valid_trade_info && !General.isZero(getVolume()) 
    }

    function getVolume() {
        return input_volume.field.text === '' ? '0' :  input_volume.field.text
    }

    function getFilteredCoins() {
        return getCoins(my_side)
    }

    function getAnyAvailableCoin(filter_ticker) {
        let coins = getFilteredCoins()
        if(filter_ticker !== undefined || filter_ticker !== '')
            coins = coins.filter(c => c.ticker !== filter_ticker)
        return coins.length > 0 ? coins[0].ticker : ''
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
        if(valid) valid = API.get().do_i_have_enough_funds(getTicker(), input_volume.field.text)
        if(valid && hasEthFees()) valid = hasEnoughEthForFees()

        return valid
    }

    function getTicker() {
        if(combo.currentIndex === -1) return ''
        const coins = getFilteredCoins()

        const coin = coins[combo.currentIndex]

        // If invalid index
        if(coin === undefined) {
            // If there are other coins, select first
            if(coins.length > 0) {
                combo.currentIndex = 0
                return coins[combo.currentIndex].ticker
            }
            // If there isn't any, reset index
            else {
                combo.currentIndex = -1
                return ''
            }
        }

        return coin.ticker
    }

    function setTicker(ticker) {
        combo.currentIndex = getFilteredCoins().map(c => c.ticker).indexOf(ticker)

        // If it doesn't exist, pick an existing one
        if(combo.currentIndex === -1) setAnyTicker()
    }

    function getMaxVolume() {
        return API.get().get_balance(getTicker())
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

    function shouldBlockInput() {
        return my_side && notEnoughBalanceForFees()
    }

    function onBaseChanged() {
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
                Layout.topMargin: parent.spacing
                Layout.leftMargin: parent.spacing*2
                Layout.rightMargin: Layout.leftMargin

                // Title
                DefaultText {
                    font.pixelSize: Style.textSizeMid2
                    text_value: API.get().empty_string + (my_side ? qsTr("Sell") : qsTr("Receive"))
                    color: my_side ? Style.colorRed : Style.colorGreen
                    font.weight: Font.Bold
                }

                Arrow {
                    up: my_side
                    color: my_side ? Style.colorRed : Style.colorGreen
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                }

                Image {
                    Layout.leftMargin: combo.Layout.rightMargin * 3
                    source: General.coinIcon(getTicker())
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: Layout.preferredWidth
                }

                DefaultComboBox {
                    id: combo

                    enabled: root.enabled

                    Layout.fillWidth: true

                    model: ticker_list
                    onCurrentTextChanged: {
                        if(!recursive_update) {
                            resetTradeInfo()

                            setPair(my_side)
                            if(my_side) prev_base = getTicker()
                            else prev_rel = getTicker()
                            updateForms(my_side, combo.currentText)
                        }
                    }

                    MouseArea {
                        visible: !my_side
                        anchors.fill: parent
                        onClicked: {
                            order_receive_modal.open()
                        }
                    }

                    OrderReceiveModal {
                        id: order_receive_modal
                    }

                    OrderbookModal {
                        id: orderbook_modal
                    }
                }
            }


            HorizontalLine {
                Layout.fillWidth: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: top_line.Layout.leftMargin
                Layout.rightMargin: top_line.Layout.rightMargin

                DefaultText {
                    text_value: API.get().empty_string + (qsTr("Amount") + ':')
                    font.pixelSize: Style.textSizeSmall1
                }

                Item {
                    Layout.fillWidth: true
                    height: input_volume.height

                    AmountField {
                        id: input_volume
                        width: parent.width
                        field.enabled: root.enabled && !shouldBlockInput()
                        field.placeholderText: API.get().empty_string + (my_side ? qsTr("Amount to sell") :
                                                         field.enabled ? qsTr("Amount to receive") : qsTr("Please fill the send amount"))
                        field.onTextChanged: {
                            const before_checks = field.text
                            onBaseChanged()
                            const after_checks = field.text

                            // Update slider only if the value is not from slider, or value got corrected here
                            if(before_checks !== after_checks || !input_volume_slider.updating_text_field) {
                                input_volume_slider.updating_from_text_field = true
                                input_volume_slider.value = parseFloat(field.text)
                                input_volume_slider.updating_from_text_field = false
                            }
                        }

                        field.font.pixelSize: Style.textSizeSmall1
                        field.font.weight: Font.Bold
                    }

                    DefaultText {
                        anchors.right: input_volume.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: input_volume.verticalCenter

                        text_value: getTicker()
                        font.pixelSize: input_volume.field.font.pixelSize
                    }
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
                readonly property int precision: Math.max(0, Math.min(General.amountPrecision, General.sliderDigitLimit - to.toString().split(".")[0].length))
                visible: my_side
                Layout.fillWidth: true
                Layout.leftMargin: top_line.Layout.leftMargin
                Layout.rightMargin: top_line.Layout.rightMargin
                Layout.bottomMargin: top_line.Layout.rightMargin
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
                Layout.bottomMargin: top_line.Layout.rightMargin

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
                                                                    (hasEthFees() ? " + " + General.formatCrypto("", curr_trade_info.erc_fees, 'ETH') : ''))
                            font.pixelSize: Style.textSizeSmall1
                        }

                        DefaultText {
                            text_value: API.get().empty_string + (qsTr('Trading Fee') + ': ' + General.formatCrypto("", curr_trade_info.trade_fee, getTicker(true)))
                            font.pixelSize: tx_fee_text.font.pixelSize
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


        // Trade button
        DefaultButton {
            visible: !my_side

            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            Layout.rightMargin: top_line.Layout.rightMargin
            Layout.bottomMargin: top_line.Layout.rightMargin
            width: 170

            text: API.get().empty_string + (qsTr("Trade"))
            enabled: valid_trade_info && form_base.isValid() && form_rel.isValid()
            onClicked: confirm_trade_modal.open()
        }
    }


    opacity_mask_enabled: true
    mask: OpacityMask {
        source: rect
        invert: true
        maskSource: Item {
            width: rect.width;
            height: rect.height;
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: my_side ? parent.right : undefined
                anchors.leftMargin: my_side ? -17.5 : 0
                anchors.right: my_side ? undefined : parent.left
                anchors.rightMargin: my_side ? 0 : -17.5
                width: 110; height: width; radius: Infinity
            }
        }
    }
}
