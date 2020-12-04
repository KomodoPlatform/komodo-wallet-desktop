import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Components"
import "../Constants"
import "./Trade"
import "./Orders"
import "./History"

Item {
    id: exchange
    readonly property int layout_margin: 15

    property int prev_page: -1
    property int current_page: idx_exchange_trade

    function cancelOrder(order_id) {
        API.app.trading_pg.cancel_order(order_id)
    }

    Component.onCompleted: {
        API.app.trading_pg.on_gui_enter_dex()
        onOpened()
    }

    Component.onDestruction: API.app.trading_pg.on_gui_leave_dex()

    function inCurrentPage() {
        return  dashboard.inCurrentPage() &&
                dashboard.current_page === idx_dashboard_exchange
    }

    function openTradeView(ticker) {
        current_page = idx_exchange_trade
        exchange_trade.open(ticker)
    }

    function onTradeTickerChanged(ticker) {
        exchange_orders.changeTicker(ticker)
    }

    function onOpened() {
        if(prev_page !== current_page) {
            // Handle DEX enter/exit
            if(current_page === idx_exchange_trade) {
                API.app.trading_pg.on_gui_enter_dex()
                exchange_trade.onOpened()
            }
            else if(prev_page === idx_exchange_trade) {
                API.app.trading_pg.on_gui_leave_dex()
            }

            // Opening of other pages
            if(current_page === idx_exchange_orders) {
                exchange_orders.onOpened()
            }
            else if(current_page === idx_exchange_history) {
                exchange_history.onOpened()
            }
        }

        prev_page = current_page
    }

    onCurrent_pageChanged: {
        onOpened()
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        anchors.fill: parent

        spacing: layout_margin

        // Top tabs
        FloatingBackground {
            id: balance_box
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.topMargin: layout_margin
            Layout.rightMargin: layout_margin

            content: Item {
                id: content
                width: balance_box.width
                height: 62

                RowLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 30

                    ExchangeTab {
                        dashboard_index: idx_exchange_trade
                        text_value: qsTr("Trade")
                    }

                    VerticalLineBasic {
                        id: vline
                        height: content.height * 0.5
                        color: Style.colorTheme5
                    }

                    ExchangeTab {
                        dashboard_index: idx_exchange_orders
                        text_value: qsTr("Orders")
                    }

                    VerticalLineBasic {
                        height: vline.height
                        color: vline.color
                    }

                    ExchangeTab {
                        dashboard_index: idx_exchange_history
                        text_value: qsTr("History")
                    }
                }
            }
        }

        // Bottom content
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: layout_margin
            Layout.rightMargin: Layout.bottomMargin

            currentIndex: current_page

            Trade {
                id: exchange_trade

                onOrderSuccess: () => {
                    General.prevent_coin_disabling.restart()
                    exchange_trade.reset(false)
                    exchange.current_page = idx_exchange_orders
                }
            }

            Orders {
                id: exchange_orders
            }

            History {
                id: exchange_history
            }
        }
    }
}








/*##^##
Designer {
    D{i:0;autoSize:true;height:264;width:1200}
}
##^##*/
