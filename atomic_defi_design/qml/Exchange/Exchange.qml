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
        API.app.trading_pg.orders.cancel_order(order_id)
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

        Component {
            id: exchange_trade

            Trade201 {}
        }

        DefaultLoader {
            id: loader

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.bottomMargin: layout_margin
            Layout.rightMargin: Layout.bottomMargin

            sourceComponent: exchange_trade
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
