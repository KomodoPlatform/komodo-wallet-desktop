import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

RowLayout {
    id: wallet

    property alias send_modal: main.send_modal

    function inCurrentPage() {
        return  dashboard.inCurrentPage() &&
                dashboard.current_page === General.idx_dashboard_wallet
    }

    // Local
    function onClickedSwap() {
        dashboard.current_page = General.idx_dashboard_exchange
        exchange.current_page = General.idx_exchange_trade
        exchange.openTradeView(api_wallet_page.ticker)
    }

    function reset() {
        main.reset()
        sidebar.reset()
        enable_coin_modal.reset()
    }

    function onOpened() {
        // Reset the coin name filter
        sidebar.reset()
    }

    readonly property double button_margin: 0.05
    spacing: 0
    Layout.fillWidth: true

    // Coins bar at left side
    Sidebar {
        id: sidebar
    }

    // Right side, main
    Main {
        id: main
    }
}









/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:1200}
}
##^##*/
