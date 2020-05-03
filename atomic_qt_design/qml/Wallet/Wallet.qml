import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

RowLayout {
    id: wallet

    // Local
    function onClickedSwap() {
        dashboard.current_page = General.idx_dashboard_exchange
        exchange.current_page = General.idx_exchange_trade
        exchange.openTradeView(API.get().current_coin_info.ticker)
    }

    function reset() {
        main.reset()
        sidebar.reset()
        enable_coin_modal.reset()
    }

    function onOpened() {
        updatePortfolio()
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
