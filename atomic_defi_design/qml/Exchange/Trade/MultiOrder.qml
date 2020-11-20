import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../../Components"
import "../../Constants"

InnerBackground {
    DefaultFlickable {
        id: list
        anchors.fill: parent

        contentWidth: width
        contentHeight: column.height


        Column {
            id: column

            Repeater {
                model: API.app.trading_pg.market_pairs_mdl.multiple_selection_box

                delegate: Item {
                    id: multi_order_line
                    width: list.width
                    height: 60

                    readonly property bool is_parent_coin: model.ticker === rel_ticker

                    readonly property string base: sell_mode ? left_ticker : model.ticker
                    readonly property string rel: sell_mode ? model.ticker : left_ticker

                    readonly property string auto_price: {
                        const current_price = parseFloat(non_null_price)
                        if(rel === right_ticker) return current_price
                        const rel_price_for_one_unit = parseFloat(model.main_fiat_price_for_one_unit)
                        const price_field_fiat = current_price * API.app.get_fiat_from_amount(rel_ticker, "1")
                        const rel_price_relative = rel_price_for_one_unit === 0 ? 0 : price_field_fiat / rel_price_for_one_unit
                        return General.formatDouble(rel_price_relative)
                    }

                    onAuto_priceChanged: price = auto_price

                    property string price: auto_price

                    readonly property double volume: parseFloat(non_null_volume) * parseFloat(price)

                    function resetData() {
                        model.multi_ticker_data = {}
                    }

                    function getData() {
                        return model.multi_ticker_data || {}
                    }

                    function setData(d) {
                        model.multi_ticker_data = d
                    }

                    function reset(multi_order_enabled) {
                        // Clear first
                        enable_ticker.checked = false
                        if(is_parent_coin && multi_order_enabled) {
                            // Retrigger the data changes
                            enable_ticker.checked = true
                        }

                        price = auto_price
                    }

                    function setMultiTickerData() {
                        if(!model.is_multi_ticker_currently_enabled) return

                        if(parseFloat(multi_order_line.price) <= 0) {
                            toast.show(qsTr("%1 price is zero!", "TICKER").arg(model.ticker), General.time_toast_important_error)

                            console.log(model.ticker + " price is not higher than zero, not creating an order for this one")
                            multi_order_values_are_valid = false
                            return
                        }

                        if(multi_order_line.volume < General.getMinTradeAmount()) {
                            toast.show(qsTr("%1 receive volume is lower than minimum trade amount", "TICKER").arg(model.ticker) + " : " + General.getMinTradeAmount(), General.time_toast_important_error)

                            console.log(model.ticker + " receive volume is lower than minimum trade amount, not creating an order for this one")
                            multi_order_values_are_valid = false
                            return
                        }

                        let params = getData()
                        params.base = left_ticker
                        params.rel = model.ticker
                        params.price = multi_order_line.price
                        params.volume = non_null_volume
                        params.is_created_order = true
                        params.base_nota = ""
                        params.base_confs = ""
                        params.rel_nota = ""
                        params.rel_confs = ""

                        params.rel_volume = "" + multi_order_line.volume

                        setData(params)
                    }

                    function updateTradeInfo() {
                        // Will move to backend
                        return
//                        if(fetching_multi_ticker_fees_busy || !enable_ticker.checked) return
//                        if(!model.multi_ticker_data.info_needs_update) return

//                        const base = multi_order_line.base
//                        const rel = multi_order_line.rel

//                        const amt = API.app.get_balance(base)
//                        console.log("Updating trading info for ", base, "/", rel, " with amount:", amt)
//                        let info = API.app.get_trade_infos(base, rel, amt)
//                        console.log(General.prettifyJSON(info))
//                        if(info.input_final_value === undefined || info.input_final_value === "nan" || info.input_final_value === "NaN") {
//                            console.log("Bad trade info!")
//                            return
//                        }

//                        let d = getData()
//                        d.info_needs_update = false
//                        d.trade_info = info
//                        setData(d)
                    }

                    Connections {
                        target: exchange_trade

                        function onMulti_order_enabledChanged() {
                            // Will move to backend
//                            multi_order_line.reset(multi_order_enabled)
                        }

                        function onPrepareMultiOrder() {
                            // Will move to backend
//                            multi_order_line.setMultiTickerData()
                        }

                        function onFetching_multi_ticker_fees_busyChanged() {
                            // Will move to backend
//                            multi_order_line.updateTradeInfo()
                        }
                    }

                    DexComboBoxLine {
                        anchors.fill: parent
                        details: model
                        padding: 10
                        bottom_text: qsTr("You'll receive %1", "AMOUNT TICKER").arg(General.formatCrypto("", multi_order_line.volume, multi_order_line.rel))
                    }

                    AmountFieldWithInfo {
                        id: input_price
                        width: 220
                        anchors.right: fee_info_button.left
                        anchors.rightMargin: 30
                        anchors.verticalCenter: parent.verticalCenter

                        field.left_text: qsTr("Price")
                        field.right_text: model.ticker + "/" + multi_order_line.base
                        field.onTextChanged: multi_order_line.price = field.text

                        field.text: multi_order_line.price
                        field.enabled: !is_parent_coin
                    }

                    DefaultSwitch {
                        id: enable_ticker
                        anchors.rightMargin: 10
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: !block_everything && !is_parent_coin
                        Component.onCompleted: checked = model.is_multi_ticker_currently_enabled || is_parent_coin
                        checked: is_parent_coin
                        onCheckedChanged: {
                            // Will move to backend
//                            model.is_multi_ticker_currently_enabled = checked

//                            if(checked) {
//                                let d = getData()
//                                if(!d.trade_info) {
//                                    d.info_needs_update = true
//                                    setData(d)
//                                }
//                            }
//                            else if(!checked) {
//                                resetData()
//                            }
                        }
                    }

                    FeeIcon {
                        id: fee_info_button
                        anchors.verticalCenter: enable_ticker.verticalCenter
                        anchors.right: enable_ticker.left
                        anchors.rightMargin: 10
                        trade_info: model.multi_ticker_data.trade_info
                        base: multi_order_line.base
                    }

                    HorizontalLine {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                    }
                }
            }
        }
    }

    DefaultBusyIndicator {
        anchors.centerIn: parent
        visible: fetching_multi_ticker_fees_busy
    }
}
