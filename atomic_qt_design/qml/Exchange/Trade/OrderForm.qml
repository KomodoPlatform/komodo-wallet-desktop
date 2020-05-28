import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

// Right side
Rectangle {
    id: root

    property alias field: input_volume.field
    property bool my_side: false
    property bool enabled: true

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
        return my_side && !General.isZero(getVolume())
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
        return input_volume.field.text !== '' && parseFloat(input_volume.field.text) > 0
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
        if(!my_side) return fieldsAreFilled()

        const ticker = getTicker()

        let valid = true

        if(valid) valid = fieldsAreFilled()
        if(valid) valid = higherThanMinTradeAmount()
        if(valid) valid = API.get().do_i_have_enough_funds(ticker, input_volume.field.text)
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

    function onBaseChanged() {
        if(capVolume()) updateTradeInfo()

        if(my_side) {
            // Rel is dependant on Base if price is set so update that
            updateRelAmount()

            // Update the new fees, input_volume might be changed
            updateTradeInfo()
        }
    }

    color: Style.colorTheme7
    radius: Style.rectangleCornerRadius

    implicitWidth: form_layout.width
    implicitHeight: form_layout.height

    DefaultText {
        font.pixelSize: Style.textSize2
        text: API.get().empty_string + (my_side ? qsTr("Sell") : qsTr("Receive"))
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: form_layout.top
        anchors.bottomMargin: combo.Layout.rightMargin * 0.5
    }

    ColumnLayout {
        id: form_layout
        width: 300
        RowLayout {
            Image {
                Layout.leftMargin: combo.Layout.rightMargin
                source: General.coinIcon(getTicker())
                Layout.preferredWidth: 32
                Layout.preferredHeight: Layout.preferredWidth
            }

            DefaultComboBox {
                id: combo

                enabled: root.enabled

                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.rightMargin: 15

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

        RowLayout {
            DefaultButton {
                Layout.leftMargin: combo.Layout.rightMargin
                Layout.topMargin: Layout.rightMargin
                Layout.bottomMargin: Layout.rightMargin
                visible: my_side
                text: API.get().empty_string + (qsTr("MAX"))
                onClicked: setMax()
            }

            AmountField {
                id: input_volume
                field.enabled: root.enabled

                Layout.fillWidth: true
                Layout.rightMargin: combo.Layout.rightMargin
                Layout.leftMargin: Layout.rightMargin
                Layout.topMargin: Layout.rightMargin
                Layout.bottomMargin: Layout.rightMargin
                field.placeholderText: API.get().empty_string + (my_side ? qsTr("Amount to sell") :
                                                 field.enabled ? qsTr("Amount to receive") : qsTr("Please fill the send amount"))
                field.onTextChanged: onBaseChanged()
            }
        }

        RowLayout {
            Layout.leftMargin: combo.Layout.rightMargin
            Layout.bottomMargin: Layout.leftMargin

            ColumnLayout {
                Layout.alignment: Qt.AlignLeft

                DefaultText {
                    id: tx_fee_text
                    text: API.get().empty_string + (canShowFees() ? qsTr('Transaction Fee') + ':' : '')
                    font.pixelSize: Style.textSizeSmall
                }

                DefaultText {
                    text: API.get().empty_string + (canShowFees() ? qsTr('Trading Fee') + ':' : '')
                    font.pixelSize: tx_fee_text.font.pixelSize
                }
            }

            ColumnLayout {
                visible: canShowFees()
                Layout.alignment: Qt.AlignRight

                DefaultText {
                    text: API.get().empty_string + (canShowFees() && valid_trade_info ? (General.formatCrypto("", curr_trade_info.tx_fee, curr_trade_info.is_ticker_of_fees_eth ? "ETH" : getTicker(true))) +
                                                                    // ETH Fees
                                                                    (hasEthFees() ? " + " + General.formatCrypto("", curr_trade_info.erc_fees, 'ETH') : '') : qsTr("Calculating..."))
                    font.pixelSize: tx_fee_text.font.pixelSize
                }

                DefaultText {
                    text: API.get().empty_string + (canShowFees() && valid_trade_info ? General.formatCrypto("", curr_trade_info.trade_fee, getTicker(true)) : qsTr("Calculating..."))
                    font.pixelSize: tx_fee_text.font.pixelSize
                }
            }
        }
    }
}
