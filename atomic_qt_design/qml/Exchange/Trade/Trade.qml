import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "../../Components"
import "../../Constants"
import "../../Wallet"

Item {
    id: exchange_trade

    property string action_result

    readonly property bool block_everything: chart.is_fetching || swap_cooldown.running

    property bool sell_mode: true
    property string left_ticker: selector_left.ticker
    property string right_ticker: selector_right.ticker
    property string base_ticker: sell_mode ? left_ticker : right_ticker
    property string rel_ticker: sell_mode ? right_ticker : left_ticker

    Timer {
        id: swap_cooldown
        repeat: false
        interval: 1000
    }

    // Override
    property var onOrderSuccess: () => {}

    function getCurrentForm() {
        return sell_mode ? form_base : form_rel
    }

    onSell_modeChanged: reset()

    // Local
    function inCurrentPage() {
        return  exchange.inCurrentPage() &&
                exchange.current_page === General.idx_exchange_trade
    }

    function fullReset() {
        initialized_orderbook_pair = false
        reset(true)
        sell_mode = true
    }

    function reset(reset_result=true, is_base) {
        if(reset_result) action_result = ""
        resetPreferredPrice()
        form_base.reset()
        form_rel.reset()
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
        sell_mode = !is_asks

        preffered_order.is_asks = is_asks
        preffered_order.price = price
        preffered_order.volume = quantity
        preffered_order.price_denom = price_denom
        preffered_order.price_numer = price_numer
        preffered_order = preffered_order

        const volume_text = General.formatDouble(quantity)
        const price_text = General.formatDouble(price)
        if(is_asks) {
            form_rel.field.text = volume_text
            form_rel.price_field.text = price_text
        }
        else {
            form_base.field.text = volume_text
            form_base.price_field.text = price_text
        }

        getCurrentForm().field.forceActiveFocus()
    }

    function getCalculatedPrice() {
        let price = getCurrentForm().price_field.text
        return General.isZero(price) ? "0" : price
    }

    function getCurrentPrice() {
        return !orderIsSelected() ? getCalculatedPrice() : preffered_order.price
    }

    function hasValidPrice() {
        return orderIsSelected() || !General.isZero(getCalculatedPrice())
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
        return getCurrentForm().notEnoughBalance()
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
    function updateTradeInfo(force=false) {
        const base = base_ticker
        const rel = rel_ticker
        const amount = sell_mode ? getCurrentForm().getVolume() :
                                   General.formatDouble(getCurrentForm().getNeededAmountToSpend(getCurrentForm().getVolume()))
        if(force || (General.isFilled(base) && General.isFilled(rel) && !General.isZero(amount))) {
            getTradeInfo(base, rel, amount)

            // Since new implementation does not update fees instantly, re-cap the volume every time, just in case
            getCurrentForm().capVolume()
        }
    }

    // Trade
    function open(ticker) {
        // TODO: setPair(true, ticker)
        onOpened()
    }

    property bool initialized_orderbook_pair: false
    function onOpened() {
        if(!initialized_orderbook_pair) {
            initialized_orderbook_pair = true
            API.get().trading_pg.set_current_orderbook("KMD", "BTC")
        }

        reset(true)
        setPair(true)
    }

    function setPair(is_left_side, changed_ticker) {
        swap_cooldown.restart()

        let base = left_ticker
        let rel = right_ticker

        let is_swap = false
        // Set the new one if it's a change
        if(changed_ticker) {
            if(is_left_side) {
                // Check if it's a swap
                if(base !== changed_ticker && rel === changed_ticker)
                    is_swap = true
                else base = changed_ticker
            }
            else {
                // Check if it's a swap
                if(rel !== changed_ticker && base === changed_ticker)
                    is_swap = true
                else rel = changed_ticker
            }
        }

        if(is_swap) {
            console.log("Swapping current pair, it was: ", base, rel)
            API.get().trading_pg.swap_market_pair()
            const tmp = base
            base = rel
            rel = tmp
        }
        else {
            console.log("Setting current orderbook with params: ", base, rel)
            API.get().trading_pg.set_current_orderbook(base, rel)
        }

        reset(true, is_left_side)
        updateTradeInfo()
        updateCexPrice(base, rel)
        exchange.onTradeTickerChanged(base)
    }

    function trade(base, rel, options, default_config) {
        updateTradeInfo(true) // Force update trade info and cap the value for one last time

        console.log("Trade config: ", JSON.stringify(options))
        console.log("Default config: ", JSON.stringify(default_config))

        let nota = ""
        let confs = ""

        if(options.enable_custom_config) {
            if(options.is_dpow_configurable) {
                nota = options.enable_dpow_confs ? "1" : "0"
            }

            if(nota !== "1") {
                confs = options.required_confirmation_count.toString()
            }
        }
        else {
            if(General.exists(default_config.requires_notarization)) {
                nota = default_config.requires_notarization ? "1" : "0"
            }

            if(nota !== "1" && General.exists(default_config.required_confirmations)) {
                confs = default_config.required_confirmations.toString()
            }
        }


        const current_form = getCurrentForm()

        const is_created_order = !orderIsSelected()
        const price_denom = preffered_order.price_denom
        const price_numer = preffered_order.price_numer
        const price = getCurrentPrice()
        const volume = current_form.field.text
        console.log("QML place order: max balance:", current_form.getMaxVolume())
        console.log("QML place order: params:", base, " <-> ", rel, "  /  price:", price, "  /  volume:", volume, "  /  is_created_order:", is_created_order, "  /  price_denom:", price_denom, "  /  price_numer:", price_numer,
                    "  /  nota:", nota, "  /  confs:", confs)
        console.log("QML place order: trade info:", JSON.stringify(curr_trade_info))

        let result

        if(sell_mode)
            result = API.get().trading_pg.place_sell_order(base, rel, price, volume, is_created_order, price_denom, price_numer, nota, confs)
        else
            result = API.get().trading_pg.place_buy_order(base, rel, price, volume, is_created_order, price_denom, price_numer, nota, confs)

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

    // Form
    ColumnLayout {
        id: form

        spacing: layout_margin

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
                        id: chart
                        anchors.fill: parent
                    }
                }


                // Ticker Selectors
                RowLayout {
                    id: selectors
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: orderbook.top
                    anchors.bottomMargin: layout_margin
                    spacing: 40

                    TickerSelector {
                        id: selector_left
                        left_side: true
                        ticker_list: API.get().trading_pg.market_pairs_mdl.left_selection_box
                        ticker: API.get().trading_pg.market_pairs_mdl.left_selected_coin
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    }

                    // Swap button
                    DefaultImage {
                        source: General.image_path + "trade_icon.svg"
                        fillMode: Image.PreserveAspectFit
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: Layout.preferredWidth
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if(!block_everything)
                                    setPair(true, right_ticker)
                            }
                        }
                    }

                    TickerSelector {
                        id: selector_right
                        left_side: false
                        ticker_list: API.get().trading_pg.market_pairs_mdl.right_selection_box
                        ticker: API.get().trading_pg.market_pairs_mdl.right_selected_coin
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }
                }

                Orderbook {
                    id: orderbook
                    height: 250
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: price_line.top
                    anchors.bottomMargin: layout_margin
                }


                // Price
                PriceLine {
                    id: price_line
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
                    visible: sell_mode

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    is_sell_form: true
                }

                // Receive
                OrderForm {
                    id: form_rel
                    visible: !form_base.visible

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                }

                // Show errors
                DefaultText {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: form_base.visible ? form_base.bottom : form_rel.bottom
                    anchors.topMargin: layout_margin * 2

                    font.pixelSize: Style.textSizeSmall4
                    color: Style.colorRed

                    text_value: API.get().settings_pg.empty_string + (
                                    // Balance check can be done without price too, prioritize that for sell
                                    notEnoughBalance() ? (qsTr("Tradable (after fees) %1 balance is lower than minimum trade amount").arg(base_ticker) + " : " + General.getMinTradeAmount()) :

                                    // Fill the price field
                                    General.isZero(getCurrentPrice()) ? (qsTr("Please fill the price field")) :

                                    // Fill the volume field
                                    General.isZero(getCurrentForm().getVolume()) ? (qsTr("Please fill the volume field")) :

                                    // Fields are filled, fee can be checked
                                    notEnoughBalanceForFees() ?
                                        (qsTr("Not enough balance for the fees. Need at least %1 more", "AMT TICKER").arg(General.formatCrypto("", curr_trade_info.amount_needed, base_ticker))) :

                                    // Not enough ETH for fees
                                    (getCurrentForm().hasEthFees() && !getCurrentForm().hasEnoughEthForFees()) ? (qsTr("Not enough ETH for the transaction fee")) :

                                    // Trade amount is lower than the minimum
                                    (getCurrentForm().fieldsAreFilled() && !getCurrentForm().higherThanMinTradeAmount()) ? ((qsTr("Amount is lower than minimum trade amount")) + " : " + General.getMinTradeAmount()) : ""
                              )

                    visible: text_value !== ""
                }
            }
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
