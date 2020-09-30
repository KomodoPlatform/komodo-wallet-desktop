import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../../Components"
import "../../Constants"

InnerBackground {
    DefaultListView {
        id: list
        anchors.fill: parent

        model: API.app.trading_pg.market_pairs_mdl.multiple_selection_box

        delegate: Item {
            id: multi_order_line
            width: list.width
            height: 60

            readonly property string base: sell_mode ? left_ticker : model.ticker
            readonly property string rel: sell_mode ? model.ticker : left_ticker

            readonly property double price: {
                const current_price = parseFloat(getCurrentPrice())
                const rel_price_for_one_unit = parseFloat(model.main_currency_price_for_one_unit)
                const price_field_fiat = current_price * API.app.get_fiat_from_amount(rel_ticker, "1")
                const rel_price_relative = rel_price_for_one_unit === 0 ? 0 : price_field_fiat / rel_price_for_one_unit
                return rel_price_relative
            }

            readonly property double volume: parseFloat(getCurrentForm().getVolume()) * price

            function resetData() {
                model.multi_ticker_data = {}
            }

            function getData() {
                return model.multi_ticker_data || {}
            }

            function setData(d) {
                model.multi_ticker_data = d
            }

            function reset() {
                resetData()
                enable_ticker.checked = false
            }

            function setMultiTickerData() {
                if(!model.is_multi_ticker_currently_enabled) return

                let params = General.clone(model.multi_ticker_data)
                params.base = left_ticker
                params.rel = model.ticker
                params.price = "" + multi_order_line.price
                params.volume = getCurrentForm().getVolume()
                params.is_created_order = true
                params.base_nota = ""
                params.base_confs = ""
                params.rel_nota = ""
                params.rel_confs = ""

                console.log("Setting multi-order params for ", model.ticker, ":", General.prettifyJSON(params))
                setData(params)
            }

            function updateTradeInfo() {
                if(fetching_multi_ticker_fees_busy || !enable_ticker.checked) return
                if(!model.multi_ticker_data.info_needs_update) return

                const base = multi_order_line.base
                const rel = multi_order_line.rel

                const amt = API.app.get_balance(base)
                console.log("Updating trading info for ", base, "/", rel, " with amount:", amt)
                let info = API.app.get_trade_infos(base, rel, amt)
                console.log(General.prettifyJSON(info))
                if(info.input_final_value === undefined || info.input_final_value === "nan" || info.input_final_value === "NaN") {
                    console.log("Bad trade info!")
                    return
                }

                let d = getData()
                d.info_needs_update = false
                d.trade_info = info
                setData(d)
            }

            Connections {
                target: exchange_trade

                function onMulti_order_enabledChanged() {
                    multi_order_line.reset()
                }

                function onPrepareMultiOrder() {
                    multi_order_line.setMultiTickerData()
                }

                function onFetching_multi_ticker_fees_busyChanged() {
                    multi_order_line.updateTradeInfo()
                }
            }

            DexComboBoxLine {
                anchors.fill: parent
                details: model
                padding: 10
            }

            DefaultText {
                id: price_text
                anchors.centerIn: parent
                text_value: API.app.settings_pg.empty_string + (qsTr("Price") + ": " + General.formatCrypto("", multi_order_line.price, multi_order_line.rel))
                font.pixelSize: Style.textSizeSmall3
            }

            DefaultText {
                anchors.left: price_text.left
                anchors.top: price_text.bottom
                anchors.topMargin: 6
                text_value: API.app.settings_pg.empty_string + (qsTr("Volume") + ": " + General.formatCrypto("", multi_order_line.volume, multi_order_line.rel))
                font.pixelSize: Style.textSizeSmall3
            }

            DefaultSwitch {
                id: enable_ticker
                anchors.rightMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                enabled: !block_everything
                Component.onCompleted: checked = model.is_multi_ticker_currently_enabled
                onCheckedChanged: {
                    model.is_multi_ticker_currently_enabled = checked

                    if(checked) {
                        let d = getData()
                        if(!d.trade_info) {
                            d.info_needs_update = true
                            setData(d)
                        }
                    }
                    else if(!checked) {
                        resetData()
                    }
                }
            }


            DefaultText {
                anchors.verticalCenter: enable_ticker.verticalCenter
                anchors.right: enable_ticker.left
                anchors.rightMargin: 10
                visible: model.multi_ticker_data.trade_info !== undefined

                text_value: API.app.settings_pg.empty_string + (General.cex_icon)

                DefaultMouseArea {
                    id: mouse_area
                    anchors.fill: parent
                    enabled: parent.visible
                    hoverEnabled: true
                }

                DefaultTooltip {
                    visible: mouse_area.containsMouse

                    contentItem: ColumnLayout {
                        DefaultText {
                            id: tx_fee_text
                            text_value: API.app.settings_pg.empty_string + (General.txFeeText(model.multi_ticker_data.trade_info, multi_order_line.base, false))
                            font.pixelSize: Style.textSizeSmall4
                        }
                        DefaultText {
                            text_value: API.app.settings_pg.empty_string + (General.tradingFeeText(model.multi_ticker_data.trade_info, multi_order_line.base, false))
                            font.pixelSize: tx_fee_text.font.pixelSize
                        }
                    }
                }
            }

            HorizontalLine {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }
    }

    DefaultBusyIndicator {
        anchors.centerIn: parent
        visible: fetching_multi_ticker_fees_busy
    }
}
