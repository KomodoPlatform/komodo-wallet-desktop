import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"
import "../../Wallet"

Item {
    id: exchange_trade

    property string action_result

    // Override
    property var onOrderSuccess: () => {}

    // Local
    function inCurrentPage() {
        return  exchange.inCurrentPage() &&
                exchange.current_page === General.idx_exchange_trade
    }

    function fullReset() {
        reset(true)
    }

    function reset(reset_result=true, is_base) {
        if(reset_result) action_result = ""
        resetPreferredPrice()
        form_base.reset(is_base)
        form_rel.reset(is_base)
        resetTradeInfo()
    }

    // Price
    property string cex_price
    function updateCexPrice(base, rel) {
        cex_price = API.get().get_cex_rates(base, rel)
    }

    readonly property var empty_order: ({ "is_asks":false,"price":"0","price_denom":"0","price_numer":"0","volume":"0"})
    property var preffered_order: General.clone(empty_order)


    function orderIsSelected() {
        return preffered_order.price !== empty_order.price
    }

    function resetPreferredPrice() {
        preffered_order = General.clone(empty_order)
    }

    function selectOrder(is_asks, price, quantity, price_denom, price_numer) {
        preffered_order.is_asks = is_asks
        preffered_order.price = price
        preffered_order.volume = quantity
        preffered_order.price_denom = price_denom
        preffered_order.price_numer = price_numer
        preffered_order = preffered_order
        updateRelAmount()
        form_base.field.forceActiveFocus()
    }

    function newRelVolume(price) {
        return parseFloat(form_base.getVolume()) * parseFloat(price)
    }

    function updateRelAmount() {
        if(orderIsSelected()) {
            const price = parseFloat(preffered_order.price)
            let new_rel = newRelVolume(preffered_order.price)

            if(!preffered_order.is_asks) {
                // If new rel volume is higher than the order max volume
                const max_volume = parseFloat(preffered_order.volume)
                if(new_rel > max_volume) {
                    new_rel = max_volume

                    // Set base
                    const max_base_volume = max_volume / price
                    if(parseFloat(form_base.getVolume()) !== max_base_volume) {
                        const new_base_text = General.formatDouble(max_base_volume)
                        if(form_base.field.text !== new_base_text)
                            form_base.field.text = new_base_text
                    }
                }
            }

            // Set rel
            const new_rel_text = General.formatDouble(new_rel)
            if(form_rel.field.text !== new_rel_text)
                form_rel.field.text = new_rel_text
        }
    }

    function getCalculatedPrice() {
        const base = form_base.getVolume()
        const rel = form_rel.getVolume()

        return General.isZero(base) || General.isZero(rel) ? "0" : API.get().get_price_amount(base, rel)
    }

    function getCurrentPrice() {
        return !orderIsSelected() ? getCalculatedPrice() : preffered_order.price
    }

    function hasValidPrice() {
        return orderIsSelected() || parseFloat(getCalculatedPrice()) !== 0
    }

    // Cache Trade Info
    readonly property var default_curr_trade_info: ({ "input_final_value": "0", "is_ticker_of_fees_eth": false, "trade_fee": "0", "tx_fee": "0", "not_enough_balance_to_pay_the_fees": false, "amount_needed": "0" })
    property bool valid_trade_info: false
    property var curr_trade_info: default_curr_trade_info

    function resetTradeInfo() {
        curr_trade_info = default_curr_trade_info
        valid_trade_info = false
    }

    Timer {
        id: trade_info_timer
        repeat: true
        running: true
        interval: 500
        onTriggered: {
            if(inCurrentPage() && !valid_trade_info) {
                updateTradeInfo()
            }
        }
    }

    function notEnoughBalanceForFees() {
        return valid_trade_info && curr_trade_info.not_enough_balance_to_pay_the_fees
    }

    function notEnoughBalance() {
        return form_base.notEnoughBalance()
    }


    function getTradeInfo(base, rel, amount, set_as_current=true) {
        if(inCurrentPage()) {
            let info = API.get().get_trade_infos(base, rel, amount)

            console.log("Getting Trade info with parameters: ", base, rel, amount, " -  Result: ", JSON.stringify(info))

            if(info.input_final_value === undefined || info.input_final_value === "nan" || info.input_final_value === "NaN") {
                info = default_curr_trade_info
                valid_trade_info = false
            }
            else valid_trade_info = true

            if(set_as_current) {
                curr_trade_info = info
            }

            return info
        }
        else return curr_trade_info
    }



    // Orderbook
    function fillTickersIfEmpty() {
        selector_base.fillIfEmpty()
        selector_rel.fillIfEmpty()
    }

    function updateTradeInfo(force=false) {
        const base = getTicker(true)
        const rel = getTicker(false)
        const amount = form_base.getVolume()
        if(force ||
            (base !== undefined && rel !== undefined && amount !== undefined &&
             base !== ''        && rel !== ''        && amount !== '' && amount !== '0')) {
            getTradeInfo(base, rel, amount)

            // Since new implementation does not update fees instantly, re-cap the volume every time, just in case
            form_base.capVolume()
        }
    }

    // Trade
    function open(ticker) {
        setTicker(true, ticker)
        onOpened()
    }

    function onOpened() {
        fillTickersIfEmpty()
        reset(true)
        updateForms()
        setPair(true)
    }

    function updateForms(my_side, new_ticker) {
        if(my_side === undefined) {
            selector_base.update()
            selector_rel.update()
        }
        else if(my_side) {
            selector_rel.update(new_ticker)
        }
        else {
            selector_base.update(new_ticker)
        }
    }

    function moveToBeginning(coins, ticker) {
        const idx = coins.map(c => c.ticker).indexOf(ticker)
        if(idx === -1) return

        const coin = coins[idx]
        return [coin].concat(coins.filter(c => c.ticker !== ticker))
    }

    function getCoins(my_side) {
        let coins = API.get().enabled_coins

        if(coins.length === 0) return coins

        // Prioritize KMD / BTC pair by moving them to the start
        coins = moveToBeginning(coins, "BTC")
        coins = moveToBeginning(coins, "KMD")

        // Return full list
        if(my_side === undefined) return coins

        // Filter for Sell
        if(my_side) {
            return coins.filter(c => {
                c.balance = API.get().get_balance(c.ticker)

                return true
            })
        }
        // Filter for Receive
        else {
            return coins.filter(c => c.ticker !== getTicker(true))
        }
    }

    function getTicker(is_base) {
        return is_base ? selector_base.getTicker() : selector_rel.getTicker()
    }

    function setTicker(is_base, ticker) {
        if(is_base) selector_base.setTicker(ticker)
        else selector_rel.setTicker(ticker)
    }

    function validBaseRel() {
        const base = getTicker(true)
        const rel = getTicker(false)
        return base !== '' && rel !== '' && base !== rel
    }

    function setPair(is_base) {
        if(getTicker(true) === getTicker(false)) {
            // Base got selected, same as rel
            // Change rel ticker
            selector_rel.setAnyTicker()
        }

        if(validBaseRel()) {
            const new_base = getTicker(true)
            const rel = getTicker(false)
            console.log("Setting current orderbook with params: ", new_base, rel)
            API.get().set_current_orderbook(new_base, rel)
            reset(true, is_base)
            updateTradeInfo()
            updateCexPrice(new_base, rel)
            exchange.onTradeTickerChanged(new_base)
        }
    }

    function trade(base, rel) {
        updateTradeInfo(true) // Force update trade info and cap the value for one last time

        const is_created_order = !orderIsSelected()
        const price_denom = preffered_order.price_denom
        const price_numer = preffered_order.price_numer
        const price = getCurrentPrice()
        const volume = form_base.field.text
        console.log("QML place_sell_order: max balance:", form_base.getMaxVolume())
        console.log("QML place_sell_order: params:", base, " <-> ", rel, "  /  price:", price, "  /  volume:", volume, "  /  is_created_order:", is_created_order, "  /  price_denom:", price_denom, "  /  price_numer:", price_numer)
        console.log("QML place_sell_order: trade info:", JSON.stringify(curr_trade_info))

        const result = API.get().place_sell_order(base, rel, price, volume, is_created_order, price_denom, price_numer)

        if(result === "") {
            action_result = "success"

            toast.show(qsTr("Placed the order"), General.time_toast_basic_info, result, false)

            onOrderSuccess()
        }
        else {
            action_result = "error"

            toast.show(qsTr("Failed to place the order"), General.time_toast_important_error, result)
        }
    }

    function getSendAmountAfterFees(amount, set_as_current) {
        const base = getTicker(true)
        const rel = getTicker(false)

        if(base === '' || rel === '') return 0

        const info = getTradeInfo(getTicker(true), getTicker(false), amount, set_as_current)
        return parseFloat(valid_trade_info ? info.input_final_value : amount)
    }

    // No coins warning
    ColumnLayout {
        anchors.centerIn: parent
        visible: selector_base.ticker_list.length === 0

        DefaultImage {
            Layout.alignment: Qt.AlignHCenter
            source: General.image_path + "setup-wallet-restore-2.svg"
            Layout.bottomMargin: 30
        }

        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + (qsTr("No balance available"))
            font.pixelSize: Style.textSize2
        }

        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text_value: API.get().empty_string + (qsTr("Please enable a coin with balance or deposit funds"))
        }
    }

    // Form
    ColumnLayout {
        id: form

        spacing: layout_margin

        visible: selector_base.ticker_list.length > 0

        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                id: left_section
                anchors.left: parent.left
                anchors.right: forms.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: layout_margin

                InnerBackground {
                    id: graph_bg

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: selectors.top
                    anchors.bottomMargin: layout_margin * 2

                    CandleStickChart {
                        anchors.fill: parent
                    }
                }

                // Ticker Selectors
                RowLayout {
                    id: selectors
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: orderbook.top
                    anchors.bottomMargin: 10
                    spacing: 40

                    TickerSelector {
                        id: selector_base
                        my_side: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    }

                    DefaultImage {
                        source: General.image_path + "trade_icon.svg"
                        fillMode: Image.PreserveAspectFit
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: Layout.preferredWidth
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }

                    TickerSelector {
                        id: selector_rel
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }
                }

                Orderbook {
                    id: orderbook
                    height: 250
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                }
            }

            Item {
                id: forms
                width: 375
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                // Sell
                OrderForm {
                    id: form_base

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    my_side: true
                }

                // Receive
                OrderForm {
                    id: form_rel
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: form_base.bottom
                    anchors.topMargin: layout_margin

                    field.enabled: form_base.field.enabled
                }

                // Show errors
                DefaultText {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: form_rel.bottom
                    anchors.topMargin: layout_margin * 2

                    font.pixelSize: Style.textSizeSmall4
                    color: Style.colorRed

                    text_value: API.get().empty_string + (
                                                        notEnoughBalance() ? (qsTr("%1 balance is lower than minimum trade amount").arg(selector_base.getTicker()) + " : " + General.getMinTradeAmount()) :
                                                        notEnoughBalanceForFees() ?
                                                        (qsTr("Not enough balance for the fees. Need at least %1 more", "AMT TICKER").arg(General.formatCrypto("", parseFloat(curr_trade_info.amount_needed), selector_base.getTicker()))) :
                                                        (form_base.hasEthFees() && !form_base.hasEnoughEthForFees()) ? (qsTr("Not enough ETH for the transaction fee")) :
                                                        (form_base.fieldsAreFilled() && !form_base.higherThanMinTradeAmount()) ? (qsTr("Sell amount is lower than minimum trade amount") + " : " + General.getMinTradeAmount()) :
                                                        (form_rel.fieldsAreFilled() && !form_rel.higherThanMinTradeAmount()) ? (qsTr("Receive amount is lower than minimum trade amount") + " : " + General.getMinTradeAmount()) : ""

                              )
                    visible: form_base.fieldsAreFilled() && (notEnoughBalanceForFees() ||
                                                             (form_base.hasEthFees() && !form_base.hasEnoughEthForFees()) ||
                                                             !form_base.higherThanMinTradeAmount() ||
                                                             (form_rel.fieldsAreFilled() && !form_rel.higherThanMinTradeAmount()))
                }
            }
        }

        // Price
        PriceLine {
            Layout.alignment: Qt.AlignHCenter
        }

        ConfirmTradeModal {
            id: confirm_trade_modal
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
