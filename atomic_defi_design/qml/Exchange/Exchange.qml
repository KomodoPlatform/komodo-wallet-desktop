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

    readonly property alias loader: loader
    readonly property alias current_component: loader.item
    property int current_page: idx_exchange_trade

    readonly property string left_ticker: API.app.trading_pg.market_pairs_mdl.left_selected_coin
    readonly property string right_ticker: API.app.trading_pg.market_pairs_mdl.right_selected_coin
    readonly property string base_ticker: API.app.trading_pg.market_pairs_mdl.base_selected_coin
    readonly property string rel_ticker: API.app.trading_pg.market_pairs_mdl.rel_selected_coin

    function cancelOrder(order_id) {
        API.app.trading_pg.cancel_order(order_id)
    }

    Component.onCompleted: {
        API.app.trading_pg.on_gui_enter_dex()
    }

    Component.onDestruction: API.app.trading_pg.on_gui_leave_dex()

    function inCurrentPage() {
        return  dashboard.inCurrentPage() &&
                dashboard.current_page === idx_dashboard_exchange
    }

    function openTradeView(ticker) {
        current_page = idx_exchange_trade

        exchange.loader.onLoadComplete = () => {
            exchange.current_component.onOpened(ticker)
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        anchors.fill: parent
        anchors.topMargin: 20

        spacing: layout_margin

        // Top tabs
        FloatingBackground {
            id: balance_box
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.topMargin: layout_margin
            Layout.rightMargin: layout_margin
            visible: false

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
//                    ExchangeTab {
//                        dashboard_index: idx_exchange_trade_v2
//                        text_value: qsTr("Trade V2")
//                    }

//                    VerticalLineBasic {
//                        height: content.height * 0.5
//                        color: Style.colorTheme5
//                    }

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
//        Component {
//            id: exchange_trade

//            Trade {}
//        }
        Component {
            id: exchange_trade

            TradeV2 {}
        }

//        Component {
//            id: exchange_orders

//            Orders {}
//        }

//        Component {
//            id: exchange_history

//            History {}
//        }

        DefaultLoader {
            id: loader

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: layout_margin
            Layout.rightMargin: Layout.bottomMargin

            sourceComponent: {
                switch(current_page) {
                case idx_exchange_trade: return exchange_trade

                default: return undefined
                }
            }
        }

        Item {
            visible: !loader.visible

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: layout_margin
            Layout.rightMargin: Layout.bottomMargin

            DefaultBusyIndicator {
                anchors.centerIn: parent
            }
        }
    }
}
