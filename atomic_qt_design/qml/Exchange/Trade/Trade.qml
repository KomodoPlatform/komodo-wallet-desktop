import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

Item {
    id: exchange_trade

    property string action_result
    property string prev_base
    property string prev_rel

    // Override
    property var onOrderSuccess: () => {}

    // Local
    function inCurrentPage() {
        return  exchange.inCurrentPage() &&
                exchange.current_page === General.idx_exchange_trade
    }

    function fullReset() {
        reset(true)
        prev_base = ''
        prev_rel = ''
        orderbook_timer.running = false
    }

    function reset(reset_result=true, is_base) {
        if(reset_result) action_result = ""
        resetPreferredPrice()
        form_base.reset(is_base)
        form_rel.reset(is_base)
        resetTradeInfo()
    }

    Timer {
        id: orderbook_timer
        repeat: true
        interval: 5000
        onTriggered: {
            if(inCurrentPage()) updateOrderbook()
        }
    }


    // Price
    readonly property string empty_price: "0"
    property string preffered_price: empty_price

    function resetPreferredPrice() {
        preffered_price = empty_price
    }

    function prepareCreateMyOwnOrder() {
        resetPreferredPrice()
    }

    function selectOrder(price, volume) {
        preffered_price = price
        updateRelAmount()
    }

    function updateRelAmount() {
        if(preffered_price !== empty_price) {
            form_rel.field.text = (parseFloat(form_base.getVolume()) * parseFloat(preffered_price)).toFixed(8)
        }
    }

    function getCalculatedPrice() {
        const base = form_base.getVolume()
        const rel = form_rel.getVolume()

        return General.isZero(base) || General.isZero(rel) ? "0" : API.get().get_price_amount(base, rel)
    }

    function getCurrentPrice() {
        return preffered_price === empty_price ? getCalculatedPrice() : preffered_price
    }

    function hasValidPrice() {
        return preffered_price !== empty_price || parseFloat(getCalculatedPrice()) !== 0
    }

    // Cache Trade Info
    readonly property var default_curr_trade_info: ({ "input_final_value": "0", "is_ticker_of_fees_eth": false, "trade_fee": "0", "tx_fee": "0"})
    property bool valid_trade_info: false
    property var curr_trade_info: default_curr_trade_info

    function resetTradeInfo() {
        curr_trade_info = default_curr_trade_info
        valid_trade_info = false
    }

    Timer {
        id: trade_info_timer
        repeat: true
        interval: 500
        onTriggered: {
            if(inCurrentPage() && !valid_trade_info) {
                updateTradeInfo()
            }
        }
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
    property var orderbook_model

    function fillTickersIfEmpty() {
        form_base.fillIfEmpty()
        form_rel.fillIfEmpty()
    }

    function updateOrderbook() {
        fillTickersIfEmpty()

        orderbook_model = API.get().get_orderbook(getTicker(true))
        orderbook_timer.running = true
        updateTradeInfo()
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
        updateOrderbook()
        reset(true)
        updateForms()
    }

    function updateForms(my_side, new_ticker) {
        if(my_side === undefined) {
            form_base.update()
            form_rel.update()
        }
        else if(my_side) {
            form_rel.update(new_ticker)
        }
        else {
            form_base.update(new_ticker)
        }
    }

    function getCurrentOrderbook() {
        if(orderbook_model === undefined) return []

        const cb = orderbook_model[getTicker()]

        return cb === undefined ? [] : cb
    }

    function getCoins(my_side) {
        const coins = API.get().enabled_coins
        if(my_side === undefined) return coins

        // Filter for Sell
        if(my_side) {
            return coins.filter(c => {
                c.balance = API.get().get_balance(c.ticker)

                return c.balance !== '' && parseFloat(c.balance) >= General.getMinTradeAmount()
            })
        }
        // Filter for Receive
        else {
            return coins.filter(c => c.ticker !== getTicker(true))
        }
    }

    function getTicker(is_base) {
        return is_base ? form_base.getTicker() : form_rel.getTicker()
    }

    function setTicker(is_base, ticker) {
        if(is_base) form_base.setTicker(ticker)
        else form_rel.setTicker(ticker)
    }

    function swapPair() {
        let base = getTicker(true)
        let rel = getTicker(false)

        // Fill previous ones if they are blank
        if(prev_base === '') prev_base = form_base.getAnyAvailableCoin(rel)
        if(prev_rel === '') prev_rel = form_rel.getAnyAvailableCoin(base)

        // Get different value if they are same
        if(base === rel) {
            if(base !== prev_base) base = prev_base
            else if(rel !== prev_rel) rel = prev_rel
        }

        // Swap
        const curr_base = base
        setTicker(true, rel)
        setTicker(false, curr_base)
    }

    function validBaseRel() {
        const base = getTicker(true)
        const rel = getTicker(false)
        return base !== '' && rel !== '' && base !== rel
    }

    function setPair(is_base) {
        if(getTicker(true) === getTicker(false)) swapPair()
        else {
            if(validBaseRel()) {
                const new_base = getTicker(true)
                const rel = getTicker(false)
                console.log("Setting current orderbook with params: ", new_base, rel)
                API.get().set_current_orderbook(new_base, rel)
                reset(true, is_base)
                updateOrderbook()

                exchange.onTradeTickerChanged(new_base)
            }
        }
    }

    function trade(base, rel) {
        updateTradeInfo(true) // Force update trade info and cap the value for one last time

        const price = getCurrentPrice()
        const volume = form_base.field.text
        console.log("QML place_sell_order: max balance:", form_base.getMaxVolume())
        console.log("QML place_sell_order: params:", base, " <-> ", rel, "  /  price:", price, "  /  volume:", volume)
        console.log("QML place_sell_order: trade info:", JSON.stringify(curr_trade_info))
        action_result = API.get().place_sell_order(base, rel, price, volume) ? "success" : "error"
        if(action_result === "success") {
            onOrderSuccess()
        }
    }

    function getSendAmountAfterFees(amount, set_as_current) {
        const base = getTicker(true)
        const rel = getTicker(false)

        if(base === '' || rel === '') return 0

        const info = getTradeInfo(getTicker(true), getTicker(false), amount, set_as_current)
        return parseFloat(valid_trade_info ? info.input_final_value : amount)
    }

    function getReceiveAmount(price) {
        return (parseFloat(form_base.getVolume()) * parseFloat(price)).toFixed(8)
    }

    // No coins warning
    ColumnLayout {
        anchors.centerIn: parent
        visible: form_base.ticker_list.length === 0

        Image {
            Layout.alignment: Qt.AlignHCenter
            source: General.image_path + "setup-wallet-restore-2.svg"
            Layout.bottomMargin: 30
        }

        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text: API.get().empty_string + (qsTr("No balance available"))
            font.pixelSize: Style.textSize2
        }

        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text: API.get().empty_string + (qsTr("Please enable a coin with balance or deposit funds"))
        }
    }

    // Form
    ColumnLayout {
        id: form

        visible: form_base.ticker_list.length > 0

        anchors.centerIn: parent

        RowLayout {
            spacing: 15

            // Sell
            OrderForm {
                id: form_base
                Layout.fillWidth: true
                my_side: true
            }

            Image {
                source: General.image_path + "exchange-exchange.svg"
                Layout.alignment: Qt.AlignVCenter
            }

            // Receive
            OrderForm {
                id: form_rel
                enabled: form_base.fieldsAreFilled()
                field.enabled: enabled && preffered_price === empty_price
            }
        }

        // Trade button
        PrimaryButton {
            id: action_button
            Layout.fillWidth: true

            text: API.get().empty_string + (qsTr("Trade"))
            enabled: valid_trade_info && form_base.isValid() && form_rel.isValid()
            onClicked: confirm_trade_modal.open()
        }

        ConfirmTradeModal {
            id: confirm_trade_modal
        }

        // Price
        PriceLine {
            Layout.alignment: Qt.AlignHCenter
        }

        // Result
        DefaultText {
            Layout.alignment: Qt.AlignHCenter

            color: action_result === "success" ? Style.colorGreen : Style.colorRed

            text: API.get().empty_string + (action_result === "" ? "" : action_result === "success" ? "" : qsTr("Failed to place the order."))
        }

        // Show ETH error
        DefaultText {
            Layout.alignment: Qt.AlignHCenter

            text: API.get().empty_string + (qsTr("Not enough ETH for the transaction fee"))
            color: Style.colorRed
            visible: form_base.hasEthFees() && !form_base.hasEnoughEthForFees()
        }

        // Show min amount error
        DefaultText {
            Layout.alignment: Qt.AlignHCenter

            text: API.get().empty_string + (qsTr("Sell amount is lower than minimum trade amount") + " : " + General.getMinTradeAmount())
            color: Style.colorRed
            visible: form_base.fieldsAreFilled() && !form_base.higherThanMinTradeAmount()
        }

        // Show min amount error
        DefaultText {
            Layout.alignment: Qt.AlignHCenter

            text: API.get().empty_string + (qsTr("Receive amount is lower than minimum trade amount") + " : " + General.getMinTradeAmount())
            color: Style.colorRed
            visible: form_rel.fieldsAreFilled() && !form_rel.higherThanMinTradeAmount()
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
