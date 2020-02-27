import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.12
import "../../Components"
import "../../Constants"

Item {
    id: exchange_trade

    property string action_result
    property string prev_base
    property string prev_rel

    function inCurrentPage() {
        return  exchange.inCurrentPage() &&
                exchange.current_page === General.idx_exchange_trade
    }

    function fullReset() {
        reset()
        prev_base = ''
        prev_rel = ''
        curr_trade_info = default_curr_trade_info
        orderbook_timer.running = false
    }

    function reset(reset_result=true) {
        if(reset_result) action_result = ""
        resetPreferredPrice()
        form_base.reset()
        form_rel.reset()
    }

    // Orders page quick refresher, used right after a fresh successful trade
    Timer {
        id: refresh_timer
        repeat: true
        interval: 500
        triggeredOnStart: true
        onTriggered: {
            if(inCurrentPage()) API.get().refresh_orders_and_swaps()
        }
    }

    Timer {
        id: stop_refreshing
        interval: 5000
        onTriggered: refresh_timer.stop()
    }

    function onOrderSuccess() {
        reset(false)
        exchange.current_page = General.idx_exchange_orders
        refresh_timer.restart()
        stop_refreshing.restart()
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

        return General.isZero(base) || General.isZero(rel) ? "0" : (parseFloat(rel) / parseFloat(base)).toString()
    }

    function getCurrentPrice() {
        return preffered_price === empty_price ? getCalculatedPrice() : preffered_price
    }

    function hasValidPrice() {
        return preffered_price !== empty_price || parseFloat(getCalculatedPrice()) !== 0
    }

    // Cache Trade Info
    readonly property var default_curr_trade_info: ({"input_final_value": "0", "is_ticker_of_fees_eth": false, "trade_fee": "0", "tx_fee": "0"})
    property var curr_trade_info: default_curr_trade_info

    function getTradeInfo(base, rel, amount, set_as_current=true) {
        if(inCurrentPage()) {
            const info = API.get().get_trade_infos(base, rel, amount)

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

    function updateTradeInfo() {
        const base = getTicker(true)
        const rel = getTicker(false)
        const amount = form_base.getVolume()
        if(base !== undefined && rel !== undefined && amount !== undefined &&
           base !== ''        && rel !== ''        && amount !== '' && amount !== '0') {
            getTradeInfo(base, rel, amount)
        }
    }

    Timer {
        id: orderbook_timer
        repeat: true
        interval: 5000
        onTriggered: updateOrderbook()
    }

    // Trade
    function open(ticker) {
        setTicker(true, ticker)
        onOpened()
    }

    function onOpened() {
        updateOrderbook()
        reset()
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

                return c.balance !== '' && parseFloat(c.balance) > 0
            })
        }
        // Filter for Receive
        else {
            return coins.filter(c => c.ticker !== getTicker(true))
        }
    }

    function getReceiveCoins() {
        return getCoins()
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

    function setPair() {
        if(getTicker(true) === getTicker(false)) swapPair()
        else {
            if(validBaseRel()) {
                reset()

                const new_base = getTicker(true)
                API.get().set_current_orderbook(new_base)
                updateOrderbook()

                exchange.onTradeTickerChanged(new_base)
            }
        }
    }

    function trade(base, rel, base_volume) {
        action_result = API.get().place_sell_order(base, rel, getCurrentPrice(), base_volume) ? "success" : "error"
        if(action_result === "success") {
            onOrderSuccess()
        }
    }

    function getSendAmountAfterFees(amount, set_as_current) {
        const base = getTicker(true)
        const rel = getTicker(false)

        if(base === '' || rel === '') return 0

        return parseFloat(getTradeInfo(getTicker(true), getTicker(false), amount, set_as_current).input_final_value)
    }

    function getReceiveAmount(price) {
        return (curr_trade_info.input_final_value * parseFloat(price)).toFixed(8)
    }

    // No coins warning
    ColumnLayout {
        anchors.centerIn: parent
        visible: form_base.getTickerList().length === 0

        Image {
            Layout.alignment: Qt.AlignHCenter
            source: General.image_path + "setup-wallet-restore-2.svg"
            Layout.bottomMargin: 30
        }

        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("No balance available")
            font.pointSize: Style.textSize2
        }

        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Please enable a coin with balance or deposit funds")
        }
    }

    // Form
    ColumnLayout {
        id: form

        visible: form_base.getTickerList().length > 0

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
        Button {
            id: action_button
            Layout.fillWidth: true

            text: qsTr("Trade")
            enabled: form_base.isValid() && form_rel.isValid()
            onClicked: trade(getTicker(true), getTicker(false), form_base.field.text)
        }

        // Price
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            text: !hasValidPrice() ? '' : (preffered_price === empty_price ? qsTr("Price: ") + getCalculatedPrice() :
                                                    qsTr("Selected Price: ") + preffered_price) + " " + getTicker(false)
        }

        // Result
        DefaultText {
            Layout.alignment: Qt.AlignHCenter

            color: action_result === "success" ? Style.colorGreen : Style.colorRed

            text: action_result === "" ? "" : action_result === "success" ? "" : qsTr("Failed to place the order.")
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
