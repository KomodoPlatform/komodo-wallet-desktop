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

            Connections {
                target: exchange_trade

                function onFetching_multi_ticker_fees_busyChanged() {
                    if(fetching_multi_ticker_fees_busy || !enable_ticker.checked) return undefined
                    if(!multi_order_line.info_needs_update) return trade_info

                    const base = sell_mode ? left_ticker : model.ticker
                    const rel =  sell_mode ? model.ticker : left_ticker

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
                text_value: !trade_info ? "" :
                            trade_info.tx_fee + " + " + trade_info.trade_fee
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
