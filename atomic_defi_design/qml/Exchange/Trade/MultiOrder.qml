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

            property bool info_needs_update: false

            property var trade_info

            readonly property string base: sell_mode ? left_ticker : model.ticker
            readonly property string rel: sell_mode ? model.ticker : left_ticker

            Connections {
                target: exchange_trade

                function onFetching_multi_ticker_fees_busyChanged() {
                    if(fetching_multi_ticker_fees_busy || !enable_ticker.checked) return undefined
                    if(!multi_order_line.info_needs_update) return trade_info

                    const base = multi_order_line.base
                    const rel = multi_order_line.rel

                    const amt = API.app.get_balance(base)
                    console.log("Updating trading info for ", base, "/", rel, " with amount:", amt)
                    let info = API.app.get_trade_infos(base, rel, amt)
                    console.log(General.prettifyJSON(info))
                    if(info.input_final_value === undefined || info.input_final_value === "nan" || info.input_final_value === "NaN") {
                        console.log("Bad trade info!")
                        return undefined
                    }

                    multi_order_line.info_needs_update = false

                    multi_order_line.trade_info = info
                }
            }

            DexComboBoxLine {
                anchors.fill: parent
                details: model
                padding: 10
            }

            DefaultText {
                anchors.centerIn: parent
                text_value: {
                    let price_field_text = getCurrentForm().price_field.text
                    if(price_field_text === '') price_field_text = '0'
                    const rel_price_for_one_unit = parseFloat(model.main_currency_price_for_one_unit)
                    const price_field_fiat = parseFloat(price_field_text) * rel_price_for_one_unit
                    const rel_price_relative = rel_price_for_one_unit === 0 ? 0 : price_field_fiat / rel_price_for_one_unit
                    return General.formatCrypto("", rel_price_relative, multi_order_line.rel)
                }
            }

            DefaultSwitch {
                id: enable_ticker
                anchors.rightMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                enabled: !block_everything
                onCheckedChanged: {
                    model.is_multi_ticker_currently_enabled = checked
                    if(checked) info_needs_update = true
                }
            }


            DefaultText {
                anchors.verticalCenter: enable_ticker.verticalCenter
                anchors.right: enable_ticker.left
                anchors.rightMargin: 10
                visible: multi_order_line.trade_info !== undefined

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
                            text_value: API.app.settings_pg.empty_string + (General.txFeeText(multi_order_line.trade_info, multi_order_line.base, false))
                            font.pixelSize: Style.textSizeSmall4
                        }
                        DefaultText {
                            text_value: API.app.settings_pg.empty_string + (General.tradingFeeText(multi_order_line.trade_info, multi_order_line.base, false))
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
