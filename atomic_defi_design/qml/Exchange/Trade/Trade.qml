import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../../Components"
import "../../Constants"
import "../../Wallet"

Item {
    id: exchange_trade

    property string action_result

    readonly property bool block_everything: swap_cooldown.running || fetching_multi_ticker_fees_busy

    readonly property bool fetching_multi_ticker_fees_busy: API.app.trading_pg.fetching_multi_ticker_fees_busy
    readonly property alias multi_order_enabled: multi_order_switch.checked

    signal prepareMultiOrder()
    property bool multi_order_values_are_valid: true



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
        multi_order_switch.checked = false
    }

    // Price
    property string cex_price
    function updateCexPrice(base, rel) {
        cex_price = API.app.get_cex_rates(base, rel)
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
            let info = API.app.get_trade_infos(base, rel, amount)

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
        setPair(true, ticker)
        onOpened()
    }

    property bool initialized_orderbook_pair: false
    readonly property string default_base: "KMD"
    readonly property string default_rel: "BTC"
    function onOpened() {
        if(!initialized_orderbook_pair) {
            initialized_orderbook_pair = true
            API.app.trading_pg.set_current_orderbook(default_base, default_rel)
        }

        reset(true)
        setPair(true)
    }


    signal pairChanged(string base, string rel)

    function setPair(is_left_side, changed_ticker) {
        let base = left_ticker
        let rel = right_ticker

        let is_swap = false
        // Set the new one if it's a change
        if(changed_ticker) {
            if(is_left_side) {
                if(base === changed_ticker) return

                // Check if it's a swap
                if(base !== changed_ticker && rel === changed_ticker)
                    is_swap = true
                else base = changed_ticker
            }
            else {
                if(rel === changed_ticker) return

                // Check if it's a swap
                if(rel !== changed_ticker && base === changed_ticker)
                    is_swap = true
                else rel = changed_ticker
            }
        }

        swap_cooldown.restart()

        if(is_swap) {
            console.log("Swapping current pair, it was: ", base, rel)
            API.app.trading_pg.swap_market_pair()
            const tmp = base
            base = rel
            rel = tmp
        }
        else {
            console.log("Setting current orderbook with params: ", base, rel)
            API.app.trading_pg.set_current_orderbook(base, rel)
        }

        reset(true, is_left_side)
        updateTradeInfo()
        updateCexPrice(base, rel)
        pairChanged(base, rel)
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
        console.log("QML place order: max_taker_volume:", current_form.getMaxVolume())
        console.log("QML place order: params:", base, " <-> ", rel, "  /  price:", price, "  /  volume:", volume, "  /  is_created_order:", is_created_order, "  /  price_denom:", price_denom, "  /  price_numer:", price_numer,
                    "  /  nota:", nota, "  /  confs:", confs)
        console.log("QML place order: trade info:", JSON.stringify(curr_trade_info))

        if(sell_mode)
            API.app.trading_pg.place_sell_order(base, rel, price, volume, is_created_order, price_denom, price_numer, nota, confs)
        else
            API.app.trading_pg.place_buy_order(base, rel, price, volume, is_created_order, price_denom, price_numer, nota, confs)
    }

    readonly property bool buy_sell_rpc_busy: API.app.trading_pg.buy_sell_rpc_busy
    readonly property var buy_sell_last_rpc_data: API.app.trading_pg.buy_sell_last_rpc_data

    onBuy_sell_last_rpc_dataChanged: {
        const response = General.clone(buy_sell_last_rpc_data)

        if(response.error_code) {
            confirm_trade_modal.close()

            action_result = "error"

            toast.show(qsTr("Failed to place the order"), General.time_toast_important_error, response.error_message)

            return
        }
        else if(response.result && response.result.uuid) { // Make sure there is information
            confirm_trade_modal.close()

            action_result = "success"

            toast.show(qsTr("Placed the order"), General.time_toast_basic_info, General.prettifyJSON(response.result), false)

            onOrderSuccess()
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

                    content: CandleStickChart {
                        id: chart
                        width: graph_bg.width
                        height: graph_bg.height
                    }
                }


                // Ticker Selectors
                RowLayout {
                    id: selectors
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: orderbook_area.top
                    anchors.bottomMargin: layout_margin
                    spacing: 20

                    TickerSelector {
                        id: selector_left
                        left_side: true
                        ticker_list: API.app.trading_pg.market_pairs_mdl.left_selection_box
                        ticker: API.app.trading_pg.market_pairs_mdl.left_selected_coin
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.fillWidth: true
                    }

                    // Swap button
                    SwapIcon {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.preferredHeight: selector_left.height * 0.9

                        top_arrow_ticker: selector_left.ticker
                        bottom_arrow_ticker: selector_right.ticker
                        hovered: swap_button.containsMouse

                        DefaultMouseArea {
                            id: swap_button
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if(!block_everything)
                                    setPair(true, right_ticker)
                            }
                        }
                    }

                    TickerSelector {
                        id: selector_right
                        left_side: false
                        ticker_list: API.app.trading_pg.market_pairs_mdl.right_selection_box
                        ticker: API.app.trading_pg.market_pairs_mdl.right_selected_coin
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.fillWidth: true
                    }
                }

                StackLayout {
                    id: orderbook_area
                    height: 250
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: price_line.top
                    anchors.bottomMargin: layout_margin

                    currentIndex: multi_order_enabled ? 1 : 0

                    Orderbook {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    MultiOrder {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }


                // Price
                InnerBackground {
                    id: price_line
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: price_line_obj.height + 30
                    PriceLine {
                        id: price_line_obj
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }
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

                // Multi-Order
                FloatingBackground {
                    visible: sell_mode

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: form_base.visible ? form_base.bottom : form_rel.bottom
                    anchors.topMargin: layout_margin

                    height: column_layout.height

                    ColumnLayout {
                        id: column_layout

                        width: parent.width

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: layout_margin
                            Layout.rightMargin: layout_margin
                            Layout.topMargin: layout_margin
                            Layout.bottomMargin: layout_margin
                            spacing: layout_margin

                            DefaultSwitch {
                                id: multi_order_switch
                                Layout.leftMargin: 15
                                Layout.rightMargin: Layout.leftMargin
                                Layout.fillWidth: true

                                text: qsTr("Multi-Order")
                                enabled: !block_everything
                                onCheckedChanged: {
                                    if(checked) {
                                        getCurrentForm().field.text = getCurrentForm().getVolumeCap()
                                    }
                                }
                            }

                            DefaultText {
                                id: first_text

                                Layout.leftMargin: multi_order_switch.Layout.leftMargin
                                Layout.rightMargin: Layout.leftMargin
                                Layout.fillWidth: true

                                text_value: qsTr("Select additional assets for multi-order creation.")
                                font.pixelSize: Style.textSizeSmall2
                            }

                            DefaultText {
                                Layout.leftMargin: multi_order_switch.Layout.leftMargin
                                Layout.rightMargin: Layout.leftMargin
                                Layout.fillWidth: true

                                text_value: qsTr("Same funds will be used until an order matches.")
                                font.pixelSize: first_text.font.pixelSize
                            }

                            DefaultButton {
                                text: qsTr("Submit Trade")
                                Layout.leftMargin: multi_order_switch.Layout.leftMargin
                                Layout.rightMargin: Layout.leftMargin
                                Layout.fillWidth: true
                                enabled: multi_order_enabled && getCurrentForm().can_submit_trade
                                onClicked: {
                                    multi_order_values_are_valid = true
                                    prepareMultiOrder()
                                    if(multi_order_values_are_valid)
                                        confirm_multi_order_trade_modal.open()
                                }
                            }
                        }
                    }
                }
            }
        }

        ConfirmTradeModal {
            id: confirm_trade_modal
        }

        ConfirmMultiOrderTradeModal {
            id: confirm_multi_order_trade_modal
        }
    }
}










/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
